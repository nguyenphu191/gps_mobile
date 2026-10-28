import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/features/destination/widgets/destination_list_item.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';

export 'package:gpscamerastamp/features/destination/widgets/destination_detail_page.dart'
    show DestinationDetailPage;

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';

// Region tab definition
class _Region {
  final String emoji;
  final List<String> continents;
  const _Region(this.emoji, this.continents);
}

const _regions = [
  _Region('🌍', []),
  _Region('🌏', ['East Asia', 'Southeast Asia', 'South Asia', 'West Asia']),
  _Region('🏰', ['Europe']),
  _Region('🗽', ['North America', 'South America']),
  _Region('🦁', ['Africa']),
  _Region('🦘', ['Oceania']),
];

class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.destinationView);
    _tabController = TabController(length: _regions.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DestinationModel> _filteredFor(_Region region) {
    if (region.continents.isEmpty) return allDestinations;
    return allDestinations
        .where((d) => region.continents.contains(d.continent))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final regionLabels = [
      t.regionAll,
      t.regionAsia,
      t.regionEurope,
      t.regionAmericas,
      t.regionAfrica,
      t.regionOceania,
    ];
    final count = _filteredFor(_regions[_tabController.index]).length;

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: 60, left: 20, size: 260, color: Aurora.aqua),
          Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20, media.padding.top + 12, 20, 8),
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
                            t.popularDestinations,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(22, weight: FontWeight.w800),
                          ),
                          Text(
                            t.placesToExplore(count),
                            style: Aurora.text(13.5, color: Aurora.subText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Region chips ───────────────────────────────────────
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: _regions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final selected = _tabController.index == i;
                    return GestureDetector(
                      onTap: () => _tabController.animateTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: selected ? Aurora.primaryGradient : null,
                          color: selected
                              ? null
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Aurora.primary.withValues(
                                alpha: selected ? 0.35 : 0.08,
                              ),
                              blurRadius: selected ? 16 : 8,
                              offset: Offset(0, selected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _regions[i].emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              regionLabels[i],
                              style: Aurora.text(
                                13,
                                weight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF4A4455),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Tab content ────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _regions.map((region) {
                    final list = _filteredFor(region);
                    if (list.isEmpty) return _empty(t);
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          DestinationListItem(dest: list[index]),
                    );
                  }).toList(),
                ),
              ),

              if (AdsEnvironment.showAds)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, media.padding.bottom + 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: EasyNativeAdWithFallback(
                      factoryId: MyAdIdName.nativeFull,
                      adId: getIt<AdConfig>().nativeDestination,
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

  Widget _empty(AppLocalizations t) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          boxShadow: Aurora.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF1EBFF), Color(0xFFE6DEFF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: const Icon(
                Icons.explore_off_rounded,
                size: 38,
                color: Aurora.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.noDestinations,
              textAlign: TextAlign.center,
              style: Aurora.text(18, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
