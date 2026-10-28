import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ads/capture_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:uuid/uuid.dart';
import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/models/photo_model.dart';
import 'package:gpscamerastamp/shared/widgets/app_snackbar.dart';
import 'package:gpscamerastamp/shared/providers/gallery_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gpscamerastamp/shared/utils/location_permission_helper.dart';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/app_localizations.dart';
import '../sharing/services/upload_queue.dart';

import 'widgets/camera_view.dart';
import 'widgets/image_stamper.dart';
import 'widgets/photo_preview.dart';

class GpsCameraScreen extends ConsumerStatefulWidget {
  const GpsCameraScreen({super.key});

  @override
  ConsumerState<GpsCameraScreen> createState() => _GpsCameraScreenState();
}

class _GpsCameraScreenState extends ConsumerState<GpsCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _cameraPermissionDenied = false;
  bool _isCapturing = false;
  bool _showPreview = false;
  String? _capturedImagePath;
  Position? _capturedPosition;
  String _capturedAddress = '';
  DateTime? _capturedTime;

  // Live location state
  double _liveLatitude = 0;
  double _liveLongitude = 0;
  String _liveAddress = '';
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.cameraView);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
      _updateLiveLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraPermissionDenied) {
        setState(() {
          _cameraPermissionDenied = false;
          _isInitialized = false;
        });
        _initCamera();
      } else if (_cameraController != null &&
          _cameraController!.value.isInitialized) {
        _initCamera();
      }
      if (mounted &&
          _liveAddress == AppLocalizations.of(context).enableLocation) {
        _updateLiveLocation();
      }
    }
  }

  Future<void> _initCamera() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    final status = await Permission.camera.status;
    final resolved = status.isDenied
        ? await Permission.camera.request()
        : status;

    if (!resolved.isGranted) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      });
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      });
      return;
    }

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
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
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

    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
  }

  Future<void> _updateLiveLocation() async {
    final permission = await Geolocator.checkPermission();
    var resolved = permission;
    if (permission == LocationPermission.denied) {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      resolved = await Geolocator.requestPermission();
      Future.delayed(const Duration(milliseconds: 500), () {
        // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      });
    }
    final granted =
        resolved == LocationPermission.whileInUse ||
        resolved == LocationPermission.always;
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
          final t = AppLocalizations.of(context);
          setState(() {
            _liveAddress = parts.isNotEmpty
                ? parts.join(', ')
                : t.unknownLocation;
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

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    final granted = await checkLocationPermission(context);
    if (!granted) return;

    setState(() => _isCapturing = true);
    try {
      final xFile = await _cameraController!.takePicture();
      final now = DateTime.now();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String address = AppLocalizations.of(context).unknownLocation;
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

      final stampedPath = await generateStampedImage(
        xFile.path,
        position.latitude,
        position.longitude,
        address,
        now,
      );

      if (mounted) {
        getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoCaptured);

        // Returns immediately unless this is the capture that earns an ad.
        await showPhotoCaptureAd(context, ref);
        if (!mounted) return;

        setState(() {
          _capturedImagePath = stampedPath;
          _capturedPosition = position;
          _capturedAddress = address;
          _capturedTime = now;
          _showPreview = true;
          _isCapturing = false;
        });
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
        // The exception is already in the log above; users get plain words.
        context.showErrorSnack(AppLocalizations.of(context).captureFailed);
      }
    }
  }

  Future<void> _savePhoto() async {
    if (_capturedImagePath == null ||
        _capturedPosition == null ||
        _capturedTime == null)
      return;

    try {
      await Gal.putImage(_capturedImagePath!);
    } catch (e) {
      debugPrint('Gallery save error: $e');
    }

    final photo = PhotoModel(
      id: const Uuid().v4(),
      imagePath: _capturedImagePath!,
      latitude: _capturedPosition!.latitude,
      longitude: _capturedPosition!.longitude,
      address: _capturedAddress,
      timestamp: _capturedTime!,
      // Stamped so another account signing in on this device does not inherit
      // it as their own.
      ownerUid: FirebaseAuth.instance.currentUser?.uid,
    );

    await ref.read(galleryProvider.notifier).addPhoto(photo);
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoSaved);

    // Share with friends in the background; silently skipped when signed out.
    unawaited(
      ref
          .read(uploadQueueProvider)
          .enqueue(
            id: photo.id,
            filePath: photo.imagePath,
            kind: MediaKind.photo,
            latitude: photo.latitude,
            longitude: photo.longitude,
            address: photo.address,
            timestamp: photo.timestamp,
          ),
    );

    if (mounted) {
      context.showSuccessSnack(AppLocalizations.of(context).photoSavedLibrary);
      setState(() {
        _showPreview = false;
        _capturedImagePath = null;
      });
    }
  }

  void _retakePhoto() {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoRetaken);
    setState(() {
      _showPreview = false;
      _capturedImagePath = null;
    });
  }

  Future<void> _toggleFlash() async {
    final next = _flashMode == FlashMode.off
        ? FlashMode.auto
        : _flashMode == FlashMode.auto
        ? FlashMode.always
        : FlashMode.off;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.flashToggled,
      parameters: {'mode': next.name},
    );
    if (mounted) setState(() => _flashMode = next);
    try {
      await _cameraController?.setFlashMode(next);
    } catch (_) {}
  }

  void _toggleCamera() {
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.cameraSwitchToggled,
      parameters: {'to_front': !_isFrontCamera ? 'true' : 'false'},
    );
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });
    _cameraController?.dispose();
    _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview && _capturedImagePath != null) {
      return PhotoPreview(
        imagePath: _capturedImagePath!,
        onRetake: _retakePhoto,
        onSave: _savePhoto,
      );
    }
    return CameraView(
      isInitialized: _isInitialized,
      cameraPermissionDenied: _cameraPermissionDenied,
      cameraController: _cameraController,
      isCapturing: _isCapturing,
      liveAddress: _liveAddress,
      liveLatitude: _liveLatitude,
      liveLongitude: _liveLongitude,
      onCapture: _capturePhoto,
      onToggleCamera: _toggleCamera,
      onBack: () => Navigator.of(context).pop(),
    );
  }
}
