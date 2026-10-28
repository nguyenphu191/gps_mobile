import 'package:flutter/material.dart';
import '../../../core/theme/aurora.dart';
import '../../../core/localization/app_localizations.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Aurora.text(18, weight: FontWeight.w800),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              t.viewAll,
              style: Aurora.text(
                13,
                weight: FontWeight.w700,
                color: Aurora.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
