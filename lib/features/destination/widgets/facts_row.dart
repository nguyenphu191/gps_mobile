import 'package:flutter/material.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quick facts row (timezone · language · currency)
// ─────────────────────────────────────────────────────────────────────────────
class QuickFactsRow extends StatelessWidget {
  final DestinationModel dest;
  const QuickFactsRow({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    final facts = <FactItem>[];
    if (dest.timezone.isNotEmpty) {
      facts.add(FactItem(Icons.schedule_rounded, dest.timezone));
    }
    if (dest.language.isNotEmpty) {
      facts.add(FactItem(Icons.translate_rounded, dest.language));
    }
    if (dest.currency.isNotEmpty) {
      facts.add(FactItem(Icons.attach_money_rounded, dest.currency));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: facts.asMap().entries.map((e) {
            final isLast = e.key == facts.length - 1;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            e.value.icon,
                            size: 20,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            e.value.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3C3C43),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(width: 0.5, color: const Color(0xFFE5E5EA)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FactItem {
  final IconData icon;
  final String label;
  const FactItem(this.icon, this.label);
}
