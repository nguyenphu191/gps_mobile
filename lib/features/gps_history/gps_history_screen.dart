import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/router/app_router.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';
import 'package:gpscamerastamp/shared/models/location_history_model.dart';
import 'widgets/history_route_map.dart';
import 'widgets/timeline_entry.dart';

final locationHistoryProvider =
    StateNotifierProvider<LocationHistoryNotifier, List<LocationHistoryModel>>(
      (ref) => LocationHistoryNotifier(),
    );

class LocationHistoryNotifier
    extends StateNotifier<List<LocationHistoryModel>> {
  LocationHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final box = Hive.box(AppConstants.historyBoxName);
    final entries = <LocationHistoryModel>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        try {
          entries.add(
            LocationHistoryModel.fromMap(Map<String, dynamic>.from(raw)),
          );
        } catch (_) {}
      }
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = entries;
  }

  Future<void> refresh() => _load();
}

class GpsHistoryScreen extends ConsumerWidget {
  const GpsHistoryScreen({super.key});

  Widget _roundButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: Aurora.cardShadow,
      ),
      child: Icon(icon, size: 20, color: Aurora.darkText),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.historyView);
    final t = AppLocalizations.of(context);
    final history = ref.watch(locationHistoryProvider);
    final points = history.map((e) => LatLng(e.latitude, e.longitude)).toList();

    // Group by calendar day, keeping the newest-first order.
    final groups = <DateTime, List<int>>{};
    for (var i = 0; i < history.length; i++) {
      final ts = history[i].timestamp;
      groups
          .putIfAbsent(DateTime(ts.year, ts.month, ts.day), () => [])
          .add(i);
    }

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 100, size: 300, color: Aurora.aqua),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      _roundButton(
                        Icons.arrow_back_ios_new_rounded,
                        () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.gpsHistoryTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(20, weight: FontWeight.w800),
                        ),
                      ),
                      _roundButton(
                        Icons.refresh_rounded,
                        () => ref.read(locationHistoryProvider.notifier).refresh(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? _buildEmptyState(context, t)
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 32),
                          children: [
                            HistoryRouteMap(
                              points: points,
                              times: history.map((e) => e.timestamp).toList(),
                            ),
                            for (final day in groups.entries)
                              ..._dayGroup(
                                day.key,
                                day.value,
                                history,
                                isLatest: day.key == groups.keys.first,
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _dayGroup(
    DateTime day,
    List<int> indexes,
    List<LocationHistoryModel> history, {
    required bool isLatest,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: isLatest ? Aurora.primaryGradient : null,
                color: isLatest ? null : const Color(0xFFE6DEFF),
                borderRadius: BorderRadius.circular(999),
                boxShadow: isLatest
                    ? [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                DateFormat('EEE, MMM dd').format(day),
                style: Aurora.text(
                  12,
                  weight: FontWeight.w800,
                  color: isLatest ? Colors.white : const Color(0xFF5A00C6),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.pin_drop_rounded,
              size: 15,
              color: Aurora.subText,
            ),
            const SizedBox(width: 3),
            Text(
              '${indexes.length}',
              style: Aurora.text(
                12,
                weight: FontWeight.w700,
                color: Aurora.subText,
              ),
            ),
          ],
        ),
      ),
      for (var j = 0; j < indexes.length; j++)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TimelineEntry(
            entry: history[indexes[j]],
            isFirst: isLatest && j == 0,
            isLast: j == indexes.length - 1,
          ),
        ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations t) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.14),
                blurRadius: 36,
                spreadRadius: -8,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 144,
                height: 144,
                child: CustomPaint(painter: _CompassPainter()),
              ),
              const SizedBox(height: 16),
              Text(
                t.noHistoryYet,
                textAlign: TextAlign.center,
                style: Aurora.text(20, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                t.historyEmptyDesc,
                textAlign: TextAlign.center,
                style: Aurora.text(14, color: Aurora.subText, height: 1.5),
              ),
              const SizedBox(height: 24),
              AuroraButton(
                label: t.takePhoto,
                height: 48,
                trailingIcon: Icons.photo_camera_rounded,
                onTap: () => context.push(AppRoutes.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Playful compass used on the empty state.
class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final scale = size.width / 160;

    // Dotted orbit
    final orbit = Paint()
      ..color = const Color(0xFFEADDFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    const dashes = 36;
    for (var i = 0; i < dashes; i++) {
      final a0 = i * 2 * 3.14159265 / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: 62 * scale),
        a0,
        2 * 3.14159265 / dashes * 0.5,
        false,
        orbit,
      );
    }

    // Dial
    canvas.drawCircle(c, 48 * scale, Paint()..color = const Color(0xFFF7F1FF));
    canvas.drawCircle(c, 40 * scale, Paint()..color = Colors.white);

    Path tri(List<Offset> pts) => Path()
      ..moveTo(c.dx + pts[0].dx * scale, c.dy + pts[0].dy * scale)
      ..lineTo(c.dx + pts[1].dx * scale, c.dy + pts[1].dy * scale)
      ..lineTo(c.dx + pts[2].dx * scale, c.dy + pts[2].dy * scale)
      ..close();

    // Needles (north pink, south violet)
    canvas.drawPath(
      tri(const [Offset(0, -32), Offset(8, 0), Offset(0, -6)]),
      Paint()..color = const Color(0xFFFE4C8C),
    );
    canvas.drawPath(
      tri(const [Offset(0, -32), Offset(-8, 0), Offset(0, -6)]),
      Paint()..color = const Color(0xFFFF4D8D),
    );
    canvas.drawPath(
      tri(const [Offset(0, 32), Offset(8, 0), Offset(0, 6)]),
      Paint()..color = const Color(0xFF7C3AED),
    );
    canvas.drawPath(
      tri(const [Offset(0, 32), Offset(-8, 0), Offset(0, 6)]),
      Paint()..color = const Color(0xFF630ED4),
    );
    canvas.drawCircle(c, 5 * scale, Paint()..color = const Color(0xFF1D1737));
    canvas.drawCircle(c, 2 * scale, Paint()..color = Colors.white);

    // Sparkles
    void star(Offset o, double r, Color color) {
      final p = Path()
        ..moveTo(o.dx, o.dy - r)
        ..lineTo(o.dx + r * 0.25, o.dy - r * 0.25)
        ..lineTo(o.dx + r, o.dy)
        ..lineTo(o.dx + r * 0.25, o.dy + r * 0.25)
        ..lineTo(o.dx, o.dy + r)
        ..lineTo(o.dx - r * 0.25, o.dy + r * 0.25)
        ..lineTo(o.dx - r, o.dy)
        ..lineTo(o.dx - r * 0.25, o.dy - r * 0.25)
        ..close();
      canvas.drawPath(p, Paint()..color = color);
    }

    star(Offset(c.dx + 44 * scale, c.dy - 42 * scale), 8 * scale, const Color(0xFFFE4C8C));
    star(Offset(c.dx - 48 * scale, c.dy - 30 * scale), 6 * scale, const Color(0xFF7C3AED));
    star(Offset(c.dx + 38 * scale, c.dy + 38 * scale), 5 * scale, const Color(0xFF2FD9F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
