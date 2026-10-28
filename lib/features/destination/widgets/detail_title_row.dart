import 'package:flutter/material.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';

class DetailTitleRow extends StatelessWidget {
  final DestinationModel dest;
  const DetailTitleRow({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dest.name,
                style: Aurora.text(
                  26,
                  weight: FontWeight.w800,
                  color: Aurora.darkText,
                ).copyWith(letterSpacing: -0.6),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 17,
                    color: Aurora.secondary,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      dest.country,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Aurora.text(14, color: Aurora.subText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x1AF59E0B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                dest.rating.toStringAsFixed(1),
                style: Aurora.text(
                  16,
                  weight: FontWeight.w800,
                  color: const Color(0xFF78350F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
