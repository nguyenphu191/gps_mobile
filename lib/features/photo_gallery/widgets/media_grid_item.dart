import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/features/sharing/services/cloudinary_client.dart';
import 'package:gpscamerastamp/shared/models/map_media_item.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';
import 'package:gpscamerastamp/shared/widgets/user_avatar.dart';

/// One square in the gallery grid: a photo or a video, owned or shared by a
/// friend.
///
/// Videos have no thumbnail stored anywhere (see VideoModel), so they render
/// as a dark tile with a play badge rather than a frame of the footage.
class MediaGridItem extends StatefulWidget {
  final MapMediaItem item;
  final VoidCallback onTap;

  /// Owner avatar and name, resolved by the screen from the live profile
  /// streams. The copies stored on [item] are a snapshot taken at upload time
  /// and go stale as soon as somebody changes their picture.
  final String? ownerPhotoUrl;
  final String ownerName;

  const MediaGridItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.ownerPhotoUrl,
    required this.ownerName,
  });

  @override
  State<MediaGridItem> createState() => _MediaGridItemState();
}

class _MediaGridItemState extends State<MediaGridItem> {
  bool _pressed = false;

  MapMediaItem get item => widget.item;
  String? get ownerPhotoUrl => widget.ownerPhotoUrl;
  String get ownerName => widget.ownerName;

  /// Short place label from the stored address: the second-to-last part of
  /// "street, city, country", or the only part when there is one.
  String? _place() {
    final raw = item.address;
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    return parts.length >= 2 ? parts[parts.length - 2] : parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final place = _place();
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.isVideo) _videoTile() else _photoTile(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC322C4D)],
                      stops: [0.5, 1],
                    ),
                  ),
                ),
                Positioned(left: 6, bottom: 6, right: 6, child: _badge(place)),
                _ownerBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String? place) {
    final text = place ?? DateFormat('MM/dd').format(item.timestamp);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (place != null) ...[
              const Icon(
                Icons.location_on_rounded,
                size: 10,
                color: Aurora.secondary,
              ),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Aurora.text(9.5, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoTile() {
    final path = item.localPath;
    if (path != null) {
      final image = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _broken(),
      );
      // Own photos open the detail page: fly the thumbnail into its hero.
      return item.isMine ? Hero(tag: 'photo_${item.id}', child: image) : image;
    }

    // A friend's photo lives on Cloudinary. A grid cell is about a third of
    // the screen wide, so pull a thumbnail rather than the full-size asset.
    final url = item.remoteUrl;
    if (url == null || url.isEmpty) return _broken();
    return ShimmerNetworkImage(
      imageUrl: CloudinaryClient.thumbnailUrl(url, width: 300),
      fit: BoxFit.cover,
    );
  }

  /// Avatar marking whose media this is. The gradient ring keeps it readable
  /// over a bright photo.
  Widget _ownerBadge() {
    return Positioned(
      right: 6,
      top: 6,
      child: Container(
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
          child: UserAvatar(
            photoUrl: ownerPhotoUrl,
            name: ownerName,
            radius: 9,
          ),
        ),
      ),
    );
  }

  Widget _videoTile() {
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Aurora.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _broken() {
    return Container(
      color: const Color(0xFFF1EBFF),
      child: const Icon(
        Icons.broken_image_rounded,
        color: Aurora.hint,
        size: 28,
      ),
    );
  }
}
