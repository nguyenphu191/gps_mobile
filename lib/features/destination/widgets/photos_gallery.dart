import 'package:flutter/material.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/shimmer_image.dart';

class PhotosGallery extends StatelessWidget {
  final List<String> images;
  final void Function(int index) onTap;
  const PhotosGallery({super.key, required this.images, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: Aurora.cardShadow,
            ),
            child: ShimmerNetworkImage(
              imageUrl: images[index],
              width: 224,
              height: 140,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}
