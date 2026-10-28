import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Aurora Pop" design tokens. Adopted screen by screen; the legacy
/// [AppConstants] tokens stay in place for screens not yet migrated.
class Aurora {
  Aurora._();

  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFFF4D8D);
  static const Color aqua = Color(0xFF22D3EE);
  static const Color sunny = Color(0xFFFFC94D);
  static const Color sunnyEnd = Color(0xFFFF9F43);
  static const Color mint = Color(0xFF2DD4BF);
  static const Color darkText = Color(0xFF1B1535);
  static const Color subText = Color(0xFF6B6486);
  static const Color bgSoft = Color(0xFFF7F5FF);
  static const Color bgSoftEnd = Color(0xFFEDE4FF);
  static const Color hint = Color(0xFF9A93B5);
  static const Color disabled = Color(0xFFE6E2F2);
  static const Color selectedFill = Color(0xFFF3EBFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient aquaViolet = LinearGradient(
    colors: [aqua, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sunnyGradient = LinearGradient(
    colors: [sunny, sunnyEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
  static List<BoxShadow> get modalShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 45,
      offset: const Offset(0, 20),
    ),
  ];

  static TextStyle text(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = darkText,
    double? height,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
