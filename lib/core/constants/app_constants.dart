import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LocaShot GPS';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.dretech.locashot.gps';

  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color darkButton = Color(0xFF151C29);

  // Home accent (new home design)
  static const Color homeAccent = Color(0xFF0099DA);
  static const Color homeAccentDark = Color(0xFF1D6FE8);

  // CTA/01 gradient
  static const Color ctaGradientStart = Color(0xFF00A8E8);
  static const Color ctaGradientEnd = Color(0xFF2563EB);
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [ctaGradientStart, ctaGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Feature flags
  /// Premium entry points (the crown on Home, the Upgrade Pro banner in
  /// Settings). Off until there is an actual purchase flow behind them —
  /// flip to true to bring both back.
  static const bool showPremium = false;

  // Dimensions
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 12.0;
  static const double bottomSheetRadius = 24.0;
  static const double dialogRadius = 20.0;

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Animation
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Map
  static const double defaultMapZoom = 15.0;
  static const double defaultLatitude = 21.0285;
  static const double defaultLongitude = 105.8542;

  // Photo Stamp
  static const double stampFontSize = 24.0;
  static const double stampPadding = 20.0;
  static const String stampDateFormat = 'yyyy-MM-dd';
  static const String stampTimeFormat = 'HH:mm:ss';

  // Storage Keys
  static const String photosBoxName = 'photos';
  static const String historyBoxName = 'location_history';
  static const String settingsBoxName = 'settings';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String firstLaunchKey = 'first_launch';
  static const String stampFormatKey = 'stamp_format';
  static const String captureAdCounterKey = 'capture_ad_counter';

  // Cloudinary — media shared with friends.
  // Unsigned uploads: these two values are meant to be public. Lock the preset
  // down on Cloudinary itself (folder, allowed formats, max file size).
  static const String cloudinaryCloudName = 'dmpzk9h6x';
  static const String cloudinaryUploadPreset = 'shared_media';
  static const String cloudinaryFolder = 'shared_media';
  static const String cloudinaryAvatarFolder = 'avatars';

  // Cloudflare Worker endpoints that hold the keys the app must not ship
  // (see server/push-worker/README.md). Empty = that feature is skipped and
  // everything else keeps working.
  static const String pushEndpoint =
      'https://gpscamerastamp-push.locashot-gps-app.workers.dev/push';
  static const String mediaDeleteEndpoint =
      'https://gpscamerastamp-push.locashot-gps-app.workers.dev/delete';

  // Map & Location APIs
  static const String googleMapsApiKey =
      'AIzaSyC3nM2nkQXb5iHPpsWDK2Dqy6WkxP0QXrw';

  // Location
  static const int locationDistanceFilter = 10;
  static const Duration locationUpdateInterval = Duration(seconds: 5);
}
