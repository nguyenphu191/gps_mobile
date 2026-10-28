import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../models/location_share_model.dart';
import '../providers/friend_profiles_provider.dart';
import '../providers/unread_shares_provider.dart';
import '../services/friend_service.dart';

/// Locations friends sent me. Without this the shares are invisible — they
/// only ever existed as markers behind two taps on the friend map.
class ReceivedLocationsSection extends ConsumerWidget {
  const ReceivedLocationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final shares = ref.watch(receivedLocationsProvider).valueOrNull ?? const [];
    final profiles = ref.watch(friendProfilesProvider).valueOrNull ?? const {};
    if (shares.isEmpty) return const SizedBox.shrink();

    // Seeing this list counts as reading it — clears the Home badge.
    final newest = shares.first.createdAt.millisecondsSinceEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastSeenShareProvider.notifier).markSeen(newest);
    });

    final visible = shares.take(5).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Aurora.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 18,
                    color: Color(0xFFB90A5A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.receivedLocations,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(18, weight: FontWeight.w800),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/shared-locations'),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.viewAll,
                          style: Aurora.text(
                            13,
                            weight: FontWeight.w700,
                            color: Aurora.primary,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Aurora.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 232,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final share = visible[i];
                final profile = profiles[share.fromUid];
                return _ShareCard(
                  share: share,
                  // Live profile first: the copy stored on the share can be
                  // months out of date.
                  photoUrl: profile?.photoUrl.isNotEmpty == true
                      ? profile!.photoUrl
                      : share.fromPhotoUrl,
                  name: profile?.username.isNotEmpty == true
                      ? profile!.username
                      : share.fromName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final LocationShareModel share;
  final String? photoUrl;
  final String name;

  const _ShareCard({
    required this.share,
    required this.photoUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final coords =
        '${share.latitude.toStringAsFixed(3)}°, ${share.longitude.toStringAsFixed(3)}°';

    Widget chip(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );

    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.12),
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
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: Aurora.aquaViolet,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: chip(
                    Text(
                      coords,
                      style: Aurora.text(9, weight: FontWeight.w800),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: chip(
                    Text(
                      DateFormat('MMM dd, HH:mm').format(share.createdAt),
                      style: Aurora.text(10, weight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  gradient: Aurora.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: UserAvatar(photoUrl: photoUrl, name: name, radius: 14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.sharedBy(share.fromName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Aurora.text(11, color: Aurora.subText),
                    ),
                    Text(
                      share.address.isNotEmpty ? share.address : coords,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Aurora.text(13, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push(
              '/friend-map?lat=${share.latitude}&lng=${share.longitude}',
            ),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFECE4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: Aurora.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.view,
                    style: Aurora.text(
                      13,
                      weight: FontWeight.w700,
                      color: Aurora.primary,
                    ),
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
