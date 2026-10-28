import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../shared/models/map_media_item.dart';
import 'media_share_service.dart';

/// Tracks which local media still needs uploading so a failed (offline)
/// upload is retried on the next app run instead of being lost.
class UploadQueue {
  static const String boxName = 'shared_uploads';

  final MediaShareService _service;
  bool _syncing = false;

  UploadQueue(this._service);

  Future<Box> _box() => Hive.openBox(boxName);

  /// Record the item and try to upload it right away (fire and forget).
  Future<void> enqueue({
    required String id,
    required String filePath,
    required MediaKind kind,
    required double latitude,
    required double longitude,
    required String address,
    required DateTime timestamp,
  }) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final entry = {
      'id': id,
      'filePath': filePath,
      'kind': kind.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };

    final box = await _box();
    await box.put(id, entry);
    await _uploadEntry(box, entry);
  }

  /// Retry everything still pending. Safe to call often; no-ops when idle.
  Future<void> syncPending() async {
    if (_syncing) return;
    if (FirebaseAuth.instance.currentUser == null) return;
    _syncing = true;
    try {
      final box = await _box();
      for (final key in box.keys.toList()) {
        final raw = box.get(key);
        if (raw is! Map) {
          await box.delete(key);
          continue;
        }
        await _uploadEntry(box, Map<String, dynamic>.from(raw));
      }
    } finally {
      _syncing = false;
    }
  }

  /// Forget a local item and remove its shared copy.
  Future<void> remove(String id) async {
    final box = await _box();
    await box.delete(id);
    await _service.deleteShared(id);
  }

  Future<void> _uploadEntry(Box box, Map<String, dynamic> entry) async {
    final id = entry['id'] as String;
    final path = entry['filePath'] as String;
    final file = File(path);

    if (!file.existsSync()) {
      // File is gone (deleted or moved) — stop tracking it.
      await box.delete(id);
      return;
    }

    final ok = await _service.upload(
      id: id,
      file: file,
      kind: entry['kind'] == MediaKind.video.name
          ? MediaKind.video
          : MediaKind.photo,
      latitude: (entry['latitude'] as num).toDouble(),
      longitude: (entry['longitude'] as num).toDouble(),
      address: entry['address'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (entry['timestamp'] as num).toInt(),
      ),
    );

    if (ok) {
      await box.delete(id);
    } else {
      debugPrint('🔥 [UploadQueue] keeping $id for a later retry');
    }
  }
}

final uploadQueueProvider = Provider<UploadQueue>(
  (ref) => UploadQueue(ref.watch(mediaShareServiceProvider)),
);
