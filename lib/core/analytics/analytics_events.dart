class AnalyticsEvents {
  AnalyticsEvents._();

  // Onboarding
  static const String splashView = 'splash_view';
  static const String splashComplete = 'splash_complete';
  static const String languageView = 'language_view';
  static const String languageComplete = 'language_complete';
  static const String introView = 'intro_view';
  static const String introSlideView = 'intro_slide_view';
  static const String introComplete = 'intro_complete';

  // Home
  static const String homeView = 'home_view';
  static const String homeLocationUpdated = 'home_location_updated';

  // Camera
  static const String cameraView = 'camera_view';
  static const String photoCaptured = 'photo_captured';
  static const String photoSaved = 'photo_saved';
  static const String photoRetaken = 'photo_retaken';
  static const String cameraSwitchToggled = 'camera_switch_toggled';
  static const String flashToggled = 'flash_toggled';

  // Gallery
  static const String galleryView = 'gallery_view';
  static const String photoDetailView = 'photo_detail_view';
  static const String photoDeleted = 'photo_deleted';
  static const String photoShared = 'photo_shared';

  // Map Gallery
  static const String mapGalleryView = 'map_gallery_view';

  // History
  static const String historyView = 'history_view';
  static const String historyCleared = 'history_cleared';

  // Explore
  static const String exploreView = 'explore_view';
  static const String exploreCategoryClick = 'explore_category_click';

  // Settings
  static const String settingsView = 'settings_view';
  static const String languageChanged = 'language_changed';
  static const String privacyPolicyClick = 'privacy_policy_click';
  static const String shareAppClick = 'share_app_click';

  // Destination
  static const String destinationView = 'destination_view';
  static const String destinationDetailView = 'destination_detail_view';
  static const String directionClick = 'direction_click';
  static const String streetViewClick = 'street_view_click';
  static const String earth3dClick = 'earth_3d_click';
  static const String panorama360Click = 'panorama_360_click';

  // Sharing
  static const String mediaShared = 'media_shared';
  static const String locationSentToFriend = 'location_sent_to_friend';

  // Ads
  static const String adAppOpenShown = 'ad_app_open_shown';
  static const String adInterstitialShown = 'ad_interstitial_shown';
  static const String adNativeShown = 'ad_native_shown';
  static const String adNativeClicked = 'ad_native_clicked';
}
