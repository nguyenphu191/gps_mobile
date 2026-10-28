import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurora.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/time_ago.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../friends/services/friend_service.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationTile extends ConsumerStatefulWidget {
  final AppNotification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  ConsumerState<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends ConsumerState<NotificationTile> {
  bool _busy = false;

  AppNotification get _n => widget.notification;

  /// The sentence shown in the row. The location share is the odd one out:
  /// the address itself is the message, exactly as in the design.
  String _message(AppLocalizations t) {
    final name = _n.fromName;
    switch (_n.type) {
      case NotificationType.friendRequest:
        return t.notifFriendRequest(name);
      case NotificationType.friendRequestAccepted:
        return t.notifRequestAccepted(name);
      case NotificationType.friendMedia:
        return _n.mediaKind == 'video'
            ? t.notifSharedVideo(name)
            : t.notifSharedPhoto(name);
      case NotificationType.locationShare:
        return t.notifSharedLocation(name);
      case NotificationType.unknown:
        return name;
    }
  }

  Future<void> _respondToRequest({required bool accept}) async {
    final friendService = ref.read(friendServiceProvider);
    final notifService = ref.read(notificationServiceProvider);
    final docId = _n.friendDocId;
    if (friendService == null || docId == null) return;

    setState(() => _busy = true);
    try {
      if (accept) {
        await friendService.acceptFriendRequest(docId);
        await notifService?.delete(_n.id);
      } else {
        await friendService.declineFriendRequest(docId);
        await notifService?.delete(_n.id);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openTarget() {
    ref.read(notificationServiceProvider)?.markRead(_n.id);
    switch (_n.type) {
      case NotificationType.locationShare:
        final lat = _n.latitude;
        final lng = _n.longitude;
        if (lat != null && lng != null) {
          context.push('/friend-map?lat=$lat&lng=$lng');
        } else {
          context.push('/friend-map');
        }
      case NotificationType.friendMedia:
        context.push('/map-gallery');
      default:
        break;
    }
  }

  (IconData, List<Color>) get _badge {
    switch (_n.type) {
      case NotificationType.friendRequest:
        return (
          Icons.person_add_rounded,
          const [Aurora.primary, Color(0xFF9B6BFF)],
        );
      case NotificationType.friendRequestAccepted:
        return (
          Icons.how_to_reg_rounded,
          const [Color(0xFF00A8B5), Color(0xFF2FD9F4)],
        );
      case NotificationType.friendMedia:
        return (
          _n.mediaKind == 'video'
              ? Icons.videocam_rounded
              : Icons.photo_camera_rounded,
          const [Color(0xFFB90A5A), Aurora.secondary],
        );
      case NotificationType.locationShare:
        return (
          Icons.near_me_rounded,
          const [Color(0xFF00A8B5), Color(0xFF2FD9F4)],
        );
      case NotificationType.unknown:
        return (Icons.notifications_rounded, const [Aurora.primary, Aurora.secondary]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // A location share leads with the address; the sentence version carries a
    // "View" button underneath instead.
    final showAddressOnly =
        _n.type == NotificationType.locationShare &&
        (_n.address?.isNotEmpty ?? false);
    final hasView =
        _n.type == NotificationType.locationShare ||
        _n.type == NotificationType.friendMedia;
    final isRequest =
        _n.type == NotificationType.friendRequest && _n.friendDocId != null;
    final badge = _badge;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _n.read
            ? Colors.white
            : const Color(0xFFECE4FF).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: _n.read ? 0.05 : 0.12),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Aurora.primaryGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: UserAvatar(
                        photoUrl: _n.fromPhotoUrl,
                        name: _n.fromName,
                        radius: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: badge.$2),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(badge.$1, size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAddressOnly)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 15,
                              color: Aurora.secondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _n.address!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Aurora.text(
                                13.5,
                                weight: FontWeight.w600,
                                color: const Color(0xFF4A4455),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _NameSentence(name: _n.fromName, sentence: _message(t)),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo(t, _n.createdAt),
                      style: Aurora.text(
                        11,
                        weight: FontWeight.w700,
                        color: const Color(0xFF7B7487),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasView) ...[
                const SizedBox(width: 8),
                _Pill(
                  label: t.view,
                  trailing: Icons.chevron_right_rounded,
                  onTap: _openTarget,
                  background: Colors.white,
                  foreground: Aurora.primary,
                ),
              ],
              if (!_n.read) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: Aurora.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Aurora.secondary.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isRequest) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 62),
              child: Row(
                children: [
                  _Pill(
                    label: t.friendsAccept,
                    leading: Icons.check_rounded,
                    gradient: true,
                    loading: _busy,
                    onTap: _busy ? null : () => _respondToRequest(accept: true),
                  ),
                  const SizedBox(width: 8),
                  _Pill(
                    label: t.friendsDecline,
                    onTap: _busy ? null : () => _respondToRequest(accept: false),
                    background: const Color(0xFFE6DEFF),
                    foreground: const Color(0xFF4A4455),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders the sender's name in bold inside the translated sentence, without
/// needing a separate markup format in the language files.
class _NameSentence extends StatelessWidget {
  final String name;
  final String sentence;

  const _NameSentence({required this.name, required this.sentence});

  @override
  Widget build(BuildContext context) {
    final base = Aurora.text(
      13.5,
      weight: FontWeight.w500,
      color: const Color(0xFF4A4455),
      height: 1.35,
    );
    final bold = Aurora.text(
      13.5,
      weight: FontWeight.w800,
      color: Aurora.darkText,
      height: 1.35,
    );

    final index = name.isEmpty ? -1 : sentence.indexOf(name);
    if (index < 0) {
      return Text(
        sentence,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: sentence.substring(0, index)),
          TextSpan(text: name, style: bold),
          TextSpan(text: sentence.substring(index + name.length)),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Small action pill. [gradient] paints it in the Aurora gradient; otherwise
/// [background]/[foreground] apply.
class _Pill extends StatelessWidget {
  final String label;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback? onTap;
  final bool gradient;
  final bool loading;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.onTap,
    this.leading,
    this.trailing,
    this.gradient = false,
    this.loading = false,
    this.background = Colors.white,
    this.foreground = Aurora.primary,
  });

  @override
  Widget build(BuildContext context) {
    final fg = gradient ? Colors.white : foreground;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradient ? Aurora.primaryGradient : null,
          color: gradient ? null : background,
          borderRadius: BorderRadius.circular(999),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: Aurora.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    Icon(leading, size: 16, color: fg),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: Aurora.text(13, weight: FontWeight.w700, color: fg),
                  ),
                  if (trailing != null) Icon(trailing, size: 16, color: fg),
                ],
              ),
      ),
    );
  }
}
