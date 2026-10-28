import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationNotifier extends StateNotifier<LocationPermission> {
  LocationNotifier() : super(LocationPermission.denied);

  Future<void> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    state = permission;
  }

  Future<void> requestPermission() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    final permission = await Geolocator.requestPermission();
    state = permission;
  }
}

final currentLocationProvider = FutureProvider<Position>((ref) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
    permission = await Geolocator.requestPermission();
    Future.delayed(const Duration(milliseconds: 500), () {
      // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
    });
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied');
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services disabled');
  }

  return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
});

final currentAddressProvider = FutureProvider<String>((ref) async {
  final position = await ref.watch(currentLocationProvider.future);
  try {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) return 'Unknown location';
    final place = placemarks.first;
    final parts = [
      place.street,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
  } catch (_) {
    return 'Address unavailable';
  }
});
