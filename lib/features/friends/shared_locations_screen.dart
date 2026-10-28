import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/models/user_model.dart';
import 'models/location_share_model.dart';
import 'providers/friend_profiles_provider.dart';
import 'providers/unread_shares_provider.dart';
import 'services/friend_service.dart';

/// Every location friends have shared with me, with a way to delete them.
/// Shares older than 24h never appear here and are removed from Firestore.
class SharedLocationsScreen extends ConsumerStatefulWidget {
  const SharedLocationsScreen({super.key});

  @override
  ConsumerState<SharedLocationsScreen> createState() =>
      _SharedLocationsScreenState();
}

class _SharedLocationsScreenState extends ConsumerState<SharedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clean up anything the TTL policy hasn't caught up with yet.
      ref.read(friendServiceProvider)?.purgeExpiredLocationShares();
    });
  }

  Future<void> _confirmDelete(LocationShareModel share) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(friendServiceProvider);
    if (service == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
        ),
        title: Text(t.deleteLocationShare),
        content: Text(t.deleteLocationShareConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.cancel,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.delete,
              style: const TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await service.deleteLocationShare(share.id);
      messenger.showSuccessSnack(t.locationShareDeleted);
    } catch (e) {
      debugPrint('🔥 [SharedLocations] delete failed: $e');
      messenger.showErrorSnack(t.errorGeneral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sharesAsync = ref.watch(receivedLocationsProvider);
    final profiles = ref.watch(friendProfilesProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        title: Text(
          t.sharedLocationsTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: sharesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('🔥 [SharedLocations] stream error: $e');
          return const AppErrorView();
        },
        data: (shares) {
          if (shares.isEmpty) return _buildEmptyState(t);

          // Opening the list counts as reading it.
          final newest = shares.first.createdAt.millisecondsSinceEpoch;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(lastSeenShareProvider.notifier).markSeen(newest);
          });

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: shares.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ShareTile(
              share: shares[index],
              profile: profiles[shares[index].fromUid],
              onDelete: () => _confirmDelete(shares[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 44,
                color: AppConstants.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.sharedLocationsEmpty,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.sharedLocationsEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final LocationShareModel share;

  /// Live profile of the sender, when loaded — the name and photo stored on
  /// the share itself are a snapshot from when it was sent.
  final UserModel? profile;
  final VoidCallback onDelete;

  const _ShareTile({
    required this.share,
    required this.profile,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final name = profile?.username.isNotEmpty == true
        ? profile!.username
        : share.fromName;
    final photoUrl = profile?.photoUrl.isNotEmpty == true
        ? profile!.photoUrl
        : share.fromPhotoUrl;

    final hoursLeft = share.remaining.inHours;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '/friend-map?lat=${share.latitude}&lng=${share.longitude}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              UserAvatar(photoUrl: photoUrl, name: name, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.sharedBy(name),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (share.address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        share.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('MMM dd, HH:mm').format(share.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hoursLeft >= 1
                              ? t.expiresInHours(hoursLeft)
                              : t.expiresSoon,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: t.deleteLocationShare,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF94A3B8),
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
