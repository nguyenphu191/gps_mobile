import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/aurora.dart';

/// The Aurora app mark on the splash screen: a gradient tile with a camera
/// lens and a GPS pin, ringed by expanding "ping" waves and floating sparkles.
///
/// [intro] runs once (0→1) and drives the entrance; [loop] repeats forever and
/// drives everything that idles (float, breathing, ripples, shimmer).
class SplashLogoStack extends StatelessWidget {
  final double size;
  final Animation<double> intro;
  final Animation<double> loop;

  const SplashLogoStack({
    super.key,
    this.size = 128,
    required this.intro,
    required this.loop,
  });

  double _stage(double begin, double end, Curve curve) =>
      curve.transform(((intro.value - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final canvas = size * 1.75;
    return RepaintBoundary(
      child: SizedBox(
        width: canvas,
        height: canvas,
        child: AnimatedBuilder(
          animation: Listenable.merge([intro, loop]),
          builder: (context, _) {
            final wave = math.sin(loop.value * 2 * math.pi);
            final logoIn = _stage(0, 0.55, Curves.elasticOut);
            final fadeIn = _stage(0, 0.35, Curves.easeOut);
            final floatY = wave * 4;
            final breathe = 1 + math.sin(loop.value * 2 * math.pi + 1) * 0.015;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Sonar rings, two half a cycle apart.
                for (final offset in const [0.0, 0.5]) _ring(offset, fadeIn),

                // Sparkles
                _sparkle(
                  index: 0,
                  alignment: const Alignment(0.62, -0.62),
                  phase: 0,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 28,
                    color: Color(0xFF2FD9F4),
                    shadows: [Shadow(color: Color(0x552FD9F4), blurRadius: 10)],
                  ),
                ),
                _sparkle(
                  index: 1,
                  alignment: const Alignment(-0.6, 0.62),
                  phase: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFE4C8C).withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(
                      Icons.pin_drop_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                _sparkle(
                  index: 2,
                  alignment: const Alignment(-0.68, -0.38),
                  phase: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // The tile itself
                Opacity(
                  opacity: fadeIn,
                  child: Transform.translate(
                    offset: Offset(0, floatY),
                    child: Transform.rotate(
                      angle: (1 - logoIn) * -0.105,
                      child: Transform.scale(
                        scale: (0.6 + 0.4 * logoIn) * breathe,
                        child: _tile(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double offset, double fadeIn) {
    final p = (loop.value + offset) % 1.0;
    final scale = 1 + p * 0.75;
    final alpha = (1 - p) * 0.35 * fadeIn;
    return Container(
      width: size * scale,
      height: size * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28 * scale),
        border: Border.all(
          color: Aurora.primary.withValues(alpha: alpha),
          width: 2,
        ),
      ),
    );
  }

  Widget _sparkle({
    required int index,
    required Alignment alignment,
    required double phase,
    required Widget child,
  }) {
    final begin = 0.35 + index * 0.1;
    final pop = _stage(begin, begin + 0.3, Curves.easeOutBack);
    final bob = math.sin(loop.value * 2 * math.pi + phase) * 4;
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Transform.scale(
          scale: pop.clamp(0.0, 1.3),
          child: Opacity(opacity: pop.clamp(0.0, 1.0), child: child),
        ),
      ),
    );
  }

  Widget _tile() {
    // Glare sweep travels across the tile during part of each loop.
    final sweepT = ((loop.value - 0.55) / 0.3).clamp(0.0, 1.0);
    final sweepX = -size * 0.6 + sweepT * size * 1.8;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [Aurora.primary, Color(0xFFFE4C8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -size * 0.15,
                left: -size * 0.15,
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: size * 0.62,
                height: size * 0.62,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _lens(),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: size * 0.19,
                        height: size * 0.19,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x33000000), blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: size * 0.12,
                          color: Aurora.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -size * 0.01,
                      left: size * 0.06,
                      child: Container(
                        width: size * 0.12,
                        height: size * 0.045,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Glare sweep
              Positioned(
                left: sweepX,
                top: -size * 0.2,
                bottom: -size * 0.2,
                child: Transform.rotate(
                  angle: 0.35,
                  child: Container(
                    width: size * 0.18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lens() {
    final ring = size * 0.5;
    final core = size * 0.375;
    final glass = size * 0.22;
    return Container(
      width: ring,
      height: ring,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: core,
        height: core,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: glass,
              height: glass,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF630ED4), Color(0xFFFE4C8C)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: glass * 0.36,
                  height: glass * 0.36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              top: core * 0.12,
              right: core * 0.17,
              child: Container(
                width: core * 0.16,
                height: core * 0.16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
