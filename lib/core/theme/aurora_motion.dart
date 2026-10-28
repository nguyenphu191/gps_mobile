import 'package:flutter/material.dart';

/// Shared timings and curves so every screen moves the same way.
class AuroraMotion {
  AuroraMotion._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);

  /// Gap between items of a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Only the first few items are staggered; the rest appear with them.
  static const int maxStagger = 10;

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  /// True when the user asked the OS to reduce motion.
  static bool reduce(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration delayFor(int index) =>
      stagger * (index < maxStagger ? index : maxStagger);
}
