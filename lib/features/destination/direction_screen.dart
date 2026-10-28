import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../shared/widgets/circle_icon_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gpscamerastamp/shared/utils/location_permission_helper.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';

import 'widgets/compass_widget.dart';

class DirectionScreen extends StatefulWidget {
  final DestinationModel destination;
  const DirectionScreen({super.key, required this.destination});

  @override
  State<DirectionScreen> createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  double _heading = 0;
  double _bearing = 0;
  double _distance = 0;
  Position? _currentPosition;

  // Low-pass filter values
  double _magX = 0, _magY = 0, _magZ = 0;
  double _accX = 0, _accY = 0, _accZ = 0;
  static const _alpha = 0.15; // smoothing factor

  final List<_StreamSub> _subs = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startSensors();
  }

  void _startSensors() {
    try {
      _subs.add(
        _StreamSub(
          magnetometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen((e) {
            _magX = _magX + _alpha * (e.x - _magX);
            _magY = _magY + _alpha * (e.y - _magY);
            _magZ = _magZ + _alpha * (e.z - _magZ);
            _updateHeading();
          }),
        ),
      );
      _subs.add(
        _StreamSub(
          accelerometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen((e) {
            _accX = _accX + _alpha * (e.x - _accX);
            _accY = _accY + _alpha * (e.y - _accY);
            _accZ = _accZ + _alpha * (e.z - _accZ);
            _updateHeading();
          }),
        ),
      );
    } catch (_) {
      // sensor unavailable (e.g. simulator)
    }
  }

  void _updateHeading() {
    // Calculate heading using magnetometer + gravity tilt compensation
    final ax = _accX, ay = _accY, az = _accZ;
    final mx = _magX, my = _magY, mz = _magZ;

    // Normalize accelerometer
    final accNorm = math.sqrt(ax * ax + ay * ay + az * az);
    if (accNorm == 0) return;
    final nax = ax / accNorm, nay = ay / accNorm;

    // Pitch and roll
    final pitch = math.asin(-nax);
    final roll = math.asin(nay / math.cos(pitch));

    // Tilt-compensated heading
    final magXComp = mx * math.cos(pitch) + mz * math.sin(pitch);
    final magYComp =
        mx * math.sin(roll) * math.sin(pitch) +
        my * math.cos(roll) -
        mz * math.sin(roll) * math.cos(pitch);

    double heading = math.atan2(-magYComp, magXComp) * 180 / math.pi;
    heading = (heading + 360) % 360;

    if (mounted) setState(() => _heading = heading);
  }

  Future<void> _initLocation() async {
    final granted = await checkLocationPermission(context);
    if (!granted) return;
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _bearing = _calculateBearing(
          pos.latitude,
          pos.longitude,
          widget.destination.latitude,
          widget.destination.longitude,
        );
        _distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          widget.destination.latitude,
          widget.destination.longitude,
        );
      });
    } catch (_) {}
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRad(lon2 - lon1);
    final lat1R = _toRad(lat1);
    final lat2R = _toRad(lat2);
    final y = math.sin(dLon) * math.cos(lat2R);
    final x =
        math.cos(lat1R) * math.sin(lat2R) -
        math.sin(lat1R) * math.cos(lat2R) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  double _toRad(double deg) => deg * math.pi / 180;

  Future<void> _openGoogleMaps() async {
    final dest = widget.destination;
    final Uri uri;
    if (_currentPosition != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&destination=${dest.latitude},${dest.longitude}'
        '&travelmode=driving',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${dest.latitude},${dest.longitude}',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    if (meters < 100000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${(meters / 1000).round()} km';
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final arrowAngle = (_bearing - _heading) * math.pi / 180;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          ShimmerNetworkImage(
            imageUrl: widget.destination.imageUrl,
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xAA000000),
                  Color(0x22000000),
                  Color(0x33000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.25, 0.55, 1.0],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              size: 44,
              elevated: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 60,
            right: 60,
            child: Column(
              children: [
                Text(
                  t.directionExplore,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  widget.destination.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Distance badge
          if (_currentPosition != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 88,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDistance(_distance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Go to Map button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 32,
            right: 32,
            child: GestureDetector(
              onTap: _openGoogleMaps,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.goToMap,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Compass
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 0,
            right: 0,
            child: Center(
              child: CompassWidget(
                heading: _heading,
                arrowAngle: arrowAngle,
                hasLocation: _currentPosition != null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stream subscription wrapper ────────────────────────────────────────────────

class _StreamSub {
  final dynamic _sub;
  _StreamSub(this._sub);
  void cancel() {
    try {
      _sub?.cancel();
    } catch (_) {}
  }
}
