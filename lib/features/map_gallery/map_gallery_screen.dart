import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/features/auth/services/auth_service.dart';
import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/providers/location_provider.dart';
import 'package:gpscamerastamp/shared/widgets/user_avatar.dart';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_config.dart';
import '../../ads/const/ads_environment.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';

import '../sharing/services/cloudinary_client.dart';
import '../sharing/services/upload_queue.dart';
import 'providers/map_media_provider.dart';
import 'widgets/map_overlay_widgets.dart';
import 'widgets/media_bottom_sheet.dart';

class MapGalleryScreen extends ConsumerStatefulWidget {
  /// True when the map is shown inside the Gallery tab rather than as its own
  /// route: there is no back button, and the overlays anchor to the top of the
  /// map area instead of the screen's notch.
  final bool embedded;

  const MapGalleryScreen({super.key, this.embedded = false});

  @override
  ConsumerState<MapGalleryScreen> createState() => _MapGalleryScreenState();
}

enum _MediaFilter { all, photos, videos, mine, friends }

class _MapGalleryScreenState extends ConsumerState<MapGalleryScreen> {
  final MapController _mapController = MapController();
  DateTimeRange? _dateFilter;
  _MediaFilter _filter = _MediaFilter.all;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.mapGalleryView);
    // Retry any share upload that failed earlier (e.g. offline capture).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadQueueProvider).syncPending();
    });
  }

  List<MapMediaItem> _filtered(List<MapMediaItem> items) {
    return items.where((item) {
      if (_dateFilter != null) {
        final inRange =
            item.timestamp.isAfter(
              _dateFilter!.start.subtract(const Duration(days: 1)),
            ) &&
            item.timestamp.isBefore(
              _dateFilter!.end.add(const Duration(days: 1)),
            );
        if (!inRange) return false;
      }
      switch (_filter) {
        case _MediaFilter.all:
          return true;
        case _MediaFilter.photos:
          return !item.isVideo;
        case _MediaFilter.videos:
          return item.isVideo;
        case _MediaFilter.mine:
          return item.isMine;
        case _MediaFilter.friends:
          return !item.isMine;
      }
    }).toList();
  }

  /// Fly to a friend's newest photo/video — their media is often hundreds of
  /// kilometres away and would never show up in the initial viewport.
  void _jumpToFriend(FriendMediaSummary friend) {
    final item = friend.latest;
    _mapController.move(LatLng(item.latitude, item.longitude), 16);
    _showMediaBottomSheet(item);
  }

  void _showMediaBottomSheet(MapMediaItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MediaBottomSheet(item: item),
    );
  }

  Future<void> _showDateFilter() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateFilter,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Aurora.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
    }
  }

  void _onBack() {
    if (AdsEnvironment.showAds) {
      bool handled = false;
      EasyAds.instance.showInterstitialAd(
        context,
        adId: getIt<AdConfig>().interBack,
        adDissmissed: () {
          if (!handled) {
            handled = true;
            Navigator.of(context).pop(); // Pop ad overlay
            context.pop(); // Pop MapGalleryScreen using GoRouter
          }
        },
        onFailed: () {
          if (!handled) {
            handled = true;
            Navigator.of(context).pop(); // Pop ad overlay
            context.pop(); // Pop MapGalleryScreen using GoRouter
          }
        },
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mapMediaProvider);
    final friends = ref.watch(friendsWithMediaProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final filtered = _filtered(media);

    final userLatLng = locationAsync.whenOrNull(
      data: (pos) => LatLng(pos.latitude, pos.longitude),
    );

    final initialCenter =
        userLatLng ??
        const LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        );

    // Move to user location whenever it becomes available
    if (userLatLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(userLatLng, 17.0);
      });
    }

    // Counts for the chips ignore the filter itself but respect the date range,
    // so they always describe what each chip would show.
    final scoped = _dateFilter == null
        ? media
        : media.where((item) => _inDateRange(item)).toList();
    final counts = <_MediaFilter, int>{
      _MediaFilter.all: scoped.length,
      _MediaFilter.photos: scoped.where((i) => !i.isVideo).length,
      _MediaFilter.videos: scoped.where((i) => i.isVideo).length,
      _MediaFilter.mine: scoped.where((i) => i.isMine).length,
      _MediaFilter.friends: scoped.where((i) => !i.isMine).length,
    };

    final body = Stack(
      children: [
        // Offline grid placeholder beneath the map tiles
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEDE4FF), Color(0xFFE5EDFF)],
            ),
          ),
          child: CustomPaint(
            painter: _MapGridPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 17.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              subdomains: const ['0', '1', '2', '3'],
              userAgentPackageName: AppConstants.appPackage,
              errorTileCallback: (tile, error, stackTrace) {},
              // Soften the stock OSM colours toward the app palette.
              tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Aurora.primary.withValues(alpha: 0.06),
                  BlendMode.srcATop,
                ),
                child: tileWidget,
              ),
            ),

            // User location marker
            if (userLatLng != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLatLng,
                    width: 44,
                    height: 44,
                    child: const _UserDot(),
                  ),
                ],
              ),

            // Photo cluster markers
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 60,
                size: const Size(48, 48),
                markers: filtered
                    .map(
                      (item) => Marker(
                        point: LatLng(item.latitude, item.longitude),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _showMediaBottomSheet(item),
                          child: _MediaMarker(item: item),
                        ),
                      ),
                    )
                    .toList(),
                builder: (context, markers) {
                  return _ClusterMarker(count: markers.length);
                },
              ),
            ),
          ],
        ),

        // Soft fade at the top so the overlays read over any map area.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Aurora.bgSoft.withValues(alpha: 0.8),
                    Aurora.bgSoft.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Top overlays: back + count, filter chips, friend strip
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.embedded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      MapBackButton(onTap: _onBack),
                      const SizedBox(width: 10),
                      MapTitlePill(title: AppLocalizations.of(context).gallery),
                      const Spacer(),
                      Builder(
                        builder: (context) {
                          final user = ref.watch(currentUserProvider).valueOrNull;
                          if (user == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              gradient: Aurora.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: UserAvatar(
                              photoUrl: user.photoUrl,
                              name: user.username.isNotEmpty
                                  ? user.username
                                  : user.displayName,
                              radius: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MapPhotoCountBadge(count: filtered.length),
                    if (_dateFilter != null)
                      Flexible(
                        child: MapDateFilterChip(
                          dateFilter: _dateFilter!,
                          onClear: () => setState(() => _dateFilter = null),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _MediaFilterBar(
                selected: _filter,
                counts: counts,
                onSelected: (value) => setState(() => _filter = value),
              ),
              if (friends.isNotEmpty && _filter != _MediaFilter.mine) ...[
                const SizedBox(height: 8),
                _FriendStrip(friends: friends, onTap: _jumpToFriend),
              ],
            ],
          ),
        ),

        // Locate + zoom
        Positioned(
          right: 16,
          bottom: 84 + MediaQuery.of(context).padding.bottom,
          child: MapToolButtons(
            onLocate: userLatLng == null
                ? null
                : () => _mapController.move(userLatLng, 17),
            onZoomIn: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            onZoomOut: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ),

      ],
    );

    return Scaffold(
      body: widget.embedded
          // The overlays position themselves with MediaQuery's top padding;
          // inside the tab that padding is already consumed by the header.
          ? MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: body,
            )
          : body,

      // Filter FAB
      floatingActionButton: GestureDetector(
        onTap: _showDateFilter,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Aurora.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Aurora.secondary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  bool _inDateRange(MapMediaItem item) {
    final range = _dateFilter;
    if (range == null) return true;
    return item.timestamp.isAfter(
          range.start.subtract(const Duration(days: 1)),
        ) &&
        item.timestamp.isBefore(range.end.add(const Duration(days: 1)));
  }
}

// ── Media marker widget ───────────────────────────────────────────────────────

class _MediaMarker extends StatelessWidget {
  final MapMediaItem item;
  const _MediaMarker({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            // Friends' media gets a cooler ring so it reads apart from ours.
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: item.isMine
                  ? Aurora.primaryGradient
                  : Aurora.aquaViolet,
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(child: _MarkerThumb(item: item)),
          ),
        ),
        if (item.isVideo)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: Aurora.primaryGradient,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          )
        else
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
              ),
              child: const Icon(
                Icons.photo_rounded,
                size: 10,
                color: Aurora.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _MarkerThumb extends StatelessWidget {
  final MapMediaItem item;
  const _MarkerThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    const fallback = ColoredBox(
      color: Color(0xFFF1EBFF),
      child: Icon(Icons.photo_rounded, size: 20, color: Aurora.hint),
    );

    if (item.isVideo) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF322C4D), Color(0xFF630ED4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
    if (item.isMine) {
      return Image.file(
        File(item.localPath ?? ''),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    // Markers are small — ask Cloudinary for a small variant instead of
    // pulling the full-size image.
    return Image.network(
      CloudinaryClient.thumbnailUrl(item.remoteUrl ?? ''),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

// ── User location dot ─────────────────────────────────────────────────────────

class _UserDot extends StatefulWidget {
  const _UserDot();

  @override
  State<_UserDot> createState() => _UserDotState();
}

class _UserDotState extends State<_UserDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20 + 24 * _pulse.value,
            height: 20 + 24 * _pulse.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Aurora.primary.withValues(alpha: 0.25 * (1 - _pulse.value)),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Aurora.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Friend strip ──────────────────────────────────────────────────────────────

class _FriendStrip extends StatelessWidget {
  final List<FriendMediaSummary> friends;
  final ValueChanged<FriendMediaSummary> onTap;

  const _FriendStrip({required this.friends, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onTap(friend),
              child: SizedBox(
                width: 56,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            gradient: Aurora.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: UserAvatar(
                              photoUrl: friend.photoUrl,
                              name: friend.name,
                              radius: 18,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              gradient: Aurora.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '${friend.count}',
                              style: Aurora.text(
                                10,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend.name.split(' ').first,
                      style: Aurora.text(
                        11,
                        weight: FontWeight.w700,
                      ).copyWith(
                        shadows: const [
                          Shadow(color: Colors.white, blurRadius: 4),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _MediaFilterBar extends StatelessWidget {
  final _MediaFilter selected;
  final Map<_MediaFilter, int> counts;
  final ValueChanged<_MediaFilter> onSelected;

  const _MediaFilterBar({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labels = <_MediaFilter, String>{
      _MediaFilter.all: t.filterAll,
      _MediaFilter.photos: t.filterPhotos,
      _MediaFilter.videos: t.filterVideos,
      _MediaFilter.mine: t.filterMine,
      _MediaFilter.friends: t.filterFriends,
    };
    const icons = <_MediaFilter, (IconData, Color)>{
      _MediaFilter.photos: (Icons.photo_camera_rounded, Aurora.primary),
      _MediaFilter.videos: (Icons.videocam_rounded, Aurora.secondary),
    };

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: labels.entries.map((entry) {
          final isSelected = entry.key == selected;
          final icon = icons[entry.key];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: isSelected ? Aurora.primaryGradient : null,
                  color: isSelected ? null : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.primary.withValues(
                        alpha: isSelected ? 0.3 : 0.08,
                      ),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null && !isSelected) ...[
                      Icon(icon.$1, size: 15, color: icon.$2),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '${entry.value} (${counts[entry.key] ?? 0})',
                      style: Aurora.text(
                        13,
                        weight: FontWeight.w700,
                        color: isSelected ? Colors.white : Aurora.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Cluster marker widget ──────────────────────────────────────────────────────

class _ClusterMarker extends StatelessWidget {
  final int count;
  const _ClusterMarker({required this.count});

  @override
  Widget build(BuildContext context) {
    final big = count >= 10;
    return Center(
      child: Container(
        width: big ? 52 : 44,
        height: big ? 52 : 44,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: Aurora.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: big ? 0.45 : 0.35),
              blurRadius: big ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (b) => Aurora.primaryGradient.createShader(b),
            child: Text(
              '$count',
              style: Aurora.text(
                big ? 16 : 14,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B87C6).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
