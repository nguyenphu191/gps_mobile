import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_events.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurora.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/models/user_model.dart';
import '../models/location_share_model.dart';
import '../services/friend_service.dart';

/// One row in the Friend tab. Swipe left to remove, "Send" shares my current
/// location, "View" opens the newest location this friend sent me.
class FriendTile extends ConsumerStatefulWidget {
  final String friendDocId;
  final UserModel profile;
  final LocationShareModel? latestShare;

  const FriendTile({
    super.key,
    required this.friendDocId,
    required this.profile,
    this.latestShare,
  });

  @override
  ConsumerState<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends ConsumerState<FriendTile> {
  bool _sending = false;
  bool _justSent = false;

  bool get _isOnline {
    final seen = widget.profile.lastSeen;
    if (seen == null) return false;
    return DateTime.now().difference(seen) < const Duration(minutes: 5);
  }

  String get _name => widget.profile.displayName.isNotEmpty
      ? widget.profile.displayName
      : widget.profile.username;

  /// Grab the current position and send it to this friend as a one-off share.
  Future<void> _sendLocation() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(friendServiceProvider);
    if (service == null || _sending) return;

    setState(() => _sending = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        messenger.showErrorSnack(t.locationDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final address =
          await LocationService().getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          ) ??
          '';

      await service.sendLocation(
        toUid: widget.profile.uid,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      getIt<AnalyticsService>().logEvent(AnalyticsEvents.locationSentToFriend);
      messenger.showSuccessSnack(t.locationSent);
      if (mounted) setState(() => _justSent = true);
      // Back to "Send" after a moment so the row stays usable.
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _justSent = false);
    } catch (e) {
      debugPrint('🔥 [Friends] send location failed: $e');
      messenger.showErrorSnack(t.locationSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool> _confirmRemove() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          t.friendsRemove,
          style: Aurora.text(18, weight: FontWeight.w800),
        ),
        content: Text(
          t.friendsRemoveConfirm(_name),
          style: Aurora.text(14, color: Aurora.subText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.cancel,
              style: Aurora.text(
                14,
                weight: FontWeight.w700,
                color: Aurora.subText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.delete,
              style: Aurora.text(
                14,
                weight: FontWeight.w800,
                color: const Color(0xFFFF4757),
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _remove() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(friendServiceProvider)?.removeFriend(widget.friendDocId);
    messenger.showSuccessSnack(t.friendsRemoved);
  }

  void _openLatestShare() {
    final share = widget.latestShare;
    if (share == null) return;
    context.push('/friend-map?lat=${share.latitude}&lng=${share.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final share = widget.latestShare;
    final hasAddress = share != null && share.address.isNotEmpty;
    final subtitle = hasAddress ? share.address : '@${widget.profile.username}';

    return Dismissible(
      key: ValueKey(widget.friendDocId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmRemove(),
      onDismissed: (_) => _remove(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFBA1A1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
            Text(
              t.delete,
              style: Aurora.text(
                10,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(
                  AppRoutes.friendProfilePath(widget.profile.uid),
                ),
                child: Row(
                  children: [
                    _avatar(),
                    const SizedBox(width: 12),
                    Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(16, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (hasAddress) ...[
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Aurora.secondary,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(12, color: Aurora.subText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (share != null) ...[
              _pill(
                label: t.view,
                background: const Color(0xFFF1EBFF),
                foreground: Aurora.primary,
                onTap: _openLatestShare,
              ),
              const SizedBox(width: 6),
            ],
            _sendPill(t),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isOnline ? Aurora.primaryGradient : null,
              color: _isOnline ? null : const Color(0x99CCC3D8),
            ),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: UserAvatar(
                photoUrl: widget.profile.photoUrl,
                name: widget.profile.username.isNotEmpty
                    ? widget.profile.username
                    : widget.profile.displayName,
                radius: 21,
              ),
            ),
          ),
          if (_isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF2FD9F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sendPill(AppLocalizations t) {
    if (_justSent) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFA2EEFF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: Color(0xFF005763),
            ),
            const SizedBox(width: 4),
            Text(
              t.friendsSent,
              style: Aurora.text(
                12,
                weight: FontWeight.w800,
                color: const Color(0xFF005763),
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: _sending ? null : _sendLocation,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: Aurora.primaryGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _sending
            ? const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.friendsSend,
                    style: Aurora.text(
                      12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.pin_drop_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Aurora.text(12, weight: FontWeight.w700, color: foreground),
        ),
      ),
    );
  }
}
