import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/map_media_item.dart';

class CloudinaryUploadResult {
  final String publicId;
  final String secureUrl;

  const CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
  });
}

/// Uploads media to Cloudinary with an *unsigned* preset, so no API secret
/// ever ships inside the app. Deleting an asset needs a signed request, so it
/// is deliberately not supported here — see [MediaShareService.deleteShared].
class CloudinaryClient {
  static const String _host = 'api.cloudinary.com';

  /// Uploads [file] and returns its hosted URL, or null when the caller should
  /// retry later (offline, rejected by the preset, misconfigured account).
  Future<CloudinaryUploadResult?> upload(
    File file, {
    required String publicId,
    required MediaKind kind,
    String? folder,
  }) async {
    if (AppConstants.cloudinaryCloudName.isEmpty ||
        AppConstants.cloudinaryUploadPreset.isEmpty) {
      debugPrint(
        '🔥 [Cloudinary] cloud name / upload preset is not configured',
      );
      return null;
    }

    final resourceType = kind == MediaKind.video ? 'video' : 'image';
    final uri = Uri.https(
      _host,
      '/v1_1/${AppConstants.cloudinaryCloudName}/$resourceType/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
        ..fields['folder'] = folder ?? AppConstants.cloudinaryFolder
        // Same id as the local media, so a retry overwrites the asset instead
        // of piling up duplicates.
        ..fields['public_id'] = publicId
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        debugPrint(
          '🔥 [Cloudinary] upload failed (${response.statusCode}): ${response.body}',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;

      final secureUrl = decoded['secure_url'] as String?;
      final returnedId = decoded['public_id'] as String?;
      if (secureUrl == null || returnedId == null) return null;

      return CloudinaryUploadResult(publicId: returnedId, secureUrl: secureUrl);
    } catch (e) {
      debugPrint('🔥 [Cloudinary] upload error: $e');
      return null;
    }
  }

  /// Delete one asset. Cloudinary requires a request signed with the account
  /// api_secret, so this goes through the Worker rather than straight to
  /// Cloudinary — the secret must never ship inside the app.
  ///
  /// Returns false when the asset may still be there (not configured, offline,
  /// rejected); the caller decides what to do about it.
  Future<bool> destroy({
    required String publicId,
    required MediaKind kind,
  }) async {
    if (AppConstants.mediaDeleteEndpoint.isEmpty) {
      debugPrint(
        '🔥 [Cloudinary] delete endpoint not configured, keeping asset',
      );
      return false;
    }

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return false;

      final response = await http
          .post(
            Uri.parse(AppConstants.mediaDeleteEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'publicId': publicId,
              'resourceType': kind == MediaKind.video ? 'video' : 'image',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint(
          '🔥 [Cloudinary] delete failed (${response.statusCode}): ${response.body}',
        );
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('🔥 [Cloudinary] delete error: $e');
      return false;
    }
  }

  /// A resized variant of a Cloudinary URL — used for map markers, which would
  /// otherwise download the full-size image for a 44px thumbnail.
  static String thumbnailUrl(String secureUrl, {int width = 200}) {
    const marker = '/upload/';
    final index = secureUrl.indexOf(marker);
    if (index < 0) return secureUrl;
    return secureUrl.replaceFirst(
      marker,
      '/upload/w_$width,c_fill,q_auto,f_auto/',
    );
  }
}
