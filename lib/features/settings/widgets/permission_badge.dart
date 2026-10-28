import 'package:flutter/material.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';

class PermissionBadge extends StatelessWidget {
  final bool granted;

  const PermissionBadge({super.key, required this.granted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: granted
            ? AppConstants.successColor.withValues(alpha: 0.1)
            : AppConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        granted ? 'Granted' : 'Denied',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: granted ? AppConstants.successColor : AppConstants.errorColor,
        ),
      ),
    );
  }
}
