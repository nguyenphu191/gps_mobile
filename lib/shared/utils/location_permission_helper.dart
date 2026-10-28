import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/shared/widgets/gradient_button.dart';
// ── Location permission ────────────────────────────────────────────────────────

/// Returns true if location permission is granted and service enabled.
/// Shows a dialog prompting user to open Settings if denied.
Future<bool> checkLocationPermission(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    permission = await Geolocator.requestPermission();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
  }

  if (permission == LocationPermission.denied) {
    if (context.mounted) _showLocationDeniedDialog(context, forever: false);
    return false;
  }

  if (permission == LocationPermission.deniedForever) {
    if (context.mounted) _showLocationDeniedDialog(context, forever: true);
    return false;
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (context.mounted) _showServiceDisabledDialog(context);
    return false;
  }

  return true;
}

void _showLocationDeniedDialog(BuildContext context, {required bool forever}) {
  final t = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => _PermissionDialog(
      iconData: Icons.location_off_rounded,
      iconBg: const Color(0xFFFFF8E1),
      iconColor: const Color(0xFFF59E0B),
      title: t.locationAccess,
      message: forever ? t.locationDeniedForeverMsg : t.locationDeniedMsg,
      showSettingsButton: forever,
      onOpenSettings: () => Geolocator.openAppSettings(),
    ),
  );
}

void _showServiceDisabledDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => _PermissionDialog(
      iconData: Icons.gps_off_rounded,
      iconBg: const Color(0xFFFFFBEB),
      iconColor: const Color(0xFFF59E0B),
      title: t.locationServicesOff,
      message: t.locationServicesOffMsg,
      showSettingsButton: true,
      onOpenSettings: () => Geolocator.openLocationSettings(),
    ),
  );
}

// ── Camera permission ──────────────────────────────────────────────────────────

/// Returns true if camera permission is granted.
/// Shows a dialog prompting user to open Settings if denied.
Future<bool> checkCameraPermission(BuildContext context) async {
  var status = await Permission.camera.status;

  if (status.isDenied) {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    status = await Permission.camera.request();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
  }

  if (status.isGranted) return true;

  if (context.mounted) {
    _showCameraDeniedDialog(context, forever: status.isPermanentlyDenied);
  }
  return false;
}

void _showCameraDeniedDialog(BuildContext context, {required bool forever}) {
  final t = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => _PermissionDialog(
      iconData: Icons.no_photography_rounded,
      iconBg: const Color(0xFFF3F4F6),
      iconColor: const Color(0xFF6B7280),
      title: t.cameraAccess,
      message: forever ? t.cameraDeniedForeverMsg : t.cameraDeniedMsg,
      showSettingsButton: forever,
      onOpenSettings: () => openAppSettings(),
    ),
  );
}

// ── Shared dialog widget ───────────────────────────────────────────────────────

class _PermissionDialog extends StatelessWidget {
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String message;
  final bool showSettingsButton;
  final VoidCallback onOpenSettings;

  const _PermissionDialog({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.showSettingsButton,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        if (showSettingsButton)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    AppLocalizations.of(context).notNow,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: AppLocalizations.of(context).openSettings,
                  height: 46,
                  borderRadius: 12,
                  onTap: () {
                    Navigator.pop(context);
                    onOpenSettings();
                  },
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: AppLocalizations.of(context).ok,
              height: 46,
              borderRadius: 12,
              onTap: () => Navigator.pop(context),
            ),
          ),
      ],
    );
  }
}
