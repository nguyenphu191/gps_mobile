import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/push_notification_service.dart';
import '../models/friend_model.dart';
import '../models/location_share_model.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/services/notification_service.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId;

  FriendService(this._currentUserId);

  NotificationService get _notifications => NotificationService(_currentUserId);

  Stream<List<FriendModel>> getFriendsStream() {
    final asSender = _firestore
        .collection('friends')
        .where('senderId', isEqualTo: _currentUserId)
        .snapshots();

    final asReceiver = _firestore
        .collection('friends')
        .where('receiverId', isEqualTo: _currentUserId)
        .snapshots();

    final controller = StreamController<List<FriendModel>>.broadcast();
    List<FriendModel> senderDocs = [];
    List<FriendModel> receiverDocs = [];

    void emit() {
      final all = <FriendModel>[];
      final seen = <String>{};
      for (final doc in [...senderDocs, ...receiverDocs]) {
        if (seen.add(doc.id)) {
          all.add(doc);
        }
      }
      // Sort by creation time so newest requests are usually on top.
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(all);
    }

    final sub1 = asSender.listen((snap) {
      senderDocs = snap.docs
          .map((doc) => FriendModel.fromMap(doc.data(), doc.id))
          .toList();
      emit();
    });

    final sub2 = asReceiver.listen((snap) {
      receiverDocs = snap.docs
          .map((doc) => FriendModel.fromMap(doc.data(), doc.id))
          .toList();
      emit();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
    };

    return controller.stream;
  }

  Future<void> sendFriendRequest(String receiverId) async {
    final existing1 = await _firestore
        .collection('friends')
        .where('senderId', isEqualTo: _currentUserId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    final existing2 = await _firestore
        .collection('friends')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: _currentUserId)
        .get();

    if (existing1.docs.isNotEmpty || existing2.docs.isNotEmpty) {
      return; // Already friends or request pending
    }

    final newRequest = FriendModel(
      id: '',
      senderId: _currentUserId,
      receiverId: receiverId,
      status: FriendStatus.pending,
      createdAt: DateTime.now(),
    );

    final doc = await _firestore.collection('friends').add(newRequest.toMap());

    // Best effort: the request itself is already saved.
    await _notifications.notifyUser(
      toUid: receiverId,
      type: NotificationType.friendRequest,
      pushTitle: 'GPS Camera',
      pushBody: 'You have a new friend request',
      friendDocId: doc.id,
    );
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final ref = _firestore.collection('friends').doc(requestId);
    await ref.update({'status': FriendStatus.accepted.name});

    // Tell whoever asked that they are now friends.
    final senderId = (await ref.get()).data()?['senderId'] as String?;
    if (senderId != null) {
      await _notifications.notifyUser(
        toUid: senderId,
        type: NotificationType.friendRequestAccepted,
        pushTitle: 'GPS Camera',
        pushBody: 'Your friend request was accepted',
      );
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friends').doc(requestId).delete();
  }

  Future<void> removeFriend(String requestId) async {
    final doc = await _firestore.collection('friends').doc(requestId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final senderId = data['senderId'] as String?;
      final receiverId = data['receiverId'] as String?;

      if (senderId != null && receiverId != null) {
        final batch = _firestore.batch();

        final shares1 = await _firestore
            .collection('location_shares')
            .where('fromUid', isEqualTo: senderId)
            .where('toUid', isEqualTo: receiverId)
            .get();
        for (final doc in shares1.docs) {
          batch.delete(doc.reference);
        }

        final shares2 = await _firestore
            .collection('location_shares')
            .where('fromUid', isEqualTo: receiverId)
            .where('toUid', isEqualTo: senderId)
            .get();
        for (final doc in shares2.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    }

    await _firestore.collection('friends').doc(requestId).delete();
  }

  // ─── One-shot location sharing ────────────────────────────────

  /// Send my current location to one friend.
  Future<void> sendLocation({
    required String toUid,
    required double latitude,
    required double longitude,
    String address = '',
  }) async {
    final me = await _firestore.collection('users').doc(_currentUserId).get();
    final data = me.data() ?? const <String, dynamic>{};

    final share = LocationShareModel(
      id: '',
      fromUid: _currentUserId,
      fromName: (data['displayName'] as String?)?.isNotEmpty == true
          ? data['displayName'] as String
          : (data['username'] as String? ?? ''),
      fromPhotoUrl: data['photoUrl'] as String? ?? '',
      toUid: toUid,
      latitude: latitude,
      longitude: longitude,
      address: address,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('location_shares').add(share.toMap());

    // Best-effort push so the friend sees it without opening the app.
    final recipient = await _firestore.collection('users').doc(toUid).get();
    final tokens =
        (recipient.data()?['fcmTokens'] as List?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    await PushNotificationService().notifyLocationShared(
      tokens: tokens,
      fromName: share.fromName,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    // Also land in the recipient's notification inbox. The push above already
    // went out, so this write only adds the row — no second banner.
    await _notifications.writeInboxOnly(
      toUid: toUid,
      type: NotificationType.locationShare,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  /// Locations friends have sent to me, newest first.
  Stream<List<LocationShareModel>> receivedLocationsStream() {
    return _firestore
        .collection('location_shares')
        .where('toUid', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LocationShareModel.fromMap(doc.data(), doc.id))
              // Expired shares are filtered here rather than trusted to the
              // TTL policy, which can lag hours behind the 24h mark.
              .where((share) => !share.isExpired)
              .toList(),
        );
  }

  /// Remove one share addressed to me.
  Future<void> deleteLocationShare(String id) async {
    final doc = await _firestore.collection('location_shares').doc(id).get();
    final data = doc.data();
    if (data == null) return;
    if (data['toUid'] != _currentUserId) return;
    await doc.reference.delete();
  }

  /// Delete every expired share this user is part of — both the ones sent to
  /// them and the ones they sent.
  ///
  /// This is the only cleanup that runs: Firestore TTL policies require the
  /// Blaze plan, so whichever side opens the app first removes the record.
  /// It also covers documents written before `expiresAt` existed.
  Future<void> purgeExpiredLocationShares() async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('location_shares')
            .where('toUid', isEqualTo: _currentUserId)
            .get(),
        _firestore
            .collection('location_shares')
            .where('fromUid', isEqualTo: _currentUserId)
            .get(),
      ]);

      final seen = <String>{};
      final expired = <DocumentReference>[];
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          if (!seen.add(doc.id)) continue;
          if (LocationShareModel.fromMap(doc.data(), doc.id).isExpired) {
            expired.add(doc.reference);
          }
        }
      }
      if (expired.isEmpty) return;

      final batch = _firestore.batch();
      for (final ref in expired) {
        batch.delete(ref);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('🔥 [Friends] purge expired shares failed: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String queryStr) async {
    final q = queryStr.startsWith('@') ? queryStr.substring(1).toLowerCase() : queryStr.toLowerCase();
    
    // Exact match search since Firestore doesn't natively support case-insensitive prefix search well without extra fields
    // But we'll try a basic prefix search assuming usernames are stored lowercase (or just match as they are)
    final query = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: q)
        .where('username', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    return query.docs
        .where((doc) => doc.id != _currentUserId)
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}

final friendServiceProvider = Provider<FriendService?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return FriendService(user.uid);
});

final friendsStreamProvider = StreamProvider<List<FriendModel>>((ref) {
  final service = ref.watch(friendServiceProvider);
  if (service == null) return Stream.value([]);
  return service.getFriendsStream();
});

final receivedLocationsProvider = StreamProvider<List<LocationShareModel>>((
  ref,
) {
  final service = ref.watch(friendServiceProvider);
  if (service == null) return Stream.value([]);
  return service.receivedLocationsStream();
});
