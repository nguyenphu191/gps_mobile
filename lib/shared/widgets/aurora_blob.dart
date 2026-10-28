import 'package:flutter/material.dart';

/// Soft radial glow used as ambient background decoration.
class AuroraBlob extends StatelessWidget {
  final double? top, left, right, bottom;
  final double size;
  final Color color;

  const AuroraBlob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
