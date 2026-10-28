import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'location_service.dart';

class PhotoService {
  /// Save a photo with GPS stamp overlay.
  ///
  /// Takes raw image bytes (e.g. from camera), draws location/date/time text
  /// onto the image, and saves it to the app's documents directory.
  /// Returns the saved file path or null on failure.
  Future<String?> savePhotoWithStamp({
    required Uint8List imageBytes,
    required LocationData location,
    bool showAddress = true,
    bool showCoordinates = true,
  }) async {
    try {
      // Decode the image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Create a copy to draw on
      final image = img.Image.from(originalImage);

      // Prepare stamp text lines
      final now = DateTime.now();
      final dateStr = DateFormat(AppConstants.stampDateFormat).format(now);
      final timeStr = DateFormat(AppConstants.stampTimeFormat).format(now);
      final lines = <String>[];

      lines.add('$dateStr  $timeStr');

      if (showCoordinates) {
        lines.add(
          'Lat: ${location.latitude.toStringAsFixed(6)}  '
          'Lng: ${location.longitude.toStringAsFixed(6)}',
        );
      }

      if (showAddress && location.address != null) {
        // Wrap long addresses
        final address = location.address!;
        if (address.length > 50) {
          final mid = address.lastIndexOf(', ', address.length ~/ 2);
          if (mid > 0) {
            lines.add(address.substring(0, mid));
            lines.add(address.substring(mid + 2));
          } else {
            lines.add(address);
          }
        } else {
          lines.add(address);
        }
      }

      if (location.altitude != null) {
        lines.add('Alt: ${location.altitude!.toStringAsFixed(1)}m');
      }

      // Calculate font size relative to image dimensions
      final fontSize = (image.width * 0.028).clamp(14.0, 48.0).toInt();
      final lineHeight = (fontSize * 1.5).toInt();
      final padding = (image.width * 0.02).clamp(10.0, 40.0).toInt();

      // Draw semi-transparent background for stamp area
      final stampHeight = (lines.length * lineHeight) + (padding * 2);
      final stampY = image.height - stampHeight - padding;

      // Draw background rectangle
      for (int y = stampY; y < stampY + stampHeight && y < image.height; y++) {
        for (int x = padding; x < image.width - padding; x++) {
          if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
            final pixel = image.getPixel(x, y);
            final r = ((pixel.r * 0.4) + (0 * 0.6)).toInt();
            final g = ((pixel.g * 0.4) + (0 * 0.6)).toInt();
            final b = ((pixel.b * 0.4) + (0 * 0.6)).toInt();
            image.setPixelRgba(x, y, r, g, b, 200);
          }
        }
      }

      // Draw text lines
      final font = _getFontForSize(fontSize);
      for (int i = 0; i < lines.length; i++) {
        final textY = stampY + padding + (i * lineHeight);
        img.drawString(
          image,
          lines[i],
          font: font,
          x: padding + 10,
          y: textY,
          color: img.ColorRgba8(255, 255, 255, 230),
        );
      }

      // Encode as JPEG
      final encodedBytes = img.encodeJpg(image, quality: 92);

      // Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final timestamp = now.millisecondsSinceEpoch;
      final fileName = 'GPS_${dateStr}_$timestamp.jpg';
      final filePath = '${photosDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(encodedBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Save a photo without GPS stamp (original image).
  Future<String?> savePhotoOriginal(Uint8List imageBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd').format(now);
      final timestamp = now.millisecondsSinceEpoch;
      final fileName = 'IMG_${dateStr}_$timestamp.jpg';
      final filePath = '${photosDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Delete a photo file from disk.
  Future<bool> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get the photos directory path.
  Future<String> getPhotosDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/photos';
  }

  /// Get total size of all saved photos in bytes.
  Future<int> getPhotoStorageSize() async {
    try {
      final photosPath = await getPhotosDirectory();
      final photosDir = Directory(photosPath);
      if (!await photosDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in photosDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Select an appropriate font based on desired size.
  img.BitmapFont _getFontForSize(int fontSize) {
    if (fontSize >= 36) return img.arial48;
    if (fontSize >= 20) return img.arial24;
    return img.arial14;
  }

  /// Format file size in human-readable form.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// Provider
final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService();
});
