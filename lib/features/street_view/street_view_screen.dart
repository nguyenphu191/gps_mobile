import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/place_search_service.dart';
import '../../shared/providers/language_provider.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/circle_icon_button.dart';

/// Pick a place (by search or by tapping the map), then open a movable
/// Street View panorama there.
class StreetViewScreen extends ConsumerStatefulWidget {
  /// Optional starting point: opened from a destination, a photo or a video,
  /// the screen should land on that spot instead of the user's own location.
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialName;

  const StreetViewScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialName,
  });

  @override
  ConsumerState<StreetViewScreen> createState() => _StreetViewScreenState();
}

class _StreetViewScreenState extends ConsumerState<StreetViewScreen> {
  static const LatLng _fallbackCenter = LatLng(21.0278, 105.8342); // Hanoi

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  int _requestId = 0;

  List<PlaceResult> _results = const [];
  bool _isSearching = false;
  bool _searchedOnce = false;

  LatLng? _selected;
  String? _selectedName;
  bool _resolvingName = false;

  LatLng _center = _fallbackCenter;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();

    final lat = widget.initialLatitude;
    final lng = widget.initialLongitude;
    if (lat != null && lng != null) {
      // Given a point, don't ask for location permission or jump to wherever
      // the user happens to be standing.
      _selected = LatLng(lat, lng);
      _selectedName = widget.initialName;
      _center = _selected!;
      _isLoadingLocation = false;
      return;
    }

    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    LatLng center = _fallbackCenter;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        center = LatLng(position.latitude, position.longitude);
      }
    } catch (_) {
      // Keep the fallback center.
    }
    if (!mounted) return;
    setState(() {
      _center = center;
      _isLoadingLocation = false;
    });
  }

  // ─── Search ───────────────────────────────────────────────────

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _isSearching = false;
        _searchedOnce = false;
      });
      return;
    }
    // Nominatim allows roughly one request per second.
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    setState(() => _isSearching = true);

    final lang = ref.read(localeProvider).languageCode;
    final results = await ref
        .read(placeSearchServiceProvider)
        .search(query, lang: lang);

    if (!mounted || id != _requestId) return;
    setState(() {
      _results = results;
      _isSearching = false;
      _searchedOnce = true;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _requestId++;
    _searchController.clear();
    setState(() {
      _results = const [];
      _isSearching = false;
      _searchedOnce = false;
    });
  }

  // ─── Selection ────────────────────────────────────────────────

  void _selectResult(PlaceResult place) {
    _searchFocus.unfocus();
    _requestId++; // drop any in-flight search
    setState(() {
      _selected = LatLng(place.latitude, place.longitude);
      _selectedName = place.name;
      _results = const [];
      _isSearching = false;
      _searchedOnce = false;
    });
    _searchController.text = place.name;
    _mapController.move(_selected!, 16);
  }

  Future<void> _selectPoint(LatLng point) async {
    _searchFocus.unfocus();
    setState(() {
      _selected = point;
      _selectedName = null;
      _resolvingName = true;
      _results = const [];
      _searchedOnce = false;
    });
    _mapController.move(point, _mapController.camera.zoom);

    final name = await ref
        .read(placeSearchServiceProvider)
        .reverse(point.latitude, point.longitude);

    if (!mounted || _selected != point) return;
    setState(() {
      _selectedName = name;
      _resolvingName = false;
    });
  }

  void _openStreetView() {
    final point = _selected;
    if (point == null) return;

    getIt<AnalyticsService>().logEvent(AnalyticsEvents.streetViewClick);

    final t = AppLocalizations.of(context);
    final url =
        'https://www.google.com/maps/embed/v1/streetview?key=${AppConstants.googleMapsApiKey}'
        '&location=${point.latitude},${point.longitude}&heading=0&pitch=0&fov=90';
    final title = _selectedName?.isNotEmpty == true
        ? _selectedName!
        : t.streetView;

    context.push(
      '/panorama?url=${Uri.encodeComponent(url)}'
      '&title=${Uri.encodeComponent(title)}'
      '&lat=${point.latitude}&lng=${point.longitude}&nav=1',
    );
  }

  // ─── UI ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selected ?? _center,
                // Opened at a known point: start close enough to recognise it.
                initialZoom: _selected != null ? 16 : 14,
                onTap: (_, point) => _selectPoint(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  userAgentPackageName: 'com.gpscamerastamp.app',
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF0EA5E9),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          _buildSearchArea(t),
          _buildBackButton(),
          if (_selected != null) _buildBottomBar(t),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: CircleIconButton(
          icon: Icons.arrow_back_ios_new,
          size: 44,
          elevated: true,
          onTap: () => context.pop(),
        ),
      ),
    );
  }

  Widget _buildSearchArea(AppLocalizations t) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 4, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onChanged: _onQueryChanged,
                onSubmitted: (value) {
                  _debounce?.cancel();
                  _runSearch(value);
                },
                decoration: InputDecoration(
                  hintText: t.streetViewSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSearch,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            if (_isSearching || _results.isNotEmpty || _searchedOnce)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: _buildResults(t),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AppLocalizations t) {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(t.streetViewSearching),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(t.streetViewNoResults),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _results[index];
        return ListTile(
          leading: const Icon(Icons.place_outlined, color: Color(0xFF0EA5E9)),
          title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: place.subtitle == null
              ? null
              : Text(
                  place.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: () => _selectResult(place),
        );
      },
    );
  }

  Widget _buildBottomBar(AppLocalizations t) {
    final point = _selected!;
    final subtitle =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _resolvingName
                    ? '...'
                    : (_selectedName?.isNotEmpty == true
                          ? _selectedName!
                          : t.streetViewTapMap),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: t.streetViewOpen,
                  height: 52,
                  borderRadius: 14,
                  icon: const Icon(Icons.streetview_rounded),
                  onTap: _openStreetView,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
