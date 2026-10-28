import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<String> generateStampedImage(
  String originalPath,
  double latitude,
  double longitude,
  String address,
  DateTime dateTime,
) async {
  final bytes = await File(originalPath).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final srcImage = frame.image;

  final w = srcImage.width.toDouble();
  final h = srcImage.height.toDouble();

  final fontSize = (w * 0.022).clamp(18.0, 36.0);
  final padH = fontSize * 0.8;
  final padV = fontSize * 0.6;
  final lineGap = fontSize * 0.35;

  final dateStr = DateFormat('yyyy-MM-dd  HH:mm:ss').format(dateTime);
  final coordStr =
      'Lat: ${latitude.toStringAsFixed(5)}   Lon: ${longitude.toStringAsFixed(5)}';
  final addrStr = address.length > 52
      ? '${address.substring(0, 49)}...'
      : address;
  final lines = [dateStr, coordStr, addrStr];

  final lineH = fontSize + lineGap;
  final blockH = padV * 2 + lineH * lines.length;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

  canvas.drawImage(srcImage, Offset.zero, Paint());
  canvas.drawRect(
    Rect.fromLTWH(0, h - blockH, w, blockH),
    Paint()..color = const Color(0xBB000000),
  );

  for (var i = 0; i < lines.length; i++) {
    final tp = TextPainter(
      text: TextSpan(
        text: lines[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: w - padH * 2);
    tp.paint(canvas, Offset(padH, h - blockH + padV + i * lineH));
  }

  final picture = recorder.endRecording();
  final outImage = await picture.toImage(srcImage.width, srcImage.height);
  final rgba = await outImage.toByteData(format: ui.ImageByteFormat.rawRgba);

  // Encode as JPEG rather than PNG: same picture to the eye, roughly a fifth
  // of the bytes on disk (and of the upload).
  final jpg = await compute(
    _encodeJpg,
    _RawFrame(
      bytes: rgba!.buffer.asUint8List(),
      width: outImage.width,
      height: outImage.height,
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final stampedPath =
      '${dir.path}/gps_photo_${dateTime.millisecondsSinceEpoch}.jpg';
  await File(stampedPath).writeAsBytes(jpg);

  return stampedPath;
}

class _RawFrame {
  final Uint8List bytes;
  final int width;
  final int height;

  const _RawFrame({
    required this.bytes,
    required this.width,
    required this.height,
  });
}

/// Runs on a background isolate — encoding a full-resolution frame on the UI
/// thread drops frames.
Uint8List _encodeJpg(_RawFrame frame) {
  final image = img.Image.fromBytes(
    width: frame.width,
    height: frame.height,
    bytes: frame.bytes.buffer,
    numChannels: 4,
  );
  return img.encodeJpg(image, quality: 92);
}
