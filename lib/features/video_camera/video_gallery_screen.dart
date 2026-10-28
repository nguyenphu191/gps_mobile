import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurora.dart';
import '../../../shared/widgets/aurora_blob.dart';
import '../../../shared/widgets/aurora_dialog.dart';
import '../../../shared/widgets/aurora_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../sharing/services/upload_queue.dart';
import 'models/video_model.dart';
import 'providers/video_gallery_provider.dart';

class VideoGalleryScreen extends ConsumerWidget {
  const VideoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final videos = ref.watch(videoGalleryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(t.videoGallery),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: videos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_library_rounded,
                    size: 64,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.videoGalleryEmpty,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return _VideoGridItem(video: video);
              },
            ),
    );
  }
}

class _VideoGridItem extends StatelessWidget {
  final VideoModel video;
  const _VideoGridItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VideoDetailScreen(video: video)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white54,
                size: 48,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(video.timestamp),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      video.address,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoDetailScreen extends ConsumerStatefulWidget {
  final VideoModel video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  ConsumerState<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends ConsumerState<VideoDetailScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.videoPath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareVideo() {
    final file = XFile(widget.video.videoPath);
    Share.shareXFiles([
      file,
    ], text: 'Check out this video from ${widget.video.address}!');
  }

  void _openStreetView() {
    context.push(
      AppRoutes.streetViewAt(
        widget.video.latitude,
        widget.video.longitude,
        name: widget.video.address,
      ),
    );
  }

  Future<void> _deleteVideo() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showAuroraConfirmDialog(
      context,
      title: t.videoDelete,
      message: 'Are you sure you want to delete this video?',
      cancelLabel: t.cancel,
      confirmLabel: t.delete,
    );
    if (!confirmed || !mounted) return;
    ref.read(videoGalleryProvider.notifier).deleteVideo(widget.video.id);
    // Also pull it back from friends' maps.
    unawaited(ref.read(uploadQueueProvider).remove(widget.video.id));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSuccessSnack('Đã xóa video thành công');
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _seekTo(double dx, double width) {
    final total = _controller.value.duration;
    if (total == Duration.zero || width <= 0) return;
    final f = (dx / width).clamp(0.0, 1.0);
    _controller.seekTo(total * f);
  }

  Widget _topButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = Aurora.darkText,
    String? tooltip,
    Color? background,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background ?? const Color(0x99ECE4FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }

  Widget _player() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF322C4D),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: _initialized ? _controller.value.aspectRatio : 9 / 14,
          child: !_initialized
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Aurora.secondary,
                    strokeWidth: 2.5,
                  ),
                )
              : ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final total = value.duration;
                    final pos = value.position;
                    final progress = total.inMilliseconds == 0
                        ? 0.0
                        : (pos.inMilliseconds / total.inMilliseconds).clamp(
                            0.0,
                            1.0,
                          );
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () => value.isPlaying
                              ? _controller.pause()
                              : _controller.play(),
                          child: VideoPlayer(_controller),
                        ),
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF322C4D).withValues(alpha: 0.9),
                                ],
                                stops: const [0.6, 1],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedOpacity(
                            opacity: value.isPlaying ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: value.isPlaying,
                              child: GestureDetector(
                                onTap: () => _controller.play(),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Aurora.primary.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 32,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 36,
                                    color: Aurora.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 12,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_fmt(pos)} / ${_fmt(total)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LayoutBuilder(
                                builder: (context, c) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (d) =>
                                      _seekTo(d.localPosition.dx, c.maxWidth),
                                  onHorizontalDragUpdate: (d) =>
                                      _seekTo(d.localPosition.dx, c.maxWidth),
                                  child: SizedBox(
                                    height: 20,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                        Container(
                                          height: 6,
                                          width: c.maxWidth * progress,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Aurora.primary,
                                                Color(0xFFFE4C8C),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                        Positioned(
                                          left: (c.maxWidth * progress) - 7,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Aurora.secondary
                                                      .withValues(alpha: 0.8),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String text,
    bool mono = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: mono
                ? Text(
                    text,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Aurora.darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  )
                : Text(
                    text,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(13, weight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final video = widget.video;
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 60, size: 300, color: Aurora.aqua),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      _topButton(
                        Icons.arrow_back_ios_new_rounded,
                        () => Navigator.of(context).pop(),
                        background: Colors.white,
                      ),
                      const Spacer(),
                      _topButton(
                        Icons.streetview_rounded,
                        _openStreetView,
                        tooltip: t.streetView,
                      ),
                      const SizedBox(width: 8),
                      _topButton(Icons.share_rounded, _shareVideo),
                      const SizedBox(width: 8),
                      _topButton(
                        Icons.delete_rounded,
                        _deleteVideo,
                        color: const Color(0xFFBA1A1A),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      media.padding.bottom + 24,
                    ),
                    child: Column(
                      children: [
                        Center(child: _player()),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xB3F1EBFF),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            children: [
                              _tile(
                                icon: Icons.pin_drop_rounded,
                                bg: const Color(0xFFFFD9E0),
                                fg: const Color(0xFFB90A5A),
                                text: video.address,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 10),
                              _tile(
                                icon: Icons.explore_rounded,
                                bg: const Color(0xFFA2EEFF),
                                fg: const Color(0xFF005763),
                                mono: true,
                                text:
                                    '${video.latitude.toStringAsFixed(5)}, ${video.longitude.toStringAsFixed(5)}',
                              ),
                              const SizedBox(height: 10),
                              _tile(
                                icon: Icons.schedule_rounded,
                                bg: const Color(0xFFEADDFF),
                                fg: const Color(0xFF630ED4),
                                mono: true,
                                text: DateFormat(
                                  'MMM dd, yyyy HH:mm',
                                ).format(video.timestamp),
                              ),
                              const SizedBox(height: 16),
                              AuroraButton(
                                label: t.streetView,
                                height: 52,
                                trailingIcon: Icons.streetview_rounded,
                                onTap: _openStreetView,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
