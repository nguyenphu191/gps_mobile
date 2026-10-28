import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gpscamerastamp/core/router/app_router.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/features/auth/models/user_model.dart';
import 'package:gpscamerastamp/features/auth/services/auth_service.dart';
import 'package:gpscamerastamp/features/friends/providers/friend_profiles_provider.dart';
import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/widgets/app_bottom_nav.dart';
import 'widgets/media_grid_item.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_motion_widgets.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../map_gallery/map_gallery_screen.dart';
import '../video_camera/models/video_model.dart';
import '../sharing/shared_media_viewer.dart';
import '../map_gallery/providers/map_media_provider.dart';
import '../video_camera/video_gallery_screen.dart';
import '../../shared/providers/gallery_provider.dart';
import '../video_camera/providers/video_gallery_provider.dart';

enum _SortOption { latest, oldest }

enum _MediaFilter { all, photo, video }

enum _OwnerFilter { all, mine }

/// One value type for the sort menu, which now carries two independent
/// settings: how the grid is ordered, and whose media it shows.
enum _MenuChoice { latest, oldest, ownerAll, ownerMine }

/// The Gallery tab: the user's own photos and videos plus everything friends
/// have shared, in one grid, with a map view of the same items one tap away.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  _SortOption _sortOption = _SortOption.latest;
  _MediaFilter _filter = _MediaFilter.all;
  _OwnerFilter _owner = _OwnerFilter.all;
  bool _showMap = false;
  int _displayCount = 30;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.galleryView);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() => _displayCount += 30);
    }
  }

  /// Own media plus whatever friends have shared, narrowed by the two
  /// filters: owner (from the menu) and kind (from the chips).
  List<MapMediaItem> _visibleItems(List<MapMediaItem> all) {
    final items = all.where((item) {
      if (_owner == _OwnerFilter.mine && !item.isMine) return false;
      return switch (_filter) {
        _MediaFilter.all => true,
        _MediaFilter.photo => !item.isVideo,
        _MediaFilter.video => item.isVideo,
      };
    }).toList();

    items.sort(
      (a, b) => _sortOption == _SortOption.latest
          ? b.timestamp.compareTo(a.timestamp)
          : a.timestamp.compareTo(b.timestamp),
    );
    return items;
  }

  /// Avatar and name to show on a tile.
  ///
  /// The copies stored on the media document were taken when it was uploaded,
  /// so they miss every later profile change. The live profile streams win;
  /// the stored copy is only the fallback while they load.
  ({String? photoUrl, String name}) _ownerOf(
    MapMediaItem item,
    UserModel? me,
    Map<String, UserModel> friendProfiles,
  ) {
    if (item.isMine) {
      return (
        photoUrl: me?.photoUrl,
        name: (me?.username.isNotEmpty ?? false)
            ? me!.username
            : (me?.displayName ?? ''),
      );
    }

    final profile = friendProfiles[item.ownerUid];
    if (profile != null) {
      return (
        photoUrl: profile.photoUrl,
        name: profile.username.isNotEmpty
            ? profile.username
            : profile.displayName,
      );
    }
    return (photoUrl: item.ownerPhotoUrl, name: item.ownerName ?? '');
  }

  void _openItem(MapMediaItem item) {
    // A friend's media has no local file and no entry in the local galleries,
    // so it gets its own viewer — the same one the map's bottom sheet uses.
    if (!item.isMine) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SharedMediaViewer(item: item)));
      return;
    }

    if (item.isVideo) {
      // Rebuild the model the detail screen expects instead of looking it up
      // by id: a lookup miss used to leave the tap doing nothing at all.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoDetailScreen(
            video: VideoModel(
              id: item.id,
              videoPath: item.localPath ?? '',
              latitude: item.latitude,
              longitude: item.longitude,
              timestamp: item.timestamp,
              address: item.address ?? '',
            ),
          ),
        ),
      );
      return;
    }

    context.push('/photo-detail/${item.id}');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = _visibleItems(ref.watch(mapMediaProvider));
    final displayed = items.take(_displayCount).toList();
    // Watched here so the whole grid rebuilds once when a profile changes,
    // instead of every tile subscribing on its own.
    final me = ref.watch(currentUserProvider).valueOrNull;
    final friendProfiles =
        ref.watch(friendProfilesProvider).valueOrNull ??
        const <String, UserModel>{};

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 120, size: 300, color: Aurora.aqua),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(t),
                if (!_showMap) _filterRow(t, items.length),
                if (ref.watch(friendsMediaProvider).hasError)
                  _friendMediaError(t),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.97, end: 1).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_showMap),
                      child: _showMap
                          ? const MapGalleryScreen(embedded: true)
                          : _grid(t, items, displayed, me, friendProfiles),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when the friends' media query fails. Without it a rules rejection
  /// is indistinguishable from "nobody has shared anything".
  Widget _friendMediaError(AppLocalizations t) {
    const red = Color(0xFFBA1A1A);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0x99FFDAD6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 17, color: red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.friendMediaLoadError,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Aurora.text(12, weight: FontWeight.w700, color: red),
            ),
          ),
          GestureDetector(
            onTap: () => ref.invalidate(friendsMediaProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 14, color: red),
                  const SizedBox(width: 4),
                  Text(
                    t.retry.toUpperCase(),
                    style: Aurora.text(10, weight: FontWeight.w800, color: red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(t.gallery, style: Aurora.text(24, weight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Aurora.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _showMap = !_showMap),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: Aurora.primaryGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Aurora.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showMap ? Icons.grid_view_rounded : Icons.map_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showMap ? t.showGrid : t.showOnMap,
                    style: Aurora.text(
                      13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow(AppLocalizations t, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(t.filterAll, _MediaFilter.all),
                  const SizedBox(width: 8),
                  _chip(t.filterPhotos, _MediaFilter.photo),
                  const SizedBox(width: 8),
                  _chip(t.filterVideos, _MediaFilter.video),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pin_drop_rounded,
                          size: 15,
                          color: Aurora.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: Aurora.text(
                            12,
                            weight: FontWeight.w800,
                            color: Aurora.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<_MenuChoice>(
            onSelected: _onMenuSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Aurora.darkText.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                size: 20,
                color: Aurora.darkText,
              ),
            ),
            itemBuilder: (_) => [
              _menuItem(
                _MenuChoice.latest,
                t.latestFirst,
                _sortOption == _SortOption.latest,
              ),
              _menuItem(
                _MenuChoice.oldest,
                t.oldestFirst,
                _sortOption == _SortOption.oldest,
              ),
              const PopupMenuDivider(),
              _menuItem(
                _MenuChoice.ownerAll,
                t.filterAll,
                _owner == _OwnerFilter.all,
              ),
              _menuItem(
                _MenuChoice.ownerMine,
                t.myGallery,
                _owner == _OwnerFilter.mine,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(_MenuChoice choice) {
    setState(() {
      switch (choice) {
        case _MenuChoice.latest:
          _sortOption = _SortOption.latest;
        case _MenuChoice.oldest:
          _sortOption = _SortOption.oldest;
        case _MenuChoice.ownerAll:
          _owner = _OwnerFilter.all;
          // Fewer items may now be loaded than the user had scrolled to;
          // start the page count over so the list is not stuck part-way.
          _displayCount = 30;
        case _MenuChoice.ownerMine:
          _owner = _OwnerFilter.mine;
          _displayCount = 30;
      }
    });
  }

  PopupMenuItem<_MenuChoice> _menuItem(
    _MenuChoice value,
    String label,
    bool selected,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: 18,
            color: selected ? Aurora.primary : Colors.transparent,
          ),
          const SizedBox(width: 8),
          Text(label, style: Aurora.text(14, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String label, _MediaFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() {
        _filter = value;
        _displayCount = 30;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? Aurora.primaryGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: selected ? 0.3 : 0.06),
              blurRadius: selected ? 16 : 8,
              offset: Offset(0, selected ? 6 : 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: Aurora.text(
            13,
            weight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF4A4455),
          ),
        ),
      ),
    );
  }

  Widget _grid(
    AppLocalizations t,
    List<MapMediaItem> all,
    List<MapMediaItem> displayed,
    UserModel? me,
    Map<String, UserModel> friendProfiles,
  ) {
    if (all.isEmpty) return _emptyState(t);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: Aurora.primary,
            onRefresh: () async {
              debugPrint('🔄 [GalleryScreen] Pull-to-refresh triggered.');
              try {
                // Invalidate the underlying providers that mapMediaProvider depends on
                ref.invalidate(galleryProvider);
                ref.invalidate(videoGalleryProvider);
                ref.invalidate(friendsMediaProvider);

                await Future.delayed(const Duration(milliseconds: 500));

                // Read the new computed list
                final newItems = ref.read(mapMediaProvider);
                debugPrint(
                  '✅ [GalleryScreen] Refreshed successfully. Found ${newItems.length} media items.',
                );
              } catch (e, st) {
                debugPrint('❌ [GalleryScreen] Error refreshing data: $e\n$st');
              }
            },
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                kAppBottomNavHeight,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: displayed.length,
              itemBuilder: (context, index) {
                final item = displayed[index];
                final owner = _ownerOf(item, me, friendProfiles);
                return FadeSlideIn.indexed(
                  key: ValueKey(item.id),
                  index: index,
                  dy: 12,
                  child: MediaGridItem(
                    item: item,
                    ownerPhotoUrl: owner.photoUrl,
                    ownerName: owner.name,
                    onTap: () => _openItem(item),
                  ),
                );
              },
            ),
          ),
        ),
        if (AdsEnvironment.showAds)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: EasyNativeAdWithFallback(
                factoryId: MyAdIdName.nativeFull,
                adId: getIt<AdConfig>().nativeLibrary,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(AppLocalizations t) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, kAppBottomNavHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyIllustration(),
            const SizedBox(height: 8),
            Text(
              t.noPhotosYet,
              textAlign: TextAlign.center,
              style: Aurora.text(24, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Text(
                t.takeFirstPhoto,
                textAlign: TextAlign.center,
                style: Aurora.text(14, color: Aurora.subText, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 240,
              child: AuroraButton(
                label: t.takePhoto,
                height: 52,
                trailingIcon: Icons.photo_camera_rounded,
                onTap: () => context.push(AppRoutes.camera),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Camera-with-polaroids illustration for the empty gallery. Everything
/// drifts gently so the screen does not feel dead.
class _EmptyIllustration extends StatefulWidget {
  const _EmptyIllustration();

  @override
  State<_EmptyIllustration> createState() => _EmptyIllustrationState();
}

class _EmptyIllustrationState extends State<_EmptyIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _main = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);
  late final AnimationController _slow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _main.dispose();
    _slow.dispose();
    super.dispose();
  }

  Widget _blob(double size, Color c) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [c.withValues(alpha: 0.4), c.withValues(alpha: 0)],
      ),
    ),
  );

  Widget _polaroid({
    required IconData icon,
    required Color tint,
    required IconData tagIcon,
    required String tag,
    required Color shadow,
  }) {
    return Container(
      width: 78,
      height: 96,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFECE4FF),
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [tint.withValues(alpha: 0.35), const Color(0xFFECE4FF)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 26, color: tint.withValues(alpha: 0.6)),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tagIcon, size: 8, color: Aurora.secondary),
                          const SizedBox(width: 1),
                          Text(
                            tag,
                            style: Aurora.text(
                              7,
                              weight: FontWeight.w800,
                              color: const Color(0xFF4A4455),
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
          const SizedBox(height: 5),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE6DEFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _camera() {
    return Container(
      width: 176,
      height: 144,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Aurora.primary, Color(0xFF630ED4), Color(0xFFFE4C8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.45),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2FD9F4),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF2FD9F4), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF322C4D).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE4C8C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: Aurora.text(
                          9,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Aurora.darkText, Color(0xFF322C4D), Color(0xFF630ED4)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA2EEFF), Aurora.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.adjust_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GPS-CAM 4K',
                  style: Aurora.text(
                    8,
                    weight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Row(
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 288,
      height: 256,
      child: AnimatedBuilder(
        animation: Listenable.merge([_main, _slow]),
        builder: (context, _) {
          final m = Curves.easeInOut.transform(_main.value);
          final sl = Curves.easeInOut.transform(_slow.value);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(top: -16, child: _blob(256, Aurora.primary)),
              _blob(208, Aurora.secondary),
              Positioned(
                left: -4,
                top: 24 - sl * 9,
                child: Transform.rotate(
                  angle: -0.21 + sl * 0.05,
                  child: _polaroid(
                    icon: Icons.landscape_rounded,
                    tint: Aurora.primary,
                    tagIcon: Icons.location_on_rounded,
                    tag: 'GPS',
                    shadow: const Color(0xFF630ED4),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: 32 + sl * 7,
                child: Transform.rotate(
                  angle: 0.21 - sl * 0.05,
                  child: _polaroid(
                    icon: Icons.wb_sunny_rounded,
                    tint: Aurora.secondary,
                    tagIcon: Icons.schedule_rounded,
                    tag: '12:45',
                    shadow: const Color(0xFFFE4C8C),
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: 48,
                child: Transform.translate(
                  offset: Offset(0, -6 * m),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      size: 18,
                      color: Color(0xFFFE4C8C),
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 16,
                left: 40,
                child: Text(
                  '✦',
                  style: TextStyle(fontSize: 20, color: Aurora.primary),
                ),
              ),
              const Positioned(
                top: 40,
                left: 64,
                child: Text('✨', style: TextStyle(fontSize: 14)),
              ),
              Transform.translate(
                offset: Offset(0, -7 * m),
                child: Transform.rotate(angle: 0.017 * m, child: _camera()),
              ),
            ],
          );
        },
      ),
    );
  }
}
