import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/features/destination/direction_screen.dart';
import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/aurora.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_webview_screen.dart';

class DetailBottomBar extends StatelessWidget {
  final DestinationModel dest;
  final double bottomPad;
  const DetailBottomBar({
    super.key,
    required this.dest,
    required this.bottomPad,
  });

  void _openStreetView(BuildContext context) {
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.streetViewClick,
      parameters: {'destination_id': dest.id},
    );
    // The app's own Street View screen, seeded with this destination, instead
    // of a bare Google Maps web page.
    context.push(
      AppRoutes.streetViewAt(dest.latitude, dest.longitude, name: dest.name),
    );
  }

  Future<void> _openEarth3D(BuildContext context) async {
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.earth3dClick,
      parameters: {'destination_id': dest.id},
    );
    // Use Google Maps Embed API for a clean satellite view inside iframe
    final url =
        'https://www.google.com/maps/embed/v1/view?key=${AppConstants.googleMapsApiKey}&center=${dest.latitude},${dest.longitude}&zoom=18&maptype=satellite';
    final t = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppWebviewScreen(title: t.earth3d, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
          decoration: BoxDecoration(
            color: Aurora.bgSoft.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Aurora.darkText.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Street View button
              _IconActionButton(
                icon: Icons.streetview_rounded,
                label: t.streetView,
                color: Aurora.primary,
                onTap: () => _openStreetView(context),
              ),
              const SizedBox(width: 10),

              // Earth 3D button
              _IconActionButton(
                icon: Icons.public_rounded,
                label: t.earth3d,
                color: Aurora.primary,
                onTap: () => _openEarth3D(context),
              ),
              const SizedBox(width: 10),

              // Directions button (expanded)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    getIt<AnalyticsService>().logEvent(
                      AnalyticsEvents.directionClick,
                      parameters: {'destination_id': dest.id},
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DirectionScreen(destination: dest),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      gradient: Aurora.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: Aurora.glow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.turn_sharp_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.directions,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFECE4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
