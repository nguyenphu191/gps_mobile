import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';
import 'services/notification_service.dart';
import 'widgets/notification_tile.dart';
import '../../shared/widgets/aurora_motion_widgets.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 240, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 80, size: 300, color: Aurora.aqua),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: Aurora.cardShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Aurora.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          t.notificationsTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(22, weight: FontWeight.w800),
                        ),
                      ),
                      if (unread > 0)
                        GestureDetector(
                          onTap: () => ref
                              .read(notificationServiceProvider)
                              ?.markAllRead(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EBFF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 18,
                                  color: Aurora.primary,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 110),
                                  child: Text(
                                    t.markAllRead,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Aurora.text(
                                      12,
                                      weight: FontWeight.w700,
                                      color: Aurora.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: notificationsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Aurora.primary),
                    ),
                    error: (_, _) => Center(
                      child: Text(
                        t.errorGeneral,
                        style: Aurora.text(14, color: Aurora.subText),
                      ),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return _EmptyState(message: t.notificationsEmpty);
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => FadeSlideIn.indexed(
                          key: ValueKey(items[index].id),
                          index: index,
                          child: NotificationTile(notification: items[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Aurora.primary.withValues(alpha: 0.35),
                          Aurora.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECE4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 42,
                      color: Aurora.primary,
                    ),
                  ),
                  const Positioned(
                    top: 4,
                    right: 6,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 22,
                      color: Aurora.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Aurora.text(18, weight: FontWeight.w800, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
