import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';

class TrafficLegend extends StatelessWidget {
  const TrafficLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 168,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.trafficLayer.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Aurora.text(
                  11,
                  weight: FontWeight.w800,
                  color: const Color(0xFF4A4455),
                ).copyWith(letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendItem(
                    color: const Color(0xFF10B981),
                    label: t.trafficLegendFree,
                  ),
                  _LegendItem(
                    color: const Color(0xFFF59E0B),
                    label: t.trafficLegendSlow,
                  ),
                  _LegendItem(
                    color: const Color(0xFFEF4444),
                    label: t.trafficLegendHeavy,
                  ),
                  _LegendItem(
                    color: const Color(0xFF881337),
                    label: t.trafficLegendJam,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Aurora.text(12, weight: FontWeight.w600)),
      ],
    );
  }
}
