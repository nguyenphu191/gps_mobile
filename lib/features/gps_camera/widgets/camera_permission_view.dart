import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import '../../../shared/widgets/aurora_blob.dart';
import '../../../shared/widgets/aurora_button.dart';

/// Shown instead of the viewfinder when camera access was refused.
class CameraPermissionView extends StatelessWidget {
  const CameraPermissionView({super.key, required this.onBack});

  final VoidCallback onBack;

  Widget _badge({
    required IconData icon,
    required Color color,
    required double size,
    Color? background,
  }) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background ?? Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Icon(icon, size: size * 0.55, color: color),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 200, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: 40, left: 100, size: 280, color: Aurora.aqua),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
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
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 170,
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Aurora.primary.withValues(alpha: 0.4),
                                          Aurora.primary.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 144,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: Aurora.primaryGradient,
                                      boxShadow: Aurora.glow,
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    right: 14,
                                    bottom: 18,
                                    child: _badge(
                                      icon: Icons.lock_rounded,
                                      color: const Color(0xFFB90A5A),
                                      size: 40,
                                      background: const Color(0xFFFFD9E0),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 10,
                                    child: _badge(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      color: Aurora.secondary,
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    bottom: 30,
                                    child: _badge(
                                      icon: Icons.location_on_rounded,
                                      color: const Color(0xFF007181),
                                      size: 34,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t.cameraAccessNotEnabled,
                              textAlign: TextAlign.center,
                              style: Aurora.text(
                                24,
                                weight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Text(
                                t.openSettingsHint,
                                textAlign: TextAlign.center,
                                style: Aurora.text(
                                  14,
                                  color: const Color(0xFF4A4455),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AuroraButton(
                    label: t.openSettings,
                    trailingIcon: Icons.settings_rounded,
                    onTap: openAppSettings,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: onBack,
                      child: Text(
                        t.notNow,
                        style: Aurora.text(
                          13,
                          weight: FontWeight.w600,
                          color: const Color(0xFF4A4455),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: media.padding.bottom > 0 ? 0 : 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
