import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class _CompressRequest {
  final Uint8List bytes;
  final int maxEdge;
  final int quality;

  const _CompressRequest({
    required this.bytes,
    required this.maxEdge,
    required this.quality,
  });
}

Uint8List? _compress(_CompressRequest request) {
  final decoded = img.decodeImage(request.bytes);
  if (decoded == null) return null;

  final longest = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  final resized = longest > request.maxEdge
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? request.maxEdge : null,
          height: decoded.height > decoded.width ? request.maxEdge : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  return img.encodeJpg(resized, quality: request.quality);
}

/// A downsized JPEG copy of [source] to upload, written under the temp dir.
///
/// Returns [source] unchanged when the image can't be compressed or the copy
/// would not be smaller — sharing must never fail because of this step.
Future<File> compressForUpload(
  File source, {
  required String id,
  int maxEdge = 1600,
  int quality = 80,
}) async {
  try {
    final bytes = await source.readAsBytes();
    final compressed = await compute(
      _compress,
      _CompressRequest(bytes: bytes, maxEdge: maxEdge, quality: quality),
    );
    if (compressed == null || compressed.length >= bytes.length) return source;

    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/upload_cache',
    );
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final out = File('${dir.path}/$id.jpg');
    await out.writeAsBytes(compressed);
    return out;
  } catch (e) {
    debugPrint('🔥 [MediaCompressor] falling back to the original file: $e');
    return source;
  }
}
