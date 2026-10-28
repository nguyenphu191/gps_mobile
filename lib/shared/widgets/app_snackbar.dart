import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';

/// One look for every transient message in the app: green for success, red for
/// failure, three seconds, floating.
///
/// Rule for callers: an exception, error code or status code **never** goes
/// into a message. Log it with `debugPrint` and show a sentence a person can
/// act on — `AppLocalizations.errorGeneral` when there is nothing better.
extension AppSnackBar on BuildContext {
  void showSuccessSnack(String message) =>
      ScaffoldMessenger.of(this)._showAppSnack(message, _SnackKind.success);

  void showErrorSnack(String message) =>
      ScaffoldMessenger.of(this)._showAppSnack(message, _SnackKind.error);

  void showInfoSnack(String message, {Duration? duration}) =>
      ScaffoldMessenger.of(
        this,
      )._showAppSnack(message, _SnackKind.info, duration: duration);
}

/// Same helpers for code that captured the messenger before an `await`
/// (the safe pattern across async gaps).
extension AppSnackBarMessenger on ScaffoldMessengerState {
  void showSuccessSnack(String message) =>
      _showAppSnack(message, _SnackKind.success);

  void showErrorSnack(String message) =>
      _showAppSnack(message, _SnackKind.error);

  void showInfoSnack(String message, {Duration? duration}) =>
      _showAppSnack(message, _SnackKind.info, duration: duration);

  void _showAppSnack(String message, _SnackKind kind, {Duration? duration}) {
    // Replace rather than queue: stacked snackbars shove the UI around.
    clearSnackBars();
    HapticFeedback.lightImpact();
    showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kind.background,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: kind.background.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(kind.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SnackKind {
  success,
  error,
  info;

  Color get background => switch (this) {
    _SnackKind.success => const Color(0xFF0E9F6E),
    _SnackKind.error => const Color(0xFFE11D48),
    _SnackKind.info => const Color(0xFF322C4D),
  };

  IconData get icon => switch (this) {
    _SnackKind.success => Icons.check_circle_rounded,
    _SnackKind.error => Icons.error_outline_rounded,
    _SnackKind.info => Icons.info_outline_rounded,
  };
}

/// Friendly stand-in for a failed async load, replacing `Text('Error: $e')`.
class AppErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? t.errorGeneral,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: Text(t.retry)),
            ],
          ],
        ),
      ),
    );
  }
}
