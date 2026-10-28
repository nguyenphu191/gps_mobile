import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurora.dart';
import '../../notifications/services/notification_service.dart';

class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => Aurora.primaryGradient.createShader(b),
                child: Text(
                  'GPS',
                  style: Aurora.text(
                    24,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(' Camera', style: Aurora.text(24, weight: FontWeight.w800)),
            ],
          ),
          Row(
            children: [
              if (AppConstants.showPremium) ...[
                const _TopIcon(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: Aurora.sunnyEnd,
                ),
                const SizedBox(width: 10),
              ],
              _TopIcon(
                icon: Icons.notifications_none_rounded,
                badgeCount: unread,
                onTap: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int badgeCount;
  final VoidCallback? onTap;

  const _TopIcon({
    required this.icon,
    this.iconColor = Aurora.darkText,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 24, color: iconColor),
            if (badgeCount > 0)
              Positioned(
                top: 2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  decoration: BoxDecoration(
                    color: Aurora.secondary,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Aurora.secondary.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: Aurora.text(
                        9,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
