import 'package:flutter/material.dart';
import '../../../shared/widgets/app_snackbar.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/aurora.dart';
import '../../../core/localization/app_localizations.dart';

class DetailCoordCard extends StatelessWidget {
  final String label, value;
  const DetailCoordCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        context.showInfoSnack(
          AppLocalizations.of(context).copiedText(label),
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: Aurora.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  size: 14,
                  color: Aurora.secondary,
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Aurora.hint,
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Aurora.darkText,
                fontFamily: 'monospace',
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).holdToCopy,
              style: TextStyle(
                fontSize: 10,
                color: Aurora.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
