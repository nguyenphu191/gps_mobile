import 'package:flutter/material.dart';
import '../../../core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/models/destination_model.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';
import 'package:gpscamerastamp/features/destination/all_destinations_screen.dart';

class DestinationCarousel extends StatefulWidget {
  final List<DestinationModel> destinations;
  const DestinationCarousel({super.key, required this.destinations});

  @override
  State<DestinationCarousel> createState() => _DestinationCarouselState();
}

class _DestinationCarouselState extends State<DestinationCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.55,
    initialPage: 3,
  );
  int _currentPage = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.destinations.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final diff = (_pageController.page! - index).abs();
                    scale = (1 - diff * 0.08).clamp(0.88, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _DestinationCard(dest: widget.destinations[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.destinations.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: active ? Aurora.primaryGradient : null,
                color: active ? null : const Color(0xFFE6DEFF),
                borderRadius: BorderRadius.circular(4),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DestinationModel dest;
  const _DestinationCard({required this.dest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              DestinationDetailPage(dest: dest, heroTag: 'dest_${dest.id}'),
          transitionsBuilder: (context, anim, secondaryAnimation, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Hero(
          tag: 'dest_${dest.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -6,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ShimmerNetworkImage(
                    imageUrl: dest.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xE61D1737)],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dest.rating.toString(),
                            style: Aurora.text(12, weight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFA2EEFF),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dest.country,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Aurora.text(
                                  12,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFFA2EEFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dest.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(
                            19,
                            weight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
