import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class HeroSection extends StatelessWidget {
  final DestinationModel dest;
  final double topPad;
  const HeroSection({super.key, required this.dest, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShimmerNetworkImage(imageUrl: dest.imageUrl, fit: BoxFit.cover),
          // Deep gradient at bottom
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.45, 1.0],
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
          // Continent badge top-right
          Positioned(
            top: topPad + 14,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  color: Colors.white.withValues(alpha: 0.22),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blur button (back button)
// ─────────────────────────────────────────────────────────────────────────────
class BlurButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const BlurButton({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 40,
            height: 40,
            color: Colors.black.withValues(alpha: 0.28),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
