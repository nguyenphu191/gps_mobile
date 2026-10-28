import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../shared/models/map_media_item.dart';

/// Full-screen viewer for a photo or video shared by a friend (network URL).
class SharedMediaViewer extends StatefulWidget {
  final MapMediaItem item;

  const SharedMediaViewer({super.key, required this.item});

  @override
  State<SharedMediaViewer> createState() => _SharedMediaViewerState();
}

class _SharedMediaViewerState extends State<SharedMediaViewer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.item.remoteUrl;
    if (url == null || url.isEmpty) {
      setState(() => _failed = true);
      return;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _initialized = true);
      controller.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.sharedBy(item.ownerName ?? ''),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: t.streetView,
            icon: const Icon(Icons.streetview_rounded, color: Colors.white),
            onPressed: () => context.push(
              AppRoutes.streetViewAt(
                item.latitude,
                item.longitude,
                name: item.address,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildMedia(t))),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.address?.isNotEmpty == true)
                  Text(
                    item.address!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM dd, yyyy  HH:mm').format(item.timestamp),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.latitude.toStringAsFixed(6)}, ${item.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(AppLocalizations t) {
    if (_failed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          t.friendMediaLoadError,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (widget.item.isVideo) {
      final controller = _controller;
      if (!_initialized || controller == null) {
        return const CircularProgressIndicator(color: Colors.white);
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          GestureDetector(
            onTap: () => setState(() {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            }),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (!controller.value.isPlaying)
            const Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
        ],
      );
    }

    return InteractiveViewer(
      child: Image.network(
        widget.item.remoteUrl ?? '',
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
        errorBuilder: (_, _, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.friendMediaLoadError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
