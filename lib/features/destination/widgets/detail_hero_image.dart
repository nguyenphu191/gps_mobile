import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';

class DetailHeroImage extends StatelessWidget {
  final DestinationModel dest;
  final double topPad;
  final String heroTag;
  const DetailHeroImage({
    super.key,
    required this.dest,
    required this.topPad,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag,
            child: ShimmerNetworkImage(
              imageUrl: dest.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
                colors: [Color(0x991D1737), Colors.transparent, Color(0xCC1D1737)],
              ),
            ),
          ),
          Positioned(
            top: topPad + 10,
            left: 0,
            right: 0,
            height: 44,
            child: Center(child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  color: Colors.white.withValues(alpha: 0.28),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        dest.continent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 44,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x991D1737),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pin_drop_rounded,
                      size: 16,
                      color: Aurora.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${dest.latitude.toStringAsFixed(4)}°, '
                        '${dest.longitude.toStringAsFixed(4)}°',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(
                          12,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
