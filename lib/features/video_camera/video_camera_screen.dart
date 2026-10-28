import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ads/capture_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/features/gps_camera/widgets/camera_control_button.dart';
import 'package:gpscamerastamp/features/gps_camera/widgets/camera_grid.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/models/map_media_item.dart';
import '../../../shared/utils/location_permission_helper.dart';
import '../sharing/services/upload_queue.dart';
import 'models/video_model.dart';
import 'providers/video_gallery_provider.dart';
import 'video_preview_screen.dart';

class VideoCameraScreen extends ConsumerStatefulWidget {
  const VideoCameraScreen({super.key});

  @override
  ConsumerState<VideoCameraScreen> createState() => _VideoCameraScreenState();
}

class _VideoCameraScreenState extends ConsumerState<VideoCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.auto;
  bool _isProcessing = false;

  /// Clips are capped so sharing them stays cheap in storage and bandwidth.
  static const int _maxRecordSeconds = 10;
  Timer? _recordTimer;
  int _remainingSeconds = _maxRecordSeconds;

  double _liveLatitude = 0;
  double _liveLongitude = 0;
  String _liveAddress = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
      _updateLiveLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // The controller goes away here, so the countdown must not outlive it.
      _stopRecordTimer();
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
      if (mounted && _liveAddress.isEmpty) {
        _updateLiveLocation();
      }
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    final cameraIndex = _isFrontCamera
        ? _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          )
        : _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
          );

    final camera = _cameras[cameraIndex < 0 ? 0 : cameraIndex];

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _updateLiveLocation() async {
    final granted = await checkLocationPermission(context);
    if (!granted) {
      if (mounted)
        setState(
          () => _liveAddress = AppLocalizations.of(context).enableLocation,
        );
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _liveLatitude = position.latitude;
        _liveLongitude = position.longitude;
      });
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks.first;
          final parts = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((p) => p != null && p.isNotEmpty);
          setState(() {
            _liveAddress = parts.isNotEmpty
                ? parts.join(', ')
                : AppLocalizations.of(context).unknownLocation;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(
            () =>
                _liveAddress = AppLocalizations.of(context).addressUnavailable,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _liveAddress = AppLocalizations.of(context).locationUnavailable,
        );
      }
    }
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });
    _initCamera();
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.auto
          ? FlashMode.always
          : _flashMode == FlashMode.always
          ? FlashMode.off
          : FlashMode.auto;
    });
    _cameraController?.setFlashMode(_flashMode);
  }

  Future<void> _toggleRecord() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isProcessing) return;
    _isProcessing = true;

    final t = AppLocalizations.of(context);

    if (_isRecording) {
      try {
        _stopRecordTimer();
        final xFile = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);
        _isProcessing = false;

        // Awaited so the ad's loading route is gone before the preview is
        // pushed — otherwise the two routes stack in the wrong order.
        await showVideoCaptureAd(context, ref);
        if (!mounted) return;

        final bool? shouldSave = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => VideoPreviewScreen(videoPath: xFile.path),
          ),
        );

        if (shouldSave != true) {
          try {
            File(xFile.path).deleteSync();
          } catch (_) {}
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        String address = t.unknownLocation;
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final parts = [
              place.street,
              place.locality,
              place.administrativeArea,
              place.country,
            ].where((p) => p != null && p.isNotEmpty);
            if (parts.isNotEmpty) address = parts.join(', ');
          }
        } catch (_) {}

        final now = DateTime.now();

        // Copy from cache to application documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}.mp4';
        final newPath = p.join(docsDir.path, fileName);
        await File(xFile.path).copy(newPath);

        try {
          await Gal.putVideo(newPath);
        } catch (e) {
          debugPrint('Save video to gallery error: $e');
        }

        // Clean up the cache file
        try {
          File(xFile.path).deleteSync();
        } catch (_) {}

        final video = VideoModel(
          id: const Uuid().v4(),
          videoPath: newPath,
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: now,
          address: address,
          // Stamped so another account signing in on this device does not
          // inherit it as their own.
          ownerUid: FirebaseAuth.instance.currentUser?.uid,
        );

        ref.read(videoGalleryProvider.notifier).addVideo(video);

        // Belt and braces: skip sharing a clip that somehow ran long, so one
        // oversized file can't eat the storage quota.
        const maxShareBytes = 30 * 1024 * 1024;
        final videoSize = File(video.videoPath).lengthSync();
        if (videoSize > maxShareBytes) {
          debugPrint(
            '🔥 [VideoCamera] skipping share, clip is $videoSize bytes',
          );
        } else {
          // Share with friends in the background; skipped when signed out.
          unawaited(
            ref
                .read(uploadQueueProvider)
                .enqueue(
                  id: video.id,
                  filePath: video.videoPath,
                  kind: MediaKind.video,
                  latitude: video.latitude,
                  longitude: video.longitude,
                  address: video.address,
                  timestamp: video.timestamp,
                ),
          );
        }

        if (mounted) {
          context.showSuccessSnack(t.videoSaved);
        }
      } catch (e) {
        debugPrint('🔥 [VideoCamera] save failed: $e');
        _stopRecordTimer();
        setState(() => _isRecording = false);
        _isProcessing = false;
        if (mounted) {
          context.showErrorSnack(t.videoSaveFailed);
        }
      }
    } else {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _remainingSeconds = _maxRecordSeconds;
        });

        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              _toggleRecord();
            }
          });
        });
      } catch (e) {
        debugPrint('Start recording error: $e');
      } finally {
        _isProcessing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final progress =
        ((_maxRecordSeconds - _remainingSeconds) / _maxRecordSeconds).clamp(
          0.0,
          1.0,
        );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!)),

          if (!_isInitialized)
            const Center(
              child: CircularProgressIndicator(
                color: Aurora.secondary,
                strokeWidth: 2.5,
              ),
            ),

          // Scrims so the overlays stay legible over any footage.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0, 0.35, 1],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: CameraGrid()),

          // Top bar + progress
          Positioned(
            top: media.padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CameraControlButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    if (_isRecording) _recPill(t),
                    CameraControlButton(
                      icon: _flashMode == FlashMode.auto
                          ? Icons.flash_auto_rounded
                          : _flashMode == FlashMode.always
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: _toggleFlash,
                    ),
                  ],
                ),
                if (_isRecording) ...[
                  const SizedBox(height: 12),
                  _progressBar(progress),
                ],
              ],
            ),
          ),

          // Bottom: GPS card, controls, hint
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, media.padding.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _gpsCard(),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassSquare(
                        Icons.photo_library_rounded,
                        () => context.push('/video-gallery'),
                      ),
                      _recordButton(),
                      _glassRound(
                        Icons.flip_camera_ios_rounded,
                        _toggleCamera,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: _isInitialized && !_isRecording ? 1 : 0,
                    child: Text(
                      t.videoMaxDuration(_maxRecordSeconds).toUpperCase(),
                      style: Aurora.text(
                        11,
                        weight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.7),
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recPill(AppLocalizations t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.black.withValues(alpha: 0.45),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Aurora.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.secondary.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                t.videoRecording,
                style: Aurora.text(
                  11,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ).copyWith(letterSpacing: 1),
              ),
              const SizedBox(width: 8),
              Text(
                t.videoDuration(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(double value) {
    return LayoutBuilder(
      builder: (context, c) => Container(
        height: 4,
        width: double.infinity,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: c.maxWidth * value,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Aurora.primary, Color(0xFFFE4C8C), Aurora.secondary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _gpsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Aurora.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _liveAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(
                              13.5,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          size: 16,
                          color: Color(0xFF22D3EE),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_liveLatitude.toStringAsFixed(4)}, ${_liveLongitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
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

  Widget _glassSquare(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 48,
            height: 48,
            color: Colors.black.withValues(alpha: 0.4),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _glassRound(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 48,
            height: 48,
            color: Colors.black.withValues(alpha: 0.35),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _recordButton() {
    return GestureDetector(
      onTap: _toggleRecord,
      child: Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: Aurora.secondary.withValues(alpha: 0.55),
              blurRadius: 24,
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _isRecording ? 32 : 56,
          height: _isRecording ? 32 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_isRecording ? 10 : 28),
            gradient: const LinearGradient(
              colors: [Color(0xFFB90A5A), Color(0xFFFE4C8C)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: _isRecording
              ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
