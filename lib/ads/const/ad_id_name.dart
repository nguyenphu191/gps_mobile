/// Factory IDs (must match strings registered in iOS AppDelegate.swift)
/// and ad config keys used across the app.
class MyAdIdName {
  // ── Factory IDs cho native ad views (match với AppDelegate) ──
  static const nativeFull = 'nativeFull';
  static const nativeNonFullAds = 'nativeNonFullAds';
  static const nativeNonFullAdsUnselected = 'nativeNonFullAdsUnselected';
  static const nativeLanguageUnselect = 'nativeLanguageUnselect';
  static const nativeIntro1 = 'nativeIntro1';
  static const nativeIntro2 = 'nativeIntro2';
  static const nativeIntro3 = 'nativeIntro3';
  static const nativeIntro4 = 'nativeIntro4';
  static const nativeExpand = 'nativeExpand';
  static const nativeCollapse = 'nativeCollapse';

  // ── Ad config keys (reference) ──
  static const nativeLanguage = 'nativeLanguage';
  static const nativeLanguageSelect = 'nativeLanguageSelect';
  static const nativeFullSplash = 'nativeFullSplash';
  static const appOpenResume = 'appOpenResume';
  static const openSplash = 'openSplash';
  static const nativeIntro1Key = 'nativeIntro1';
  static const nativeIntro2Key = 'nativeIntro2';
  static const nativeIntro3Key = 'nativeIntro3';
  static const nativeIntro4Key = 'nativeIntro4';
  static const nativeHome = 'nativeHome';
  static const nativeLibrary = 'nativeLibrary';
  static const nativeExplore = 'nativeExplore';
  static const nativeDestination = 'nativeDestination';
  static const interCapture = 'interCapture';
  static const interViewAll = 'interViewAll';
  static const interBack = 'interBack';
}

enum AdType { nativeExpand, nativeCollapse }
