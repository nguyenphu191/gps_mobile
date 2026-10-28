import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';

// Overlay pieces for the map. They are plain widgets (not Positioned): the
// screen lays them out inside its own Stack/Column.

// ── Back button ────────────────────────────────────────────────────────────────

class MapBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const MapBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Aurora.darkText,
        ),
      ),
    );
  }
}

// ── Title pill (full-screen mode) ──────────────────────────────────────────────

class MapTitlePill extends StatelessWidget {
  final String title;

  const MapTitlePill({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Aurora.text(16, weight: FontWeight.w800),
      ),
    );
  }
}

// ── Date filter chip ───────────────────────────────────────────────────────────

class MapDateFilterChip extends StatelessWidget {
  final DateTimeRange dateFilter;
  final VoidCallback onClear;

  const MapDateFilterChip({
    super.key,
    required this.dateFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Aurora.darkText.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 17,
            color: Aurora.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${fmt.format(dateFilter.start)} – ${fmt.format(dateFilter.end)}',
            style: Aurora.text(13, weight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFCCC3D8).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: Aurora.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo count badge ──────────────────────────────────────────────────────────

class MapPhotoCountBadge extends StatelessWidget {
  final int count;

  const MapPhotoCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Aurora.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Aurora.secondary.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).photosCount(count),
            style: Aurora.text(12, weight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ── Map tools (locate + zoom) ──────────────────────────────────────────────────

class MapToolButtons extends StatelessWidget {
  final VoidCallback? onLocate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapToolButtons({
    super.key,
    required this.onLocate,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  BoxDecoration get _glass => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.9),
    boxShadow: [
      BoxShadow(
        color: Aurora.darkText.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  Widget _btn(IconData icon, VoidCallback? onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: onTap == null
                ? Aurora.hint
                : (color ?? Aurora.darkText),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: _glass.copyWith(shape: BoxShape.circle),
          child: _btn(Icons.near_me_rounded, onLocate, color: Aurora.primary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: _glass.copyWith(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _btn(Icons.add_rounded, onZoomIn),
              Container(
                width: 20,
                height: 1,
                color: const Color(0xFFCCC3D8).withValues(alpha: 0.4),
              ),
              _btn(Icons.remove_rounded, onZoomOut),
            ],
          ),
        ),
      ],
    );
  }
}
