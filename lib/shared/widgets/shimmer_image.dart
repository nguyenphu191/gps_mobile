import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A CachedNetworkImage with a shimmer placeholder and broken-image fallback.
class ShimmerNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ShimmerNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _ShimmerBox(width: width, height: height),
      errorWidget: (_, __, ___) => _ErrorBox(width: width, height: height),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;

  const _ShimmerBox({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(width: width, height: height, color: Colors.white),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final double? width;
  final double? height;

  const _ErrorBox({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFCBD5E1),
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Color(0xFF94A3B8),
          size: 28,
        ),
      ),
    );
  }
}
