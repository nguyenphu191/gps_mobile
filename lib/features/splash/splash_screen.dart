import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';
import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';
import '../../utils/initialization_helper.dart';
import '../../ads/const/ad_config.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/nativefull/native_full_screen.dart';
import '../../core/localization/app_localizations.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import 'widgets/splash_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  /// How long the progress bar takes to fill. Matches the minimum wait in
  /// [_navigateAfterDelay] — initialisation reports no progress of its own, so
  /// the bar is timed rather than driven by real work.
  static const Duration _minimumWait = Duration(milliseconds: 2500);

  late final AnimationController _introCtrl;
  late final AnimationController _loopCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<double> _progress;
  final int _entryTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.splashView);

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressCtrl = AnimationController(vsync: this, duration: _minimumWait)
      ..forward();
    _progress = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOutCubic,
    );

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    final helper = InitializationHelper(navigatorKey: rootNavigatorKey);
    await Future.wait([helper.initialize(), Future.delayed(_minimumWait)]);

    if (!mounted) return;
    final timeToAction = DateTime.now().millisecondsSinceEpoch - _entryTime;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.splashComplete,
      parameters: {'time_to_action': timeToAction},
    );

    void proceedToNextScreen() {
      // Language + intro are shown on every launch; the intro decides whether
      // the signed-in user goes straight to /home or has to sign in.
      final currentContext = rootNavigatorKey.currentContext;
      if (currentContext == null) return;
      currentContext.go('/language');
    }

    if (AdsEnvironment.showAds) {
      void goToNativeFull() {
        // Temporarily bypassed native full ads splash
        proceedToNextScreen();
        /*
        final currentContext = rootNavigatorKey.currentContext;
        if (currentContext == null) return;
        Navigator.of(currentContext).push(
          MaterialPageRoute(
            builder: (context) => NativeFullScreen(
              nativeFullId: getIt<AdConfig>().nativeFullSplash,
              handleNavigate: proceedToNextScreen,
            ),
          ),
        );
        */
      }

      EasyAds.instance.showAppOpenAdWithId(
        context,
        adId: getIt<AdConfig>().openSplash,
        adDissmissed: goToNativeFull,
        onFailed: goToNativeFull,
      );
    } else {
      proceedToNextScreen();
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _loopCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  /// Fade + rise, driven by a slice of the intro timeline.
  Widget _reveal(double begin, double end, double dy, Widget child) {
    final curve = CurvedAnimation(
      parent: _introCtrl,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curve.value) * dy),
          child: child,
        ),
      ),
      child: child,
    );
  }

  /// A blob that drifts slowly so the backdrop feels alive.
  Widget _driftingBlob({
    required double phase,
    required AuroraBlob blob,
  }) {
    // AuroraBlob is itself Positioned, so it needs its own Stack to live in
    // once wrapped by the transform.
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _loopCtrl,
          builder: (context, child) {
            final a = _loopCtrl.value * 2 * math.pi + phase;
            return Transform.translate(
              offset: Offset(math.sin(a) * 14, math.cos(a) * 14),
              child: child,
            );
          },
          child: Stack(children: [blob]),
        ),
      ),
    );
  }

  Widget _title(AppLocalizations t) {
    final name = t.appName;
    final style = Aurora.text(26, weight: FontWeight.w800, height: 1.15);
    final hasGps = name.startsWith('GPS');
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: style,
        children: [
          if (hasGps) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => Aurora.primaryGradient.createShader(b),
                child: Text('GPS', style: style.copyWith(color: Colors.white)),
              ),
            ),
            TextSpan(text: name.substring(3)),
          ] else
            TextSpan(text: name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F1FF), Color(0xFFECE4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _driftingBlob(
              phase: 0,
              blob: const AuroraBlob(
                top: -64,
                left: -64,
                size: 288,
                color: Aurora.primary,
              ),
            ),
            _driftingBlob(
              phase: 2.1,
              blob: const AuroraBlob(
                bottom: -64,
                right: -64,
                size: 320,
                color: Aurora.secondary,
              ),
            ),
            _driftingBlob(
              phase: 4.2,
              blob: const AuroraBlob(
                top: 320,
                left: 90,
                size: 200,
                color: Aurora.aqua,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SplashLogoStack(intro: _introCtrl, loop: _loopCtrl),
                          const SizedBox(height: 4),
                          _reveal(0.4, 0.8, 16, _title(t)),
                          const SizedBox(height: 8),
                          _reveal(
                            0.55,
                            0.95,
                            16,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                              ),
                              child: Text(
                                t.introSlide1Desc,
                                textAlign: TextAlign.center,
                                style: Aurora.text(
                                  14,
                                  color: Aurora.subText,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _reveal(
                    0.7,
                    1.0,
                    24,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) => Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Text(
                                    '${(_progress.value * 100).round()}%',
                                    style: Aurora.text(
                                      12,
                                      weight: FontWeight.w800,
                                      color: Aurora.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _progressBar(_progress.value),
                              ],
                            ),
                          ),
                          if (AdsEnvironment.showAds) ...[
                            const SizedBox(height: 14),
                            Text(
                              t.splashAdsNotice,
                              textAlign: TextAlign.center,
                              style: Aurora.text(11, color: Aurora.hint),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(double value) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth * value;
        return Container(
          height: 8,
          width: double.infinity,
          padding: const EdgeInsets.all(1),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: const Color(0xFFE6DEFF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: w,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Aurora.primary, Color(0xFFFE4C8C)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (value > 0.02)
                PositionedDirectional(
                  start: (w - 6).clamp(0.0, c.maxWidth),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.secondary.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
