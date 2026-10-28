import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';

List<_Category> buildExploreCategories(AppLocalizations t) => [
  _Category(
    t.petrolStation,
    Icons.local_gas_station_rounded,
    const Color(0xFFFF5416),
    const Color(0xFFFFF4E6),
    const Color(0xFFFFE2C2),
    'petrol station near me',
  ),
  _Category(
    t.hospital,
    Icons.local_hospital_rounded,
    const Color(0xFFB90A5A),
    const Color(0xFFFFEAEF),
    const Color(0xFFFFD3DC),
    'hospital near me',
  ),
  _Category(
    t.schoolLabel,
    Icons.school_rounded,
    const Color(0xFF0092B0),
    const Color(0xFFE6F7FF),
    const Color(0xFFBAE7FF),
    'school near me',
  ),
  _Category(
    t.restaurant,
    Icons.restaurant_rounded,
    const Color(0xFFFA6400),
    const Color(0xFFFFF0E6),
    const Color(0xFFFFD8BF),
    'restaurant near me',
  ),
  _Category(
    t.cafe,
    Icons.local_cafe_rounded,
    const Color(0xFF7A3D16),
    const Color(0xFFF9EFE7),
    const Color(0xFFEED9C7),
    'cafe near me',
  ),
  _Category(
    t.hotel,
    Icons.hotel_rounded,
    Aurora.primary,
    const Color(0xFFF0EDFF),
    const Color(0xFFDDD4FE),
    'hotel near me',
  ),
  _Category(
    t.supermarket,
    Icons.shopping_cart_rounded,
    const Color(0xFF009966),
    const Color(0xFFE6FBF2),
    const Color(0xFFC3F4DE),
    'supermarket near me',
  ),
  _Category(
    t.bank,
    Icons.account_balance_rounded,
    const Color(0xFF1867DC),
    const Color(0xFFEBF3FF),
    const Color(0xFFD1E4FF),
    'bank near me',
  ),
  _Category(
    t.police,
    Icons.local_police_rounded,
    const Color(0xFF3854E0),
    const Color(0xFFEEF2FF),
    const Color(0xFFD8E0FF),
    'police station near me',
  ),
  _Category(
    t.stadium,
    Icons.stadium_rounded,
    const Color(0xFFE82A86),
    const Color(0xFFFDF0F8),
    const Color(0xFFF9CFE8),
    'stadium near me',
  ),
];

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final Color tintEnd;
  final String query;

  const _Category(
    this.label,
    this.icon,
    this.color,
    this.tint,
    this.tintEnd,
    this.query,
  );
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  Future<void> _openGoogleMaps(String query) async {
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.exploreCategoryClick,
      parameters: {'category': query},
    );
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (_) {}

    final Uri url;
    if (position != null) {
      url = Uri.parse(
        'https://www.google.com/maps/search/$query/@${position.latitude},${position.longitude},15z',
      );
    } else {
      url = Uri.parse('https://www.google.com/maps/search/$query');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.exploreView);
    final t = AppLocalizations.of(context);
    final categories = buildExploreCategories(t);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.secondary),
          const AuroraBlob(top: 200, right: -96, size: 340, color: Aurora.primary),
          const AuroraBlob(bottom: -64, left: 60, size: 300, color: Aurora.aqua),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, media.padding.top + 12, 20, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: Aurora.cardShadow,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Aurora.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.exploreNearby,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(24, weight: FontWeight.w800),
                          ),
                          Text(
                            t.tapOpenMaps,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(13.5, color: Aurora.subText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: Aurora.cardShadow,
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        size: 20,
                        color: Aurora.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) => _CategoryCard(
                    cat: categories[index],
                    onTap: () => _openGoogleMaps(categories[index].query),
                  ),
                ),
              ),

              if (AdsEnvironment.showAds)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    media.padding.bottom + 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: EasyNativeAdWithFallback(
                      factoryId: MyAdIdName.nativeFull,
                      adId: getIt<AdConfig>().nativeExplore,
                      height: media.size.height * 0.3,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _Category cat;
  final VoidCallback onTap;

  const _CategoryCard({required this.cat, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cat.color.withValues(alpha: 0.14),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -36,
                bottom: -36,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cat.tintEnd.withValues(alpha: 0.6),
                        cat.tintEnd.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cat.tint, cat.tintEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(cat.icon, size: 28, color: cat.color),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cat.tint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.north_east_rounded,
                          size: 16,
                          color: cat.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    cat.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(17, weight: FontWeight.w800, height: 1.15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
