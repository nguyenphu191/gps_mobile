import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurora.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradientText = Aurora.text(
      14,
      weight: FontWeight.w800,
      color: Colors.white,
    );

    return GestureDetector(
      onTap: () => context.push(AppRoutes.camera),
      // The whole card is the target, not just the label.
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 190),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Aurora.primary, Color(0xFF630ED4), Color(0xFFFE4C8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.38),
              blurRadius: 36,
              spreadRadius: -6,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -48,
              right: -48,
              child: _glow(176, Colors.white.withValues(alpha: 0.22)),
            ),
            Positioned(
              bottom: -40,
              right: 40,
              child: _glow(144, Aurora.secondary.withValues(alpha: 0.35)),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _float,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, (_float.value - 0.5) * 8),
                  child: child,
                ),
                child: const Center(child: _BannerArt()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.captureEveryJourney,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(
                          22,
                          weight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.gpsStampedPhotos,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(
                          13.5,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (b) =>
                              Aurora.primaryGradient.createShader(b),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_camera_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.captureNow,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: gradientText,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _glow(double size, Color color) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}

class _BannerArt extends StatelessWidget {
  const _BannerArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 56,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x4D000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF2FD9F4),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x33000000), blurRadius: 10),
                ],
              ),
              child: const Icon(
                Icons.near_me_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
