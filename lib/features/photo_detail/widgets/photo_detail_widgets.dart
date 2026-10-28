import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/core/router/app_router.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/models/photo_model.dart';

/// Shares the stamped photo file with a short caption.
Future<void> sharePhoto(PhotoModel photo) async {
  getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoShared);
  await Share.shareXFiles(
    [XFile(photo.imagePath)],
    text:
        'Photo at ${photo.address} on ${DateFormat('yyyy-MM-dd HH:mm').format(photo.timestamp)}',
  );
}

// ── Address block ──────────────────────────────────────────────────────────────

class PhotoAddressBlock extends StatefulWidget {
  final String address;
  final double latitude;
  final double longitude;

  const PhotoAddressBlock({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PhotoAddressBlock> createState() => _PhotoAddressBlockState();
}

class _PhotoAddressBlockState extends State<PhotoAddressBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.address}\n${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
      ),
    );
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Aurora.bgSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: Aurora.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Aurora.text(16, weight: FontWeight.w700, height: 1.25),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _copy,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: Aurora.cardShadow,
              ),
              child: Icon(
                _copied ? Icons.done_rounded : Icons.content_copy_rounded,
                size: 19,
                color: Aurora.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info tile ──────────────────────────────────────────────────────────────────

class PhotoInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String label;
  final String value;
  final bool mono;

  const PhotoInfoTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            style: Aurora.text(
              10,
              weight: FontWeight.w700,
              color: const Color(0xFF4A4455),
            ).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: mono
                ? const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: Aurora.darkText,
                  )
                : Aurora.text(12.5, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Map preview ────────────────────────────────────────────────────────────────

class PhotoMapPreview extends StatelessWidget {
  final LatLng photoLatLng;

  const PhotoMapPreview({super.key, required this.photoLatLng});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: Aurora.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Offline grid placeholder (always visible beneath tiles)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEDE4FF), Color(0xFFE5EDFF)],
                ),
              ),
              child: CustomPaint(
                painter: _GridPainter(),
                child: const SizedBox.expand(),
              ),
            ),
            FlutterMap(
              options: MapOptions(
                initialCenter: photoLatLng,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  userAgentPackageName: AppConstants.appPackage,
                  errorTileCallback: (tile, error, stackTrace) {},
                  tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Aurora.primary.withValues(alpha: 0.06),
                      BlendMode.srcATop,
                    ),
                    child: tileWidget,
                  ),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: photoLatLng,
                      width: 56,
                      height: 56,
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: Aurora.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Aurora.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 20,
                              color: Aurora.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Grid painter for offline map placeholder
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B87C6).withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    const step = 32.0;
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

// ── Action dock ────────────────────────────────────────────────────────────────

class PhotoActionButtonsRow extends ConsumerWidget {
  final PhotoModel photo;
  final String photoId;
  final void Function(BuildContext context, WidgetRef ref) onDeleteTap;

  const PhotoActionButtonsRow({
    super.key,
    required this.photo,
    required this.photoId,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Aurora.darkText.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DockItem(
            icon: Icons.share_rounded,
            label: t.share,
            onTap: () => sharePhoto(photo),
          ),
          _DockItem(
            icon: Icons.map_rounded,
            label: t.openInMap,
            onTap: () => context.push('/map-gallery'),
          ),
          _DockItem(
            icon: Icons.streetview_rounded,
            label: t.streetView,
            hero: true,
            onTap: () {
              getIt<AnalyticsService>().logEvent(
                AnalyticsEvents.streetViewClick,
              );
              context.push(
                AppRoutes.streetViewAt(
                  photo.latitude,
                  photo.longitude,
                  name: photo.address,
                ),
              );
            },
          ),
          _DockItem(
            icon: Icons.delete_rounded,
            label: t.delete,
            danger: true,
            onTap: () => onDeleteTap(context, ref),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hero;
  final bool danger;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hero = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFBA1A1A);
    final size = hero ? 44.0 : 38.0;
    final labelColor = danger
        ? red
        : hero
        ? Aurora.primary
        : Aurora.darkText;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hero ? Aurora.primaryGradient : null,
                color: hero
                    ? null
                    : danger
                    ? const Color(0x99FFDAD6)
                    : const Color(0xFFF1EBFF),
                boxShadow: hero
                    ? [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: hero ? 23 : 20,
                color: hero
                    ? Colors.white
                    : danger
                    ? red
                    : Aurora.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Aurora.text(
                11,
                weight: hero ? FontWeight.w800 : FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
