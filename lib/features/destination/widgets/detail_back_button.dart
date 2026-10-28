import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/aurora_motion_widgets.dart';

class DetailBackButton extends StatelessWidget {
  final double topPad;
  const DetailBackButton({super.key, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPad + 10,
      left: 16,
      child: Pressable(
        onTap: () => Navigator.of(context).pop(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 44,
              height: 44,
              color: Colors.white.withValues(alpha: 0.28),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
