import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import '../../../shared/widgets/aurora_blob.dart';
import 'camera_control_button.dart';

/// Review of the just-captured (already stamped) photo before saving.
class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    super.key,
    required this.imagePath,
    required this.onRetake,
    required this.onSave,
  });

  final String imagePath;
  final VoidCallback onRetake;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Aurora.darkText,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 240, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: 100, left: 80, size: 300, color: Color(0xFF007181)),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, media.padding.top + 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CameraControlButton(
                      icon: Icons.close_rounded,
                      onTap: onRetake,
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 22,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 40,
                          spreadRadius: -10,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: ColoredBox(
                        color: Colors.black,
                        child: SizedBox.expand(
                          child: Image.file(File(imagePath), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      20,
                      24,
                      media.padding.bottom + 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE6141026),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CameraActionButton(
                            icon: Icons.replay_rounded,
                            label: t.retake,
                            onTap: onRetake,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CameraActionButton(
                            icon: Icons.check_circle_rounded,
                            label: t.save,
                            onTap: onSave,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
