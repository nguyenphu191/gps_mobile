import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<void> signInWithGoogle() async {
    try {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      await _saveUserToFirestore(userCredential.user);
    } finally {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    // User will be updated in Firestore automatically by authStateChanges if not exists, but usually we just log in
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    // Create the user first to get Firebase Auth permissions for reading Firestore
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      try {
        final exists = await checkUsernameExists(username);
        if (exists) {
          // Rollback if username is taken
          await user.delete();
          throw Exception('Username already taken');
        }

        final docRef = _firestore.collection('users').doc(user.uid);
        final newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: '',
          photoUrl: '',
          username: username,
        );
        await docRef.set(newUser.toMap());
      } catch (e) {
        // If anything fails (like network error during check), rollback user creation
        try {
          await user.delete();
        } catch (_) {}
        rethrow;
      }
    }
  }

  Future<void> signInWithApple() async {
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    await _saveUserToFirestore(userCredential.user);
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        username: '', // Needs to be setup by user later
      );
      await docRef.set(newUser.toMap());
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Point the profile at a newly uploaded avatar.
  Future<void> updatePhotoUrl(String uid, String photoUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  Future<void> updateUsername(String uid, String username) async {
    await _firestore.collection('users').doc(uid).update({
      'username': username,
    });
  }

  Future<void> updateLocation(String uid, double lat, double lng) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLatitude': lat,
      'lastLongitude': lng,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> toggleLocationSharing(String uid, bool isShared) async {
    await _firestore.collection('users').doc(uid).update({
      'isLocationShared': isShared,
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(authServiceProvider).getUserData(user.uid);
});
