import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/map_media_item.dart';
import '../../sharing/services/cloudinary_client.dart';
import '../../sharing/services/media_compressor.dart';
import 'auth_service.dart';

enum AvatarUploadResult { success, cancelled, failed }

/// Picks a profile picture, uploads it to Cloudinary and points the user's
/// Firestore profile at the new URL.
class AvatarService {
  final AuthService _authService;
  final CloudinaryClient _cloudinary = CloudinaryClient();

  AvatarService(this._authService);

  Future<AvatarUploadResult> pickAndUpload(String uid) async {
    File? compressed;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (picked == null) return AvatarUploadResult.cancelled;

      // Avatars are never shown larger than ~100px, so 512 is generous.
      compressed = await compressForUpload(
        File(picked.path),
        id: 'avatar_$uid',
        maxEdge: 512,
        quality: 85,
      );

      final result = await _cloudinary.upload(
        compressed,
        // Fixed id per user: changing the avatar overwrites the old asset
        // instead of leaving one behind on every change.
        publicId: uid,
        kind: MediaKind.photo,
        folder: AppConstants.cloudinaryAvatarFolder,
      );
      if (result == null) return AvatarUploadResult.failed;

      await _authService.updatePhotoUrl(uid, result.secureUrl);
      return AvatarUploadResult.success;
    } catch (e) {
      debugPrint('🔥 [Avatar] upload failed: $e');
      return AvatarUploadResult.failed;
    } finally {
      if (compressed != null && compressed.path.contains('upload_cache')) {
        try {
          await compressed.delete();
        } catch (_) {
          // Temp file, reclaimed with the cache directory.
        }
      }
    }
  }
}

final avatarServiceProvider = Provider<AvatarService>(
  (ref) => AvatarService(ref.watch(authServiceProvider)),
);
