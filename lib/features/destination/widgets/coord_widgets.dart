import 'package:flutter/material.dart';
import '../../../shared/widgets/app_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Coordinate row
// ─────────────────────────────────────────────────────────────────────────────
class CoordRow extends StatelessWidget {
  final DestinationModel dest;
  const CoordRow({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: CoordCard(
            label: t.latitude,
            value: dest.latitude.toStringAsFixed(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CoordCard(
            label: t.longitude,
            value: dest.longitude.toStringAsFixed(6),
          ),
        ),
      ],
    );
  }
}

class CoordCard extends StatelessWidget {
  final String label;
  final String value;
  const CoordCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        final t = AppLocalizations.of(context);
        context.showInfoSnack(
          t.copiedText(label),
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  size: 13,
                  color: Color(0xFF8E8E93),
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                fontFamily: 'monospace',
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).holdToCopy,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF2563EB).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
