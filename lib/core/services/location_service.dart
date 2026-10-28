import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final String? address;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.address,
    required this.timestamp,
  });

  LocationData copyWith({String? address}) {
    return LocationData(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      speed: speed,
      address: address ?? this.address,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      address: map['address'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LocationData>.broadcast();

  Stream<LocationData> get locationStream => _locationController.stream;

  /// Check and request location permissions.
  /// Returns true if permission is granted.
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
      permission = await Geolocator.requestPermission();
      Future.delayed(const Duration(milliseconds: 500), () {
        // EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(false);
      });
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get the current device position with address.
  Future<LocationData?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        timestamp: position.timestamp,
      );

      // Try to get address
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return locationData.copyWith(address: address);
    } catch (e) {
      return null;
    }
  }

  /// Reverse geocode coordinates to a human-readable address.
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[
        if (place.street != null && place.street!.isNotEmpty) place.street!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];

      return parts.isNotEmpty ? parts.join(', ') : null;
    } catch (e) {
      return null;
    }
  }

  /// Start streaming location updates.
  void startLocationUpdates({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            distanceFilter: distanceFilter,
          ),
        ).listen(
          (position) async {
            final address = await getAddressFromCoordinates(
              position.latitude,
              position.longitude,
            );

            final locationData = LocationData(
              latitude: position.latitude,
              longitude: position.longitude,
              altitude: position.altitude,
              accuracy: position.accuracy,
              speed: position.speed,
              address: address,
              timestamp: position.timestamp,
            );

            _locationController.add(locationData);
          },
          onError: (error) {
            // Silently handle stream errors
          },
        );
  }

  /// Stop streaming location updates.
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculate distance between two points in meters.
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Open device location settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}

// Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentLocationProvider = FutureProvider<LocationData?>((ref) async {
  final service = ref.read(locationServiceProvider);
  return service.getCurrentPosition();
});

final locationStreamProvider = StreamProvider<LocationData>((ref) {
  final service = ref.read(locationServiceProvider);
  service.startLocationUpdates();
  ref.onDispose(() => service.stopLocationUpdates());
  return service.locationStream;
});
