import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/aurora.dart';
import '../../core/theme/aurora_motion.dart';

/// Shows the app's confirm dialog: blurred backdrop, spring-in card, pill
/// buttons. Returns true when the primary (destructive) action is chosen.
Future<bool> showAuroraConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  IconData icon = Icons.delete_forever_rounded,
  bool destructive = true,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: const Color(0x99322C4D),
    transitionDuration: AuroraMotion.normal,
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * anim.value,
          sigmaY: 8 * anim.value,
        ),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
    pageBuilder: (ctx, _, _) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: Aurora.modalShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: destructive
                      ? const Color(0x99FFDAD6)
                      : const Color(0xFFF1EBFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: destructive
                      ? const Color(0xFFBA1A1A)
                      : Aurora.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Aurora.text(20, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Aurora.text(14, color: Aurora.subText, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE4FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cancelLabel,
                          style: Aurora.text(13, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(ctx, true);
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: destructive
                              ? const Color(0xFFBA1A1A)
                              : null,
                          gradient: destructive ? null : Aurora.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (destructive
                                          ? const Color(0xFFBA1A1A)
                                          : Aurora.primary)
                                      .withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          confirmLabel,
                          style: Aurora.text(
                            14,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Generic Aurora dialog shell: blurred backdrop + spring-in white card.
/// [builder] returns the card's content; it is wrapped in the card chrome.
Future<T?> showAuroraDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dismiss',
    barrierColor: const Color(0x99322C4D),
    transitionDuration: AuroraMotion.normal,
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * anim.value,
          sigmaY: 8 * anim.value,
        ),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
    pageBuilder: (ctx, _, _) => PopScope(
      canPop: barrierDismissible,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: Aurora.modalShadow,
              ),
              child: builder(ctx),
            ),
          ),
        ),
      ),
    ),
  );
}
