import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Round icon button used for headers on the screens that have no AppBar.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  /// Filled with the CTA gradient and a white icon instead of the flat
  /// light-grey treatment.
  final bool gradient;

  /// White fill with a soft drop shadow, so the button reads as floating above
  /// the content instead of sitting flat on it. Ignored when [gradient] is set.
  final bool elevated;

  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 18,
    this.gradient = false,
    this.elevated = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient
            ? null
            : (elevated ? Colors.white : const Color(0xFFF1F5F9)),
        gradient: gradient ? AppConstants.ctaGradient : null,
        shape: BoxShape.circle,
        // Two shadows: a wide soft one for the lift, a tight one right under
        // the edge so the circle keeps a crisp outline against white pages.
        boxShadow: elevated && !gradient
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: iconSize,
            color: gradient ? Colors.white : AppConstants.darkButton,
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
