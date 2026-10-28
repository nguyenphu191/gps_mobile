import 'dart:math' as math;

import 'package:flutter/material.dart';

// ── Compass widget ─────────────────────────────────────────────────────────────

class CompassWidget extends StatelessWidget {
  final double heading;
  final double arrowAngle;
  final bool hasLocation;

  const CompassWidget({
    super.key,
    required this.heading,
    required this.arrowAngle,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring rotates with device heading
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: CustomPaint(
              size: const Size(230, 230),
              painter: CompassRingPainter(),
            ),
          ),

          // Inner circle
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.72),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),

          // Direction arrow
          if (hasLocation)
            Transform.rotate(
              angle: arrowAngle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: const Size(20, 58),
                    painter: ArrowPainter(up: true),
                  ),
                  const SizedBox(height: 2),
                  CustomPaint(
                    size: const Size(20, 32),
                    painter: ArrowPainter(up: false),
                  ),
                ],
              ),
            )
          else
            const Icon(Icons.explore_rounded, color: Colors.white38, size: 36),

          // Heading degrees
          Positioned(
            bottom: 22,
            child: Text(
              '${heading.round() % 360}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ring painter ───────────────────────────────────────────────────────────────

class CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Tick marks
    for (int i = 0; i < 72; i++) {
      final deg = i * 5;
      final angle = deg * math.pi / 180 - math.pi / 2;
      final isMajor = deg % 45 == 0;
      final isMid = deg % 15 == 0;

      final outerR = radius - 8;
      final innerR = isMajor
          ? radius - 28
          : isMid
          ? radius - 20
          : radius - 14;

      canvas.drawLine(
        Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle),
        ),
        Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle),
        ),
        Paint()
          ..color = isMajor
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = isMajor ? 2.0 : 1.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Degree numbers every 30°
    for (int i = 0; i < 12; i++) {
      final deg = i * 30;
      final angle = deg * math.pi / 180 - math.pi / 2;
      final labelR = radius - 44;
      final x = center.dx + labelR * math.cos(angle);
      final y = center.dy + labelR * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: '$deg',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // N / E / S / W labels
    final cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    for (final entry in cardinals.entries) {
      final angle = entry.value * math.pi / 180 - math.pi / 2;
      final labelR = radius - 62;
      final x = center.dx + labelR * math.cos(angle);
      final y = center.dy + labelR * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: entry.key == 'N'
                ? const Color(0xFFFF4444)
                : Colors.white.withValues(alpha: 0.9),
            fontSize: entry.key == 'N' || entry.key == 'S' ? 15 : 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Arrow painter ──────────────────────────────────────────────────────────────

class ArrowPainter extends CustomPainter {
  final bool up;
  const ArrowPainter({required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = up ? const Color(0xFFFF4444) : Colors.white30
      ..style = PaintingStyle.fill;

    final path = Path();
    if (up) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, size.height * 0.75);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width * 0.75, 0);
      path.lineTo(size.width / 2, size.height * 0.25);
      path.lineTo(size.width * 0.25, 0);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
