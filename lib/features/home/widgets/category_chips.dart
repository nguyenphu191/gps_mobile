import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';

class NearbyCategory {
  final String label;
  final String emoji;
  final String query;

  const NearbyCategory(this.label, this.emoji, this.query);
}

List<NearbyCategory> buildNearbyCategories(AppLocalizations t) => [
  NearbyCategory(t.petrol, '⛽', 'petrol station near me'),
  NearbyCategory(t.atm, '🏧', 'ATM near me'),
  NearbyCategory(t.cafe, '☕', 'cafe near me'),
  NearbyCategory(t.hotel, '🏨', 'hotel near me'),
  NearbyCategory(t.hospital, '🏥', 'hospital near me'),
];

class _CategoryChip extends StatelessWidget {
  final NearbyCategory cat;

  const _CategoryChip({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(
          'https://www.google.com/maps/search/${Uri.encodeComponent(cat.query)}',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 8),
            Text(cat.label, style: Aurora.text(12.5, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class CategoryChipList extends StatelessWidget {
  const CategoryChipList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categories = buildNearbyCategories(t);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _CategoryChip(cat: categories[index]),
      ),
    );
  }
}
