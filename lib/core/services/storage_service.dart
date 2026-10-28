import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';

/// Model representing a saved photo record.
class PhotoRecord {
  final String id;
  final String filePath;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PhotoRecord({
    required this.id,
    required this.filePath,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PhotoRecord.fromMap(Map<dynamic, dynamic> map) {
    return PhotoRecord(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }
}

/// Model representing a location history entry.
class LocationHistoryEntry {
  final String id;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationHistoryEntry({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return LocationHistoryEntry(
      id: map['id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class StorageService {
  /// Boxes are opened once in [main]; read them lazily so the service works
  /// without a separate initialize() call.
  Box? _box(String name) => Hive.isBoxOpen(name) ? Hive.box(name) : null;

  Box? get _photosBox => _box(AppConstants.photosBoxName);
  Box? get _historyBox => _box(AppConstants.historyBoxName);
  Box? get _settingsBox => _box(AppConstants.settingsBoxName);

  /// Open any box that isn't open yet. Safe to call more than once.
  Future<void> initialize() async {
    await Hive.initFlutter();
    for (final name in const [
      AppConstants.photosBoxName,
      AppConstants.historyBoxName,
      AppConstants.settingsBoxName,
    ]) {
      if (!Hive.isBoxOpen(name)) await Hive.openBox(name);
    }
  }

  // ─── Photos CRUD ──────────────────────────────────────────────

  /// Save a photo record.
  Future<void> savePhoto(PhotoRecord photo) async {
    await _photosBox?.put(photo.id, photo.toMap());
  }

  /// Get a single photo record by ID.
  PhotoRecord? getPhoto(String id) {
    final data = _photosBox?.get(id);
    if (data == null) return null;
    return PhotoRecord.fromMap(Map<dynamic, dynamic>.from(data));
  }

  /// Get all photo records, sorted by creation date (newest first).
  List<PhotoRecord> getAllPhotos() {
    final photos = <PhotoRecord>[];
    final box = _photosBox;
    if (box == null) return photos;

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          photos.add(PhotoRecord.fromMap(Map<dynamic, dynamic>.from(data)));
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }

    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  /// Update an existing photo record.
  Future<void> updatePhoto(PhotoRecord photo) async {
    await _photosBox?.put(photo.id, photo.toMap());
  }

  /// Delete a photo record by ID.
  Future<void> deletePhoto(String id) async {
    await _photosBox?.delete(id);
  }

  /// Delete all photo records.
  Future<void> deleteAllPhotos() async {
    await _photosBox?.clear();
  }

  /// Get total number of photos.
  int getPhotoCount() {
    return _photosBox?.length ?? 0;
  }

  // ─── Location History CRUD ────────────────────────────────────

  /// Save a location history entry.
  Future<void> saveLocationHistory(LocationHistoryEntry entry) async {
    await _historyBox?.put(entry.id, entry.toMap());
  }

  /// Get all location history entries, sorted by timestamp (newest first).
  List<LocationHistoryEntry> getAllLocationHistory() {
    final entries = <LocationHistoryEntry>[];
    final box = _historyBox;
    if (box == null) return entries;

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          entries.add(
            LocationHistoryEntry.fromMap(Map<dynamic, dynamic>.from(data)),
          );
        } catch (_) {
          // Skip corrupted entries
        }
      }
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get location history for a specific date.
  List<LocationHistoryEntry> getLocationHistoryForDate(DateTime date) {
    return getAllLocationHistory().where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  /// Delete a location history entry by ID.
  Future<void> deleteLocationHistory(String id) async {
    await _historyBox?.delete(id);
  }

  /// Clear all location history.
  Future<void> clearLocationHistory() async {
    await _historyBox?.clear();
  }

  /// Get total number of history entries.
  int getHistoryCount() {
    return _historyBox?.length ?? 0;
  }

  // ─── Settings ─────────────────────────────────────────────────

  /// Get a setting value.
  T? getSetting<T>(String key) {
    return _settingsBox?.get(key) as T?;
  }

  /// Save a setting value.
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  /// Check if this is the first app launch.
  bool isFirstLaunch() {
    return _settingsBox?.get(AppConstants.firstLaunchKey, defaultValue: true)
            as bool? ??
        true;
  }

  /// Mark first launch as complete.
  Future<void> setFirstLaunchComplete() async {
    await _settingsBox?.put(AppConstants.firstLaunchKey, false);
  }

  /// Get saved language code.
  String? getSavedLanguage() {
    return _settingsBox?.get(AppConstants.languageKey) as String?;
  }

  /// Save language preference.
  Future<void> saveLanguage(String languageCode) async {
    await _settingsBox?.put(AppConstants.languageKey, languageCode);
  }

  /// Get saved theme mode ('light', 'dark', or 'system').
  String getThemeMode() {
    return _settingsBox?.get(AppConstants.themeKey, defaultValue: 'system')
            as String? ??
        'system';
  }

  /// Save theme mode preference.
  Future<void> saveThemeMode(String mode) async {
    await _settingsBox?.put(AppConstants.themeKey, mode);
  }

  // ─── Cache Management ────────────────────────────────────────

  /// Clear all cached data (photos, history, settings).
  Future<void> clearAllCache() async {
    await _photosBox?.clear();
    await _historyBox?.clear();
  }

  /// Get total storage size used by Hive boxes in bytes.
  Future<int> getStorageSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      int totalSize = 0;

      // Measure Hive directory
      final hiveDir = Directory(appDir.path);
      await for (final entity in hiveDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.hive')) {
          totalSize += await entity.length();
        }
      }

      // Measure photos directory
      final photosDir = Directory('${appDir.path}/photos');
      if (await photosDir.exists()) {
        await for (final entity in photosDir.list()) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human-readable string.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  // Boxes are app-wide and opened in main(); never closed here.
  return StorageService();
});

final allPhotosProvider = Provider<List<PhotoRecord>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return storage.getAllPhotos();
});

final allLocationHistoryProvider = Provider<List<LocationHistoryEntry>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return storage.getAllLocationHistory();
});

final storageSizeProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(storageServiceProvider);
  return storage.getStorageSize();
});
