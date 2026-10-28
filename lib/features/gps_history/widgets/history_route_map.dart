import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';

/// Route overview card. [points] are newest-first (the order the history is
/// stored in); [times] lines up with them.
class HistoryRouteMap extends StatelessWidget {
  final List<LatLng> points;
  final List<DateTime> times;

  const HistoryRouteMap({super.key, required this.points, required this.times});

  double get _km {
    const d = Distance();
    var meters = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      meters += d.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return meters / 1000;
  }

  String get _tracked {
    if (times.length < 2) return '0m';
    final span = times.first.difference(times.last).abs();
    final h = span.inHours;
    final m = span.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    // Chronological order for drawing: oldest → newest.
    final route = points.reversed.toList();
    final start = route.first;
    final end = route.last;
    final multi = route.length >= 2;

    return Container(
      height: 228,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: end,
                  initialZoom: 15,
                  initialCameraFit: multi
                      ? CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(route),
                          padding: const EdgeInsets.fromLTRB(40, 40, 40, 90),
                          maxZoom: 17,
                        )
                      : null,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
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
                  if (multi)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          strokeWidth: 4.5,
                          color: Aurora.secondary,
                          pattern: StrokePattern.dashed(segments: const [6, 7]),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (multi && route.length <= 12)
                        for (final p in route.sublist(1, route.length - 1))
                          Marker(
                            point: p,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Aurora.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                size: 13,
                                color: Aurora.primary,
                              ),
                            ),
                          ),
                      if (multi)
                        Marker(
                          point: start,
                          width: 84,
                          height: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2FD9F4),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF2FD9F4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('HH:mm').format(times.last),
                                  style: Aurora.text(
                                    11,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Marker(
                        point: end,
                        width: 40,
                        height: 40,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: Aurora.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Aurora.secondary.withValues(alpha: 0.45),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats dock
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.darkText.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _stat(
                      Icons.alt_route_rounded,
                      Aurora.primary,
                      '${_km.toStringAsFixed(1)} km',
                    ),
                    _divider(),
                    _stat(
                      Icons.pin_drop_rounded,
                      Aurora.secondary,
                      '${points.length}',
                    ),
                    _divider(),
                    _stat(
                      Icons.schedule_rounded,
                      const Color(0xFF007181),
                      _tracked,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 24,
    color: const Color(0xFFECE4FF),
  );

  Widget _stat(IconData icon, Color color, String value) => Expanded(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Aurora.text(14, weight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}
