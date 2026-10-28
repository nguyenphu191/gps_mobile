import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/models/location_history_model.dart';

class TimelineEntry extends StatelessWidget {
  final LocationHistoryModel entry;
  final bool isFirst;
  final bool isLast;

  const TimelineEntry({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail: continuous line with a dot on it.
          SizedBox(
            width: 28,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: isFirst ? 22 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 22 : null,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isFirst
                            ? const [Aurora.secondary, Color(0xFFE6DEFF)]
                            : const [Color(0xFFE6DEFF), Color(0xFFE6DEFF)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: isFirst ? 12 : 9,
                      height: isFirst ? 12 : 9,
                      decoration: BoxDecoration(
                        color: isFirst ? Aurora.secondary : Aurora.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Aurora.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? const Color(0xFFFFD9E0)
                          : const Color(0xFFEADDFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(entry.timestamp),
                      style: Aurora.text(
                        11,
                        weight: FontWeight.w800,
                        color: isFirst
                            ? const Color(0xFF8F0043)
                            : const Color(0xFF5A00C6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(15, weight: FontWeight.w700, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.explore_rounded,
                        size: 14,
                        color: Color(0xFF007181),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${entry.latitude.toStringAsFixed(6)}, ${entry.longitude.toStringAsFixed(6)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A4455),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy  HH:mm:ss').format(entry.timestamp),
                    style: Aurora.text(12, color: Aurora.subText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
