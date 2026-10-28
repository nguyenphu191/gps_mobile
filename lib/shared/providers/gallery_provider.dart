import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/models/photo_model.dart';
import '../../features/sharing/services/cloudinary_client.dart';
import '../../core/constants/app_constants.dart';

const _boxName = 'gallery';

/// Returns the app documents directory path (stable across builds).
Future<String> _docsDir() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// Extract only the filename from a path (handles both old absolute paths
/// and already-filename-only entries).
String _toFilename(String pathOrName) => p.basename(pathOrName);

class GalleryNotifier extends StateNotifier<List<PhotoModel>> {
  GalleryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final docsPath = await _docsDir();
    final photos = <PhotoModel>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        try {
          final map = Map<String, dynamic>.from(raw);
          // Always resolve to full path at load time
          final filename = _toFilename(map['imagePath'] as String);
          map['imagePath'] = p.join(docsPath, filename);
          photos.add(PhotoModel.fromMap(map));
        } catch (_) {
          // Skip corrupted entries.
        }
      }
    }
    photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = photos;
  }

  /// One-time migration: photos taken before `ownerUid` existed have no owner,
  /// so any account signing in on this device would show them as its own.
  /// The first account to sign in after the update claims them — which is the
  /// right answer for the overwhelmingly common single-account device, and
  /// stops a second account from inheriting them.
  Future<void> claimUntagged(String uid) async {
    final untagged = state.where((p) => p.ownerUid == null).toList();
    if (untagged.isEmpty) return;

    final box = await Hive.openBox(_boxName);
    for (final photo in untagged) {
      final raw = box.get(photo.id);
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw)..['ownerUid'] = uid;
      await box.put(photo.id, map);
    }

    debugPrint('🔎 [Gallery] claimed ${untagged.length} untagged photo(s)');
    state = [
      for (final photo in state)
        photo.ownerUid == null ? photo.copyWith(ownerUid: uid) : photo,
    ];
  }

  Future<void> addPhoto(PhotoModel photo) async {
    final box = await Hive.openBox(_boxName);
    // Store only filename — not the full path
    final storedMap = photo.toMap();
    storedMap['imagePath'] = _toFilename(photo.imagePath);
    await box.put(photo.id, storedMap);
    state = [photo, ...state];
  }

  Future<void> deletePhoto(String id) async {
    // Attempt to delete from Cloudinary first (best effort)
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final cloudinary = CloudinaryClient();
        await cloudinary.destroy(
          publicId: '${AppConstants.cloudinaryFolder}/$uid/$id',
          kind: MediaKind.photo,
        );
      }
    } catch (e) {
      debugPrint('🔥 [Gallery] failed to delete from Cloudinary: $e');
    }

    // Delete local file
    try {
      final photo = state.firstWhere((p) => p.id == id);
      final file = File(photo.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('🔥 [Gallery] failed to delete local file: $e');
    }

    final box = await Hive.openBox(_boxName);
    await box.delete(id);
    state = state.where((p) => p.id != id).toList();
  }

  void sortByDate({bool ascending = false}) {
    final sorted = [...state];
    sorted.sort(
      (a, b) => ascending
          ? a.timestamp.compareTo(b.timestamp)
          : b.timestamp.compareTo(a.timestamp),
    );
    state = sorted;
  }

  void sortByDistance({
    required double fromLatitude,
    required double fromLongitude,
  }) {
    final sorted = [...state];
    sorted.sort((a, b) {
      final distA = _haversine(
        fromLatitude,
        fromLongitude,
        a.latitude,
        a.longitude,
      );
      final distB = _haversine(
        fromLatitude,
        fromLongitude,
        b.latitude,
        b.longitude,
      );
      return distA.compareTo(distB);
    });
    state = sorted;
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371e3; // Earth radius in metres.
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;

  Future<void> refresh() => _load();
}

final galleryProvider =
    StateNotifierProvider<GalleryNotifier, List<PhotoModel>>(
      (ref) => GalleryNotifier(),
    );
