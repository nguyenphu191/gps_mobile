import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/map_media_item.dart';
import '../../../shared/providers/gallery_provider.dart';
import '../../sharing/services/cloudinary_client.dart';
import '../../sharing/services/media_share_service.dart';
import '../../sharing/services/upload_queue.dart';
import '../../video_camera/providers/video_gallery_provider.dart';

enum AccountDeletionResult {
  success,

  /// Firebase refuses to delete an account whose sign-in is old. The user has
  /// to sign in again, then the whole thing can be retried.
  needsReauth,

  failed,
}

/// Deletes the account and everything attached to it.
///
/// Required by App Store guideline 5.1.1(v): an app that lets people create an
/// account must let them delete it — and the data with it — from inside the app.
class AccountDeletionService {
  /// Firestore allows 500 operations per batch.
  static const int _batchLimit = 400;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryClient _cloudinary = CloudinaryClient();
  final MediaShareService _mediaShare;
  final Ref _ref;

  AccountDeletionService(this._ref, this._mediaShare);

  Future<AccountDeletionResult> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AccountDeletionResult.failed;
    final uid = user.uid;

    try {
      // Data first, account last: once the account is gone the rules deny
      // every write, and whatever is left behind can never be cleaned up.
      await _deleteSharedMedia(uid);
      await _deleteAvatar(uid);
      await _deleteLocationShares(uid);
      await _deleteFriendships(uid);
      await _firestore.collection('users').doc(uid).delete();
      await _clearLocalData();

      await user.delete();
      return AccountDeletionResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint('🔥 [DeleteAccount] needs re-authentication');
        return AccountDeletionResult.needsReauth;
      }
      debugPrint('🔥 [DeleteAccount] auth error: $e');
      return AccountDeletionResult.failed;
    } catch (e) {
      debugPrint('🔥 [DeleteAccount] failed: $e');
      return AccountDeletionResult.failed;
    }
  }

  /// Each shared item takes its Cloudinary asset with it.
  Future<void> _deleteSharedMedia(String uid) async {
    final snapshot = await _firestore
        .collection(MediaShareService.collectionName)
        .where('ownerUid', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      await _mediaShare.deleteShared(doc.id);
    }
  }

  Future<void> _deleteAvatar(String uid) async {
    await _cloudinary.destroy(
      publicId: '${AppConstants.cloudinaryAvatarFolder}/$uid',
      kind: MediaKind.photo,
    );
  }

  Future<void> _deleteLocationShares(String uid) async {
    await _deleteMatching('location_shares', 'toUid', uid);
    await _deleteMatching('location_shares', 'fromUid', uid);
  }

  Future<void> _deleteFriendships(String uid) async {
    await _deleteMatching('friends', 'senderId', uid);
    await _deleteMatching('friends', 'receiverId', uid);
  }

  Future<void> _deleteMatching(
    String collection,
    String field,
    String uid,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(field, isEqualTo: uid)
        .get();
    if (snapshot.docs.isEmpty) return;

    for (var i = 0; i < snapshot.docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      final end = (i + _batchLimit).clamp(0, snapshot.docs.length);
      for (final doc in snapshot.docs.sublist(i, end)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _clearLocalData() async {
    // Photos and videos: the notifiers remove the files from disk too.
    final gallery = _ref.read(galleryProvider.notifier);
    for (final photo in [..._ref.read(galleryProvider)]) {
      await gallery.deletePhoto(photo.id);
    }
    final videos = _ref.read(videoGalleryProvider.notifier);
    for (final video in [..._ref.read(videoGalleryProvider)]) {
      await videos.deleteVideo(video.id);
    }

    try {
      final uploads = await Hive.openBox(UploadQueue.boxName);
      await uploads.clear();
      final settings = Hive.isBoxOpen(AppConstants.settingsBoxName)
          ? Hive.box(AppConstants.settingsBoxName)
          : await Hive.openBox(AppConstants.settingsBoxName);
      await settings.delete('last_seen_location_share');
    } catch (e) {
      debugPrint('🔥 [DeleteAccount] local cleanup failed: $e');
    }
  }
}

final accountDeletionServiceProvider = Provider<AccountDeletionService>(
  (ref) => AccountDeletionService(ref, ref.watch(mediaShareServiceProvider)),
);
