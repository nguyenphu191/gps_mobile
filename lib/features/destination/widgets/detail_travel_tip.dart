import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';

class DetailTravelTip extends StatelessWidget {
  final String tip;
  const DetailTravelTip({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7E0), Color(0xFFFFE9D6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: Aurora.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: Aurora.sunnyGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).travelTip,
                  style: Aurora.text(
                    12,
                    weight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip,
                  style: Aurora.text(
                    13.5,
                    color: Aurora.darkText,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
