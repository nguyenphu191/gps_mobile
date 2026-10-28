import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import 'camera_control_button.dart';
import 'camera_grid.dart';
import 'camera_permission_view.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.isInitialized,
    required this.cameraPermissionDenied,
    required this.cameraController,
    required this.isCapturing,
    required this.liveAddress,
    required this.liveLatitude,
    required this.liveLongitude,
    required this.onCapture,
    required this.onToggleCamera,
    required this.onBack,
  });

  final bool isInitialized;
  final bool cameraPermissionDenied;
  final CameraController? cameraController;
  final bool isCapturing;
  final String liveAddress;
  final double liveLatitude;
  final double liveLongitude;
  final VoidCallback onCapture;
  final VoidCallback onToggleCamera;
  final VoidCallback onBack;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with SingleTickerProviderStateMixin {
  // Slow "breathing" glow on the shutter.
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized && widget.cameraPermissionDenied) {
      return CameraPermissionView(onBack: widget.onBack);
    }

    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final controller = widget.cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (widget.isInitialized &&
              controller != null &&
              controller.value.previewSize != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.previewSize!.height,
                  height: controller.value.previewSize!.width,
                  child: CameraPreview(controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Aurora.secondary,
                strokeWidth: 2.5,
              ),
            ),

          // Top and bottom scrims for legibility over any scene.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: media.size.height / 3,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ),

          // Rule-of-thirds grid
          const Positioned.fill(child: CameraGrid()),

          // Top controls
          Positioned(
            top: media.padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraControlButton(
                  icon: Icons.close_rounded,
                  onTap: widget.onBack,
                ),
                CameraControlButton(
                  icon: Icons.cameraswitch_rounded,
                  onTap: widget.onToggleCamera,
                ),
              ],
            ),
          ),

          // Bottom: GPS stamp card + shutter
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                media.padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stampCard(t),
                  const SizedBox(height: 22),
                  _shutter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stampCard(AppLocalizations t) {
    final needsLocation = widget.liveAddress == t.enableLocation;
    const amber = Color(0xFFF59E0B);
    final hasFix = !needsLocation;

    Widget chip(IconData icon, Color color, String text) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Aurora.secondary,
                      Aurora.primary,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: needsLocation ? openAppSettings : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(
                            needsLocation
                                ? Icons.location_off_rounded
                                : Icons.location_on_rounded,
                            size: 18,
                            color: needsLocation ? amber : Aurora.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.liveAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Aurora.text(
                                13.5,
                                weight: FontWeight.w700,
                                color: needsLocation ? amber : Colors.white,
                              ),
                            ),
                          ),
                          if (hasFix)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22D3EE).withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'GPS',
                                style: Aurora.text(
                                  9.5,
                                  weight: FontWeight.w800,
                                  color: const Color(0xFF22D3EE),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        chip(
                          Icons.gps_fixed_rounded,
                          const Color(0xFF22D3EE),
                          '${t.latShort}: ${widget.liveLatitude.toStringAsFixed(5)}  ${t.lonShort}: ${widget.liveLongitude.toStringAsFixed(5)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        chip(
                          Icons.access_time_rounded,
                          const Color(0xFFA78BFA),
                          DateFormat('yyyy-MM-dd  HH:mm:ss').format(
                            DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shutter() {
    return GestureDetector(
      onTap: widget.isCapturing ? null : widget.onCapture,
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (context, _) {
          final v = Curves.easeInOut.transform(_breathe.value);
          return Container(
            width: 82,
            height: 82,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Transform.scale(
              scale: 1 + 0.025 * v,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Aurora.primary, Color(0xFFEC4899), Color(0xFFFB7185)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        Aurora.secondary,
                        Aurora.primary,
                        v,
                      )!.withValues(alpha: 0.55),
                      blurRadius: 25 + 10 * v,
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isCapturing
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
