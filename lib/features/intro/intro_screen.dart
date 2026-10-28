import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';
import '../../shared/widgets/aurora_button.dart';

class _SlideData {
  final String image;
  final String title;
  final String description;
  final List<String> chips;

  const _SlideData({
    required this.image,
    required this.chips,
    required this.title,
    required this.description,
  });
}

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);
  final _pageController = PageController();
  int _currentPage = 0;
  final int _entryTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.introView);
  }

  Future<void> _onComplete() async {
    final timeToAction = DateTime.now().millisecondsSinceEpoch - _entryTime;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.introComplete,
      parameters: {'time_to_action': timeToAction},
    );
    await ref.read(storageServiceProvider).setFirstLaunchComplete();

    // Firebase persists the session, so an already signed-in user skips login.
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Give Firebase a moment to restore the session (hot restart / cold start).
      try {
        user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(milliseconds: 1500));
      } catch (_) {
        user = FirebaseAuth.instance.currentUser;
      }
    }

    if (!mounted) return;
    context.go(user != null ? '/home' : '/auth');
  }

  List<_SlideData> _buildSlides(AppLocalizations t) {
    return [
      _SlideData(
        image: 'assets/images/intro1.png',
        chips: const ['📍', '🕒', '🧭'],
        title: t.introSlide1Title,
        description: t.introSlide1Desc,
      ),
      _SlideData(
        image: 'assets/images/intro2.png',
        chips: const ['🗺', '📸', '✨'],
        title: t.introSlide2Title,
        description: t.introSlide2Desc,
      ),
      _SlideData(
        image: 'assets/images/intro3.png',
        chips: const ['👥', '📡', '💜'],
        title: t.introSlide3Title,
        description: t.introSlide3Desc,
      ),
      _SlideData(
        image: 'assets/images/intro4.png',
        chips: const ['🚦', '🧭', '⚡'],
        title: t.introSlide4Title,
        description: t.introSlide4Desc,
      ),
    ];
  }

  @override
  void dispose() {
    _float.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final slides = _buildSlides(t);
    final isLast = _currentPage == slides.length - 1;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCFAFF), Aurora.bgSoftEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const AuroraBlob(top: -96, left: 40, size: 320, color: Aurora.primary),
            const AuroraBlob(top: 260, right: -80, size: 256, color: Aurora.secondary),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: isLast
                          ? null
                          : TextButton(
                              onPressed: _onComplete,
                              child: Text(
                                t.skip,
                                style: Aurora.text(
                                  13,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFF8E87A5),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        getIt<AnalyticsService>().logEvent(
                          AnalyticsEvents.introSlideView,
                          parameters: {'slide_index': index},
                        );
                      },
                      itemBuilder: (context, index) => _slide(slides[index]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dots(slides.length),
                  if (AdsEnvironment.showAds) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: screenH * 0.22,
                          child: IndexedStack(
                            index: _currentPage,
                            children: [
                              for (final id in [
                                getIt<AdConfig>().nativeIntro1,
                                getIt<AdConfig>().nativeIntro2,
                                getIt<AdConfig>().nativeIntro3,
                                getIt<AdConfig>().nativeIntro4,
                              ])
                                EasyNativeAdWithFallback(
                                  factoryId: MyAdIdName.nativeFull,
                                  adId: id,
                                  height: screenH * 0.22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: AuroraButton(
                      label: isLast ? t.getStarted : t.continueText,
                      trailingIcon: Icons.east_rounded,
                      onTap: () {
                        if (isLast) {
                          _onComplete();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
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

  Widget _slide(_SlideData slide) {
    return Column(
      children: [
        // Fixed height so titles line up across slides.
        SizedBox(
          height: 124,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(25, weight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(13.5, color: Aurora.subText, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 310,
                height: 340,
                child: _hero(slide),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(_SlideData slide) {
    Widget chip(String emoji, {required Alignment at, required double phase}) {
      return Align(
        alignment: at,
        child: AnimatedBuilder(
          animation: _float,
          builder: (_, child) => Transform.translate(
            offset: Offset(
              0,
              (phase == 0 ? _float.value : 1 - _float.value) * 8 - 4,
            ),
            child: child,
          ),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Aurora.darkText.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: -0.026,
          child: Container(
            width: 230,
            height: 320,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.28),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                slide.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        chip(slide.chips[0], at: const Alignment(-1, -0.85), phase: 0),
        chip(slide.chips[1], at: const Alignment(1, -0.45), phase: 1),
        chip(slide.chips[2], at: const Alignment(0.95, 0.85), phase: 0),
      ],
    );
  }

  Widget _dots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active ? Aurora.primaryGradient : null,
            color: active ? null : const Color(0xFFE5DCFB),
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Aurora.secondary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
