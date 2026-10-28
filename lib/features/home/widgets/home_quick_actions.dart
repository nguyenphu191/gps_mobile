import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurora.dart';

/// The three shortcuts under the hero banner.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.videocam_rounded,
              tint: const Color(0x99A2EEFF),
              iconColor: const Color(0xFF005763),
              label: t.gpsVideo,
              onTap: () => context.push(AppRoutes.videoCamera),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAction(
              icon: Icons.streetview_rounded,
              tint: const Color(0xFFFFD9E0),
              iconColor: const Color(0xFF8F0043),
              label: t.streetView,
              onTap: () => context.push(AppRoutes.streetViewRoute),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAction(
              icon: Icons.traffic_rounded,
              tint: const Color(0xFFEADDFF),
              iconColor: const Color(0xFF630ED4),
              label: t.trafficMap,
              onTap: () => context.push(AppRoutes.trafficMapRoute),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, size: 26, color: widget.iconColor),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Aurora.text(12, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
