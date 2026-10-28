import 'package:flutter/material.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_hero_image.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_title_row.dart';
import 'package:gpscamerastamp/features/destination/widgets/photos_gallery.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_coords_row.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_map.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_back_button.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_bottom_bar.dart';
import 'package:gpscamerastamp/features/destination/widgets/image_gallery_viewer.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_facts_row.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_expandable_text.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_info_tile.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_highlights.dart';
import 'package:gpscamerastamp/features/destination/widgets/detail_travel_tip.dart';
import 'package:go_router/go_router.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_motion_widgets.dart';

class DestinationDetailPage extends StatefulWidget {
  final DestinationModel dest;
  final String? heroTag;
  const DestinationDetailPage({super.key, required this.dest, this.heroTag});

  @override
  State<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  void _showImageFullscreen(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageGalleryViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dest = widget.dest;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DetailHeroImage(
                  dest: dest,
                  topPad: topPad,
                  heroTag: widget.heroTag ?? 'all_dest_${dest.id}',
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Aurora.bgSoft,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 6),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCC3D8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeSlideIn.indexed(index: 0, child: DetailTitleRow(dest: dest)),
                              const SizedBox(height: 18),
                              FadeSlideIn.indexed(index: 1, child: DetailFactsRow(dest: dest)),
                              const SizedBox(height: 24),
                              DetailSectionLabel(t.about),
                              const SizedBox(height: 10),
                              FadeSlideIn.indexed(
                                index: 2,
                                child: DetailExpandableText(text: dest.description),
                              ),
                            ],
                          ),
                        ),
                        if (dest.images.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: DetailSectionLabel(t.allPhotos),
                          ),
                          const SizedBox(height: 12),
                          PhotosGallery(
                            images: dest.images,
                            onTap: (i) => _showImageFullscreen(dest.images, i),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AuroraButton(
                            label: t.view360,
                            trailingIcon: Icons.threesixty_rounded,
                            onTap: () {
                              final url =
                                  dest.panoramaUrl ??
                                  'https://www.google.com/maps/embed/v1/streetview?key=${AppConstants.googleMapsApiKey}&location=${dest.latitude},${dest.longitude}';

                              context.push(
                                '/panorama?url=${Uri.encodeComponent(url)}',
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dest.bestTime.isNotEmpty ||
                                  dest.weather.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                if (dest.bestTime.isNotEmpty)
                                  DetailInfoTile(
                                    icon: Icons.wb_sunny_rounded,
                                    iconBg: const Color(0xFFFFF3CD),
                                    iconColor: const Color(0xFFF59E0B),
                                    title: t.bestTime,
                                    value: dest.bestTime,
                                  ),
                                if (dest.bestTime.isNotEmpty &&
                                    dest.weather.isNotEmpty)
                                  const SizedBox(height: 12),
                                if (dest.weather.isNotEmpty)
                                  DetailInfoTile(
                                    icon: Icons.cloud_rounded,
                                    iconBg: const Color(0xFFE0F2FE),
                                    iconColor: const Color(0xFF0284C7),
                                    title: t.climate,
                                    value: dest.weather,
                                  ),
                              ],
                              if (dest.highlights.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                DetailSectionLabel(t.topHighlights),
                                const SizedBox(height: 12),
                                DetailHighlightsList(items: dest.highlights),
                              ],
                              if (dest.travelTip.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                DetailTravelTip(tip: dest.travelTip),
                              ],
                              const SizedBox(height: 24),
                              DetailSectionLabel(t.gpsCoordinates),
                              const SizedBox(height: 12),
                              DetailCoordsRow(dest: dest),
                              const SizedBox(height: 24),
                              DetailSectionLabel(t.locationOnMap),
                              const SizedBox(height: 12),
                              DetailMap(dest: dest),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          DetailBackButton(topPad: topPad),
        ],
      ),
      bottomNavigationBar: DetailBottomBar(dest: dest, bottomPad: bottomPad),
    );
  }
}
