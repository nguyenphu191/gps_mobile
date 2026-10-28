import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';

class DetailFactsRow extends StatelessWidget {
  final DestinationModel dest;
  const DetailFactsRow({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final facts = <_FactData>[];
    if (dest.timezone.isNotEmpty)
      facts.add(
        _FactData(
          icon: Icons.schedule_rounded,
          label: t.timezoneLabel,
          value: dest.timezone,
          iconColor: Aurora.primary,
          iconBg: const Color(0xFFEDE4FF),
        ),
      );
    if (dest.language.isNotEmpty)
      facts.add(
        _FactData(
          icon: Icons.translate_rounded,
          label: t.language,
          value: dest.language,
          iconColor: Aurora.secondary,
          iconBg: const Color(0xFFFFD9E0),
        ),
      );
    if (dest.currency.isNotEmpty)
      facts.add(
        _FactData(
          icon: Icons.attach_money_rounded,
          label: t.currencyLabel,
          value: dest.currency,
          iconColor: const Color(0xFF0891B2),
          iconBg: const Color(0xFFCFFAFE),
        ),
      );
    if (facts.isEmpty) return const SizedBox.shrink();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: facts.asMap().entries.map((e) {
          final isLast = e.key == facts.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 10),
              child: _FactCard(data: e.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FactData {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;
  const _FactData({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });
}

class _FactCard extends StatelessWidget {
  final _FactData data;
  const _FactCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Aurora.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, size: 17, color: data.iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Aurora.hint,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Aurora.darkText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
