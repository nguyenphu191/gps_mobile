import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/map_media_item.dart';
import '../../auth/services/auth_service.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/services/notification_service.dart';
import '../models/shared_media_model.dart';
import 'cloudinary_client.dart';
import 'media_compressor.dart';

/// Uploads the current user's media to Cloudinary and reads back the media
/// shared by friends (indexed in Firestore).
class MediaShareService {
  static const String collectionName = 'shared_media';

  // Firestore allows at most 30 values in a `whereIn`; keep well under it.
  static const int _chunkSize = 10;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryClient _cloudinary = CloudinaryClient();
  final AuthService _authService;

  MediaShareService(this._authService);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Upload one media file and index it. Returns false when it should be
  /// retried later (offline, transient failure, not signed in).
  Future<bool> upload({
    required String id,
    required File file,
    required MediaKind kind,
    required double latitude,
    required double longitude,
    required String address,
    required DateTime timestamp,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    if (!file.existsSync()) return true; // nothing to upload, don't retry

    // Photos go up as a downsized JPEG; videos are already capped at 10s.
    final toUpload = kind == MediaKind.photo
        ? await compressForUpload(file, id: id)
        : file;

    try {
      // One asset per media id, namespaced per user inside the preset's folder.
      final result = await _cloudinary.upload(
        toUpload,
        publicId: '$uid/$id',
        kind: kind,
      );
      if (result == null) return false;

      final owner = await _authService.getUserData(uid);

      final media = SharedMediaModel(
        id: id,
        ownerUid: uid,
        ownerName: owner?.displayName.isNotEmpty == true
            ? owner!.displayName
            : (owner?.username ?? ''),
        ownerPhotoUrl: owner?.photoUrl ?? '',
        kind: kind,
        storagePath: result.publicId,
        downloadUrl: result.secureUrl,
        latitude: latitude,
        longitude: longitude,
        address: address,
        timestamp: timestamp,
      );

      // Doc id == local media id, so a retry overwrites instead of duplicating.
      await _firestore.collection(collectionName).doc(id).set(media.toMap());

      // Tell friends about it. Best effort — the media is already shared.
      await NotificationService(uid).notifyFriends(
        type: NotificationType.friendMedia,
        pushTitle: media.ownerName,
        pushBody: kind == MediaKind.video ? 'shared a video' : 'shared a photo',
        mediaId: id,
        mediaKind: kind == MediaKind.video ? 'video' : 'photo',
        thumbnailUrl: CloudinaryClient.thumbnailUrl(result.secureUrl),
      );
      return true;
    } catch (e) {
      debugPrint('🔥 [MediaShare] upload failed for $id: $e');
      return false;
    } finally {
      if (toUpload.path != file.path) {
        try {
          await toUpload.delete();
        } catch (_) {
          // Temp file will be reclaimed with the cache directory.
        }
      }
    }
  }

  /// Stop sharing an item: the Cloudinary asset is deleted and the index doc
  /// goes away, so it disappears from friends' maps immediately.
  Future<void> deleteShared(String id) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      final data = doc.data();
      if (data == null) return;
      if (data['ownerUid'] != uid) return;

      // Delete the asset first: once the document is gone there is no way
      // left to find the file again.
      final media = SharedMediaModel.fromMap(data, doc.id);
      if (media.storagePath.isNotEmpty) {
        final destroyed = await _cloudinary.destroy(
          publicId: media.storagePath,
          kind: media.kind,
        );
        if (!destroyed) {
          // The user asked for this to go away — never block on Cloudinary.
          // Worst case the file is orphaned; see docs/firebase-setup.md.
          debugPrint('🔥 [MediaShare] asset $id left on Cloudinary');
        }
      }

      await doc.reference.delete();
    } catch (e) {
      debugPrint('🔥 [MediaShare] delete failed for $id: $e');
    }
  }

  /// Live media shared by the given friends, merged across `whereIn` chunks.
  Stream<List<SharedMediaModel>> friendsMedia(List<String> friendUids) {
    if (friendUids.isEmpty) return Stream.value(const []);

    final chunks = <List<String>>[];
    for (var i = 0; i < friendUids.length; i += _chunkSize) {
      chunks.add(
        friendUids.sublist(
          i,
          i + _chunkSize > friendUids.length
              ? friendUids.length
              : i + _chunkSize,
        ),
      );
    }

    final latest = List<List<SharedMediaModel>>.filled(chunks.length, const []);
    final controller = StreamController<List<SharedMediaModel>>();
    final subs = <StreamSubscription>[];

    void emit() {
      if (controller.isClosed) return;
      final all = latest.expand((e) => e).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      controller.add(all);
    }

    for (var i = 0; i < chunks.length; i++) {
      final index = i;
      subs.add(
        _firestore
            .collection(collectionName)
            .where('ownerUid', whereIn: chunks[index])
            .snapshots()
            .listen(
              (snapshot) {
                latest[index] = snapshot.docs
                    .map((d) => SharedMediaModel.fromMap(d.data(), d.id))
                    .toList();
                debugPrint(
                  '🔎 [FriendMedia] chunk $index (${chunks[index].length} uids) '
                  '→ ${snapshot.docs.length} doc(s)',
                );
                emit();
              },
              // Surfaced, not swallowed: a rules rejection used to look
              // identical to "this friend has shared nothing".
              onError: (Object e, StackTrace st) {
                debugPrint('🔎 [FriendMedia] chunk $index FAILED: $e');
                if (!controller.isClosed) controller.addError(e, st);
              },
            ),
      );
    }

    controller.onCancel = () async {
      for (final sub in subs) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }
}

final mediaShareServiceProvider = Provider<MediaShareService>(
  (ref) => MediaShareService(ref.watch(authServiceProvider)),
);
