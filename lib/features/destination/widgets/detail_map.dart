import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';

class DetailMap extends StatelessWidget {
  final DestinationModel dest;
  const DetailMap({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(dest.latitude, dest.longitude),
            initialZoom: 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              subdomains: const ['0', '1', '2', '3'],
              userAgentPackageName: 'com.gpscamera.app',
              errorTileCallback: (tile, error, stackTrace) {},
              tileBuilder: (context, tile, _) => ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Aurora.primary.withValues(alpha: 0.12),
                  BlendMode.srcATop,
                ),
                child: tile,
              ),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(dest.latitude, dest.longitude),
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: Aurora.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.45),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
