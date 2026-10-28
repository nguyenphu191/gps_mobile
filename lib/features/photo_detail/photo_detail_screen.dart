import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_dialog.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/features/sharing/services/upload_queue.dart';
import 'package:gpscamerastamp/shared/providers/gallery_provider.dart';
import 'package:gpscamerastamp/shared/widgets/app_snackbar.dart';

import 'widgets/photo_detail_widgets.dart';

class PhotoDetailScreen extends ConsumerWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Aurora.darkText),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoDetailView);
    final t = AppLocalizations.of(context);
    final photos = ref.watch(galleryProvider);
    final photo = photos.where((p) => p.id == photoId).firstOrNull;
    final media = MediaQuery.of(context);

    if (photo == null) {
      return Scaffold(
        backgroundColor: Aurora.bgSoft,
        body: Stack(
          children: [
            const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
            const AuroraBlob(bottom: -64, right: -80, size: 300, color: Aurora.secondary),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _glassButton(
                        Icons.arrow_back_ios_new_rounded,
                        () => context.pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD9E0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              size: 38,
                              color: Color(0xFFB90A5A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.photoNotFound,
                            style: Aurora.text(18, weight: FontWeight.w800),
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

    final photoLatLng = LatLng(photo.latitude, photo.longitude);
    final heroHeight = (media.size.height * 0.45).clamp(280.0, 440.0);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero photo
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'photo_${photo.id}',
                          child: Image.file(
                          File(photo.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF322C4D),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Aurora.hint,
                              size: 48,
                            ),
                          ),
                        ),
                        ),
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.85),
                                ],
                                stops: const [0, 0.45, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info sheet overlapping the photo
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      media.padding.bottom + 96,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.darkText.withValues(alpha: 0.06),
                          blurRadius: 35,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCC3D8).withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        PhotoAddressBlock(
                          address: photo.address,
                          latitude: photo.latitude,
                          longitude: photo.longitude,
                        ),
                        const SizedBox(height: 14),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: PhotoInfoTile(
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: Aurora.primary,
                                  background: const Color(0xFFF1EBFF),
                                  label: t.date,
                                  value: DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(photo.timestamp),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PhotoInfoTile(
                                  icon: Icons.schedule_rounded,
                                  iconColor: const Color(0xFFB90A5A),
                                  background: const Color(0xFFECE4FF),
                                  label: t.time,
                                  value: DateFormat(
                                    'HH:mm:ss',
                                  ).format(photo.timestamp),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PhotoInfoTile(
                                  icon: Icons.explore_rounded,
                                  iconColor: const Color(0xFF005763),
                                  background: const Color(0xFFE6DEFF),
                                  label: t.coordinates,
                                  mono: true,
                                  value:
                                      '${photo.latitude.toStringAsFixed(4)},\n${photo.longitude.toStringAsFixed(4)}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.map_rounded,
                              size: 20,
                              color: Aurora.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t.locationOnMap,
                              style: Aurora.text(18, weight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        PhotoMapPreview(photoLatLng: photoLatLng),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating top buttons
          Positioned(
            top: media.padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  Icons.arrow_back_ios_new_rounded,
                  () => context.pop(),
                ),
                _glassButton(Icons.share_rounded, () => sharePhoto(photo)),
              ],
            ),
          ),

          // Floating action dock
          Positioned(
            left: 16,
            right: 16,
            bottom: media.padding.bottom + 20,
            child: PhotoActionButtonsRow(
              photo: photo,
              photoId: photoId,
              onDeleteTap: (ctx, r) => _showDeleteDialog(ctx, r),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showAuroraConfirmDialog(
      context,
      title: t.deletePhoto,
      message: t.deletePhotoConfirm,
      cancelLabel: t.cancel,
      confirmLabel: t.delete,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(galleryProvider.notifier).deletePhoto(photoId);
    // Also pull it back from friends' maps.
    unawaited(ref.read(uploadQueueProvider).remove(photoId));
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.photoDeleted);
    context.pop();
    ScaffoldMessenger.of(context).showSuccessSnack('Đã xóa ảnh thành công');
  }
}
