import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// A place returned by the search provider.
class PlaceResult {
  final String name;
  final String? subtitle;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.name,
    this.subtitle,
    required this.latitude,
    required this.longitude,
  });
}

/// Forward/reverse place lookup used by the Street View screen.
///
/// Forward search uses Nominatim (OpenStreetMap) — free and key-less, matching
/// the OSM tiles used by the maps in this app. Reverse lookup reuses the
/// `geocoding` package already used by [LocationService].
class PlaceSearchService {
  static const String _host = 'nominatim.openstreetmap.org';

  // Nominatim rejects requests without an identifying User-Agent.
  static const Map<String, String> _headers = {
    'User-Agent': 'GPSCameraStamp/1.0 (com.gpscamerastamp.app)',
    'Accept': 'application/json',
  };

  /// Search places by free-text query. Returns an empty list on any failure.
  Future<List<PlaceResult>> search(String query, {String? lang}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final uri = Uri.https(_host, '/search', {
        'q': trimmed,
        'format': 'jsonv2',
        'limit': '8',
        'addressdetails': '1',
        'accept-language': ?lang,
      });

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) return const [];

      final results = <PlaceResult>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final lat = double.tryParse('${item['lat']}');
        final lon = double.tryParse('${item['lon']}');
        if (lat == null || lon == null) continue;

        final display = (item['display_name'] as String?) ?? '';
        final name = (item['name'] as String?)?.trim();
        final head = (name != null && name.isNotEmpty)
            ? name
            : display.split(',').first.trim();
        final tail = display.startsWith(head)
            ? display.substring(head.length).replaceFirst(RegExp(r'^,\s*'), '')
            : display;

        results.add(
          PlaceResult(
            name: head.isNotEmpty ? head : display,
            subtitle: tail.isNotEmpty ? tail : null,
            latitude: lat,
            longitude: lon,
          ),
        );
      }
      return results;
    } catch (_) {
      return const [];
    }
  }

  /// Human-readable address for coordinates picked by tapping the map.
  Future<String?> reverse(double latitude, double longitude) async {
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
    } catch (_) {
      return null;
    }
  }
}

final placeSearchServiceProvider = Provider<PlaceSearchService>(
  (ref) => PlaceSearchService(),
);
