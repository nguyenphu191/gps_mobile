import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class PermissionState {
  final PermissionStatus cameraStatus;
  final PermissionStatus locationStatus;

  const PermissionState({
    this.cameraStatus = PermissionStatus.denied,
    this.locationStatus = PermissionStatus.denied,
  });

  bool get allGranted => cameraStatus.isGranted && locationStatus.isGranted;

  bool get cameraGranted => cameraStatus.isGranted;
  bool get locationGranted => locationStatus.isGranted;

  PermissionState copyWith({
    PermissionStatus? cameraStatus,
    PermissionStatus? locationStatus,
  }) {
    return PermissionState(
      cameraStatus: cameraStatus ?? this.cameraStatus,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(const PermissionState()) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final camera = await Permission.camera.status;
    final location = await Permission.location.status;
    state = PermissionState(cameraStatus: camera, locationStatus: location);
  }

  Future<bool> requestCamera() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    final status = await Permission.camera.request();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
    state = state.copyWith(cameraStatus: status);
    return status.isGranted;
  }

  Future<bool> requestLocation() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    final status = await Permission.location.request();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
    state = state.copyWith(locationStatus: status);
    return status.isGranted;
  }

  Future<bool> requestAll() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    final statuses = await [Permission.camera, Permission.location].request();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
    state = PermissionState(
      cameraStatus: statuses[Permission.camera] ?? PermissionStatus.denied,
      locationStatus: statuses[Permission.location] ?? PermissionStatus.denied,
    );
    return state.allGranted;
  }

  Future<void> openSettings() => openAppSettings();
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>(
      (ref) => PermissionNotifier(),
    );
