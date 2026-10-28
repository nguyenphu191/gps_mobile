import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/router/app_router.dart';
import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/widgets/user_avatar.dart';
import 'package:gpscamerastamp/shared/widgets/app_snackbar.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_dialog.dart';

import '../../friends/providers/friend_profiles_provider.dart';
import '../../sharing/services/cloudinary_client.dart';
import '../../sharing/services/upload_queue.dart';
import '../../sharing/shared_media_viewer.dart';
import '../../video_camera/models/video_model.dart';
import '../../video_camera/providers/video_gallery_provider.dart';
import '../../video_camera/video_gallery_screen.dart';
import '../../../shared/providers/gallery_provider.dart';

/// Bottom sheet for any map item: own photo, own video, or a friend's media.
class MediaBottomSheet extends ConsumerWidget {
  final MapMediaItem item;

  const MediaBottomSheet({super.key, required this.item});

  void _open(BuildContext context) {
    Navigator.pop(context);

    if (!item.isMine) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SharedMediaViewer(item: item)));
      return;
    }

    if (item.isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoDetailScreen(
            video: VideoModel(
              id: item.id,
              videoPath: item.localPath ?? '',
              latitude: item.latitude,
              longitude: item.longitude,
              timestamp: item.timestamp,
              address: item.address ?? '',
            ),
          ),
        ),
      );
      return;
    }

    context.push('/photo-detail/${item.id}');
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showAuroraConfirmDialog(
      context,
      title: item.isVideo ? t.videoDelete : t.deletePhoto,
      message: item.isVideo
          ? 'Are you sure you want to delete this video?'
          : t.deletePhotoConfirm,
      cancelLabel: t.cancel,
      confirmLabel: t.delete,
    );
    if (!confirmed || !context.mounted) return;
    if (item.isVideo) {
      ref.read(videoGalleryProvider.notifier).deleteVideo(item.id);
    } else {
      ref.read(galleryProvider.notifier).deletePhoto(item.id);
    }
    // Also pull it back from friends' maps.
    unawaited(ref.read(uploadQueueProvider).remove(item.id));
    Navigator.pop(context); // Close bottom sheet
    ScaffoldMessenger.of(context).showSuccessSnack(
      item.isVideo ? 'Đã xóa video thành công' : 'Đã xóa ảnh thành công',
    );
  }

  Widget _squareButton({
    required IconData icon,
    required Color background,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profile = item.ownerUid == null
        ? null
        : (ref.watch(friendProfilesProvider).valueOrNull ??
              const {})[item.ownerUid];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: -6,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCCC3D8).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (!item.isMine) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: Aurora.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: UserAvatar(
                    photoUrl: profile?.photoUrl.isNotEmpty == true
                        ? profile!.photoUrl
                        : item.ownerPhotoUrl,
                    name: profile?.username.isNotEmpty == true
                        ? profile!.username
                        : (item.ownerName ?? ''),
                    radius: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.sharedBy(item.ownerName ?? ''),
                    style: Aurora.text(
                      13,
                      weight: FontWeight.w700,
                      color: Aurora.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: _Thumbnail(item: item),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.address ?? '',
                      style: Aurora.text(
                        15,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM dd, yyyy  HH:mm').format(item.timestamp),
                      style: Aurora.text(12.5, color: Aurora.subText),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.pin_drop_rounded,
                          size: 14,
                          color: Aurora.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${item.latitude.toStringAsFixed(5)}, ${item.longitude.toStringAsFixed(5)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Aurora.primary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AuroraButton(
                  label: t.viewDetail,
                  height: 48,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onTap: () => _open(context),
                ),
              ),
              const SizedBox(width: 10),
              _squareButton(
                icon: Icons.streetview_rounded,
                background: const Color(0x80A2EEFF),
                color: const Color(0xFF005763),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.streetViewAt(
                      item.latitude,
                      item.longitude,
                      name: item.address,
                    ),
                  );
                },
              ),
              if (item.isMine) ...[
                const SizedBox(width: 10),
                _squareButton(
                  icon: Icons.delete_outline_rounded,
                  background: const Color(0x99FFDAD6),
                  color: const Color(0xFFBA1A1A),
                  onTap: () => _showDeleteDialog(context, ref),
                ),
              ],
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final MapMediaItem item;
  const _Thumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    // No thumbnails are generated for videos — show a play tile instead.
    if (item.isVideo) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF322C4D), Color(0xFF630ED4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Aurora.primary,
              size: 26,
            ),
          ),
        ),
      );
    }

    final placeholder = Container(
      color: const Color(0xFFF1EBFF),
      child: const Icon(Icons.broken_image_rounded, color: Aurora.hint),
    );

    if (item.isMine) {
      return Image.file(
        File(item.localPath ?? ''),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    // 80px preview — a resized variant is plenty.
    return Image.network(
      CloudinaryClient.thumbnailUrl(item.remoteUrl ?? '', width: 240),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
