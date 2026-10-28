import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/features/home/widgets/home_top_bar.dart';
import 'package:gpscamerastamp/features/home/widgets/home_banner.dart';
import 'package:gpscamerastamp/features/home/widgets/home_section_header.dart';
import 'package:gpscamerastamp/features/home/widgets/category_chips.dart';
import 'package:gpscamerastamp/features/home/widgets/destination_carousel.dart';
import 'package:gpscamerastamp/features/home/widgets/home_quick_actions.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_motion_widgets.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/app_localizations.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  // The address is no longer shown on screen; the permission flow is kept for
  // the location analytics event and to prime the permission on first launch.
  bool _locationDenied = false;
  late final List<DestinationModel> _popularDestinations;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.homeView);
    _popularDestinations = popularDestinations;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _requestLocationAndFetch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _locationDenied) {
      _requestLocationAndFetch();
    }
  }

  Future<void> _requestLocationAndFetch() async {
    final permission = await Geolocator.checkPermission();
    LocationPermission resolved = permission;
    if (permission == LocationPermission.denied) {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      resolved = await Geolocator.requestPermission();
      Future.delayed(const Duration(milliseconds: 500), () {
        // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      });
    }
    final granted =
        resolved == LocationPermission.whileInUse ||
        resolved == LocationPermission.always;
    if (!granted) {
      if (mounted) setState(() => _locationDenied = true);
      return;
    }
    if (mounted) setState(() => _locationDenied = false);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final pm = placemarks.first;
        final parts = [
          pm.street,
          pm.subLocality,
          pm.locality,
        ].where((e) => e != null && e.isNotEmpty).toList();
        getIt<AnalyticsService>().logEvent(
          AnalyticsEvents.homeLocationUpdated,
          parameters: {'has_address': parts.isNotEmpty ? 'true' : 'false'},
        );
      }
    } catch (_) {
      // Nothing to show on screen; the analytics event simply does not fire.
    }
  }

  void _navigateWithoutAd(String route) {
    context.push(route);
  }

  void _handleViewAll(String route) {
    if (AdsEnvironment.showAds) {
      bool handled = false;
      EasyAds.instance.showInterstitialAd(
        context,
        adId: getIt<AdConfig>().interViewAll,
        adDissmissed: () {
          if (!handled) {
            handled = true;
            Navigator.of(context).pop();
            _navigateWithoutAd(route);
          }
        },
        onFailed: () {
          if (!handled) {
            handled = true;
            Navigator.of(context).pop();
            _navigateWithoutAd(route);
          }
        },
      );
    } else {
      _navigateWithoutAd(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 120, size: 300, color: Aurora.aqua),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
              FadeSlideIn.indexed(index: 0, child: const HomeTopBar()),

              // ── Hero banner ──────────────────────────────────────────
              FadeSlideIn.indexed(index: 1, dy: 24, child: const HomeBanner()),

              const SizedBox(height: 20),

              // ── Quick actions ────────────────────────────────────────
              FadeSlideIn.indexed(
                index: 2,
                child: const HomeQuickActions(),
              ),

              const SizedBox(height: 28),

              // ── Categories header ─────────────────────────────────────
              SectionHeader(
                title: t.locationNearby,
                onViewAll: () => _handleViewAll('/explore'),
              ),

              const SizedBox(height: 14),

              // ── Category chips (horizontal scroll) ────────────────────
              FadeSlideIn.indexed(
                index: 4,
                child: const CategoryChipList(),
              ),

              const SizedBox(height: 28),

              // ── Popular Destination ───────────────────────────────────
              SectionHeader(
                title: t.popularDestination,
                onViewAll: () => _handleViewAll('/all-destinations'),
              ),

              const SizedBox(height: 16),

              FadeSlideIn.indexed(
                index: 6,
                dy: 24,
                child: DestinationCarousel(destinations: _popularDestinations),
              ),

              const SizedBox(height: 24),

              // Ad sits below the designed content so the top of the screen
              // matches the design exactly.
              if (AdsEnvironment.showAds)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: EasyNativeAdWithFallback(
                    factoryId: MyAdIdName.nativeFull,
                    adId: getIt<AdConfig>().nativeHome,
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}
