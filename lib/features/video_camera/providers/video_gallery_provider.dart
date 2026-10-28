import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import '../../sharing/services/cloudinary_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/video_model.dart';

const _boxName = 'video_gallery';

Future<String> _docsDir() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

String _toFilename(String pathOrName) => p.basename(pathOrName);

class VideoGalleryNotifier extends StateNotifier<List<VideoModel>> {
  VideoGalleryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final docsPath = await _docsDir();
    final videos = <VideoModel>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        try {
          final map = Map<String, dynamic>.from(raw);
          final filename = _toFilename(map['videoPath'] as String);
          map['videoPath'] = p.join(docsPath, filename);
          videos.add(VideoModel.fromMap(map));
        } catch (_) {}
      }
    }
    videos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = videos;
  }

  /// See GalleryNotifier.claimUntagged — same migration for videos.
  Future<void> claimUntagged(String uid) async {
    final untagged = state.where((v) => v.ownerUid == null).toList();
    if (untagged.isEmpty) return;

    final box = await Hive.openBox(_boxName);
    for (final video in untagged) {
      final raw = box.get(video.id);
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw)..['ownerUid'] = uid;
      await box.put(video.id, map);
    }

    debugPrint(
      '🔎 [VideoGallery] claimed ${untagged.length} untagged video(s)',
    );
    state = [
      for (final video in state)
        video.ownerUid == null ? video.copyWith(ownerUid: uid) : video,
    ];
  }

  Future<void> addVideo(VideoModel video) async {
    final box = await Hive.openBox(_boxName);
    final storedMap = video.toMap();
    storedMap['videoPath'] = _toFilename(video.videoPath);
    await box.put(video.id, storedMap);
    state = [video, ...state];
  }

  Future<void> deleteVideo(String id) async {
    // Attempt to delete from Cloudinary first (best effort)
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final cloudinary = CloudinaryClient();
        await cloudinary.destroy(
          publicId: '${AppConstants.cloudinaryFolder}/$uid/$id',
          kind: MediaKind.video,
        );
      }
    } catch (e) {
      debugPrint('🔥 [VideoGallery] failed to delete from Cloudinary: $e');
    }

    // Delete local file
    try {
      final video = state.firstWhere((v) => v.id == id);
      final file = File(video.videoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('🔥 [VideoGallery] failed to delete local file: $e');
    }

    final box = await Hive.openBox(_boxName);
    await box.delete(id);
    state = state.where((v) => v.id != id).toList();
  }
}

final videoGalleryProvider =
    StateNotifierProvider<VideoGalleryNotifier, List<VideoModel>>((ref) {
      return VideoGalleryNotifier();
    });
