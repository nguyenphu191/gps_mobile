import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_coord_card.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';

class DetailCoordsRow extends StatelessWidget {
  final DestinationModel dest;
  const DetailCoordsRow({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: DetailCoordCard(
            label: t.latitude,
            value: dest.latitude.toStringAsFixed(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DetailCoordCard(
            label: t.longitude,
            value: dest.longitude.toStringAsFixed(6),
          ),
        ),
      ],
    );
  }
}
