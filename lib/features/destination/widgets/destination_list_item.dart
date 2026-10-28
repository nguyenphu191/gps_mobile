import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/features/destination/direction_screen.dart';
import 'package:gpscamerastamp/features/destination/widgets/destination_detail_page.dart';
import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';

class DestinationListItem extends StatefulWidget {
  final DestinationModel dest;
  const DestinationListItem({super.key, required this.dest});

  @override
  State<DestinationListItem> createState() => _DestinationListItemState();
}

class _DestinationListItemState extends State<DestinationListItem> {
  bool _pressed = false;

  DestinationModel get dest => widget.dest;

  String get _coords {
    final lat = dest.latitude;
    final lng = dest.longitude;
    return '${lat.abs().toStringAsFixed(3)}°${lat >= 0 ? 'N' : 'S'}, '
        '${lng.abs().toStringAsFixed(3)}°${lng >= 0 ? 'E' : 'W'}';
  }

  void _open(BuildContext context) {
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.destinationDetailView,
      parameters: {'destination_id': dest.id},
    );
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DestinationDetailPage(dest: dest, heroTag: 'all_dest_${dest.id}'),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => _open(context),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 168,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image with rating badge
              SizedBox(
                width: 136,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'all_dest_${dest.id}',
                        child: ShimmerNetworkImage(
                          imageUrl: dest.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                dest.rating.toString(),
                                style: Aurora.text(11, weight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(17, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 15,
                                color: Aurora.secondary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  dest.country,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Aurora.text(
                                    13,
                                    weight: FontWeight.w600,
                                    color: Aurora.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _coords,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Aurora.subText,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(child: DestinationTag(dest.continent, accent: true)),
                          const SizedBox(width: 6),
                          Flexible(child: DestinationTag(dest.timezone)),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: DirectionButton(dest: dest),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DestinationTag extends StatelessWidget {
  final String label;
  final bool accent;
  const DestinationTag(this.label, {super.key, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent ? const Color(0xFFECE4FF) : const Color(0xFFF1EBFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: Aurora.text(
          10,
          weight: accent ? FontWeight.w800 : FontWeight.w600,
          color: accent ? Aurora.primary : const Color(0xFF4A4455),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class DirectionButton extends StatelessWidget {
  final DestinationModel dest;
  const DirectionButton({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<AnalyticsService>().logEvent(
          AnalyticsEvents.directionClick,
          parameters: {'destination_id': dest.id},
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DirectionScreen(destination: dest)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: Aurora.primaryGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(
              AppLocalizations.of(context).directionLabel,
              style: Aurora.text(
                12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
