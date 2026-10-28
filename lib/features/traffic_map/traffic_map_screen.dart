import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import 'widgets/traffic_legend.dart';

class TrafficMapScreen extends StatefulWidget {
  const TrafficMapScreen({super.key});

  @override
  State<TrafficMapScreen> createState() => _TrafficMapScreenState();
}

class _TrafficMapScreenState extends State<TrafficMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  bool _showTraffic = true;

  // IMPORTANT: For production, a valid API key must be used.
  // We use a placeholder here and inform the user.
  final String _tomtomApiKey = 'K6UqiyT7koAEihrEzwTgB20TImLHVMT2';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _isLoadingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentPosition = const LatLng(
              0,
              0,
            ); // Default to (0,0) if no permission
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = const LatLng(0, 0);
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _recenter() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    }
  }

  Widget _userDot() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20 + 28 * _pulse.value,
            height: 20 + 28 * _pulse.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Aurora.primary.withValues(alpha: 0.25 * (1 - _pulse.value)),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: Aurora.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          if (!_isLoadingLocation && _currentPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  userAgentPackageName: 'com.gpscamerastamp.app',
                  tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Aurora.primary.withValues(alpha: 0.06),
                      BlendMode.srcATop,
                    ),
                    child: tileWidget,
                  ),
                ),
                if (_showTraffic)
                  TileLayer(
                    urlTemplate:
                        'https://api.tomtom.com/traffic/map/4/tile/flow/relative0/{z}/{x}/{y}.png?key=$_tomtomApiKey',
                    userAgentPackageName: 'com.gpscamerastamp.app',
                    // Using a placeholder API key will likely result in 403 errors loading tiles
                    // We catch it silently here but we should instruct user to provide valid key.
                    errorTileCallback: (tile, error, stackTrace) {
                      // Silently ignore tile load errors for the placeholder API key
                    },
                  ),
                if (_currentPosition != const LatLng(0, 0))
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 52,
                        height: 52,
                        child: Center(child: _userDot()),
                      ),
                    ],
                  ),
              ],
            ),

          // Soft fade so the header reads over any map area.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Aurora.bgSoft.withValues(alpha: 0.8),
                      Aurora.bgSoft.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading location
          if (_isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Aurora.bgSoft.withValues(alpha: 0.7),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Aurora.secondary,
                          backgroundColor: Color(0xFFE6DEFF),
                        ),
                      ),
                      const Icon(
                        Icons.satellite_alt_rounded,
                        size: 26,
                        color: Aurora.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Header
          Positioned(
            top: media.padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.14),
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEADDFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.traffic_rounded,
                            size: 20,
                            color: Aurora.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.trafficMap,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Aurora.text(16, weight: FontWeight.w800),
                              ),
                              Text(
                                t.trafficMapSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Aurora.text(12, color: Aurora.subText),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _showTraffic,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Aurora.primary,
                          inactiveTrackColor: const Color(0xFFE6DEFF),
                          inactiveThumbColor: Colors.white,
                          trackOutlineColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          onChanged: (val) => setState(() => _showTraffic = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // API Key missing banner
          if (_tomtomApiKey == 'PLACEHOLDER_API_KEY')
            Positioned(
              top: media.padding.top + 76,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: Aurora.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        size: 18,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.trafficApiKeyMissing,
                        style: Aurora.text(
                          12.5,
                          weight: FontWeight.w600,
                          color: const Color(0xFF451A03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Zoom controls
          if (!_isLoadingLocation)
            Positioned(
              right: 16,
              top: media.padding.top + 140,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.darkText.withValues(alpha: 0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.add_rounded, size: 20),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 1,
                      color: const Color(0xFFCCC3D8).withValues(alpha: 0.4),
                    ),
                    GestureDetector(
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.remove_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Legend
          if (_showTraffic)
            Positioned(
              bottom: media.padding.bottom + 20,
              left: 16,
              child: const TrafficLegend(),
            ),

          // Current location button
          Positioned(
            bottom: media.padding.bottom + 20,
            right: 16,
            child: GestureDetector(
              onTap: _recenter,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Aurora.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.primary.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: -2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
