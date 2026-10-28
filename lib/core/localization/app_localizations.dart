import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('vi'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('pt'),
    Locale('hi'),
    Locale('ar'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'vi': 'Tiếng Việt',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'ar': 'العربية',
  };

  static String languageName(String code) => _languageNames[code] ?? code;

  Future<void> load() async {
    final langCode = locale.languageCode;
    try {
      final data = await rootBundle.loadString('assets/lang/$langCode.json');
      _strings = Map<String, String>.from(json.decode(data));
    } catch (_) {
      final data = await rootBundle.loadString('assets/lang/en.json');
      _strings = Map<String, String>.from(json.decode(data));
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    var text = _strings[key] ?? _strings['en_$key'] ?? key;
    if (params != null) {
      for (final e in params.entries) {
        text = text.replaceAll('{${e.key}}', e.value);
      }
    }
    return text;
  }

  // Common
  String get appName => translate('app_name');
  String get greeting => translate('greeting');
  String get welcomeTitle => translate('welcome_title');
  String get welcomeSubtitle => translate('welcome_subtitle');
  String get getStarted => translate('get_started');
  String get next => translate('next');
  String get skip => translate('skip');
  String get done => translate('done');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get back => translate('back');
  String get close => translate('close');
  String get share => translate('share');
  String get retry => translate('retry');
  String get search => translate('search');
  String get continueText => translate('continue_text');
  String get onLabel => translate('on');
  String get offLabel => translate('off');
  String get autoLabel => translate('auto');

  // Features
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get mapView => translate('map_view');
  String get mapGallery => translate('map_gallery');
  String get history => translate('history');
  String get settings => translate('settings');
  String get home => translate('home');

  // Camera
  String get takePhoto => translate('take_photo');
  String get capturePhoto => translate('capture_photo');
  String get switchCamera => translate('switch_camera');
  String get flash => translate('flash');
  String get flashOn => translate('flash_on');
  String get flashOff => translate('flash_off');
  String get flashAuto => translate('flash_auto');

  // Location
  String get currentLocation => translate('current_location');
  String get latitude => translate('latitude');
  String get longitude => translate('longitude');
  String get address => translate('address');
  String get locationNotAvailable => translate('location_not_available');
  String get fetchingLocation => translate('fetching_location');
  String get locationPermissionDenied => translate('location_permission_denied');
  String get enableLocationServices => translate('enable_location_services');
  String get unknownLocation => translate('unknown_location');
  String get addressUnavailable => translate('address_unavailable');
  String get locationUnavailable => translate('location_unavailable');
  String get enableLocation => translate('enable_location');

  // Gallery
  String get noPhotos => translate('no_photos');
  String get photoDetail => translate('photo_detail');
  String get deletePhoto => translate('delete_photo');
  String get deletePhotoConfirm => translate('delete_photo_confirm');
  String get sharePhoto => translate('share_photo');
  String get photoSaved => translate('photo_saved');
  String get allPhotos => translate('all_photos');
  String get today => translate('today');
  String get yesterday => translate('yesterday');

  // Map
  String get viewOnMap => translate('view_on_map');
  String get photoLocations => translate('photo_locations');
  String get noLocations => translate('no_locations');

  // History
  String get locationHistory => translate('location_history');
  String get noHistory => translate('no_history');
  String get clearHistory => translate('clear_history');
  String get clearHistoryConfirm => translate('clear_history_confirm');

  // Settings
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemTheme => translate('system_theme');
  String get stampFormat => translate('stamp_format');
  String get dateFormat => translate('date_format');
  String get timeFormat => translate('time_format');
  String get showAddress => translate('show_address');
  String get showCoordinates => translate('show_coordinates');
  String get about => translate('about');
  String get version => translate('version');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get clearCache => translate('clear_cache');
  String get storageUsed => translate('storage_used');

  // Errors
  String get errorGeneral => translate('error_general');
  String get errorCamera => translate('error_camera');
  String get errorSavingPhoto => translate('error_saving_photo');
  String get errorLoadingPhotos => translate('error_loading_photos');

  // Splash
  String get splashTagline => translate('splash_tagline');
  String get splashAdsNotice => translate('splash_ads_notice');

  // Language selection
  String get selectLanguageTitle => translate('select_language_title');
  String get selectLanguageSubtitle => translate('select_language_subtitle');
  String get pleaseSelectLanguage => translate('please_select_language');
  String get chooseLanguageContinue => translate('choose_language_continue');

  // Intro slides
  String get introSlide1Title => translate('intro_slide_1_title');
  String get introSlide1Desc => translate('intro_slide_1_desc');
  String get introSlide2Title => translate('intro_slide_2_title');
  String get introSlide2Desc => translate('intro_slide_2_desc');
  String get introSlide3Title => translate('intro_slide_3_title');
  String get introSlide3Desc => translate('intro_slide_3_desc');
  String get introSlide4Title => translate('intro_slide_4_title');
  String get introSlide4Desc => translate('intro_slide_4_desc');

  // Legacy intro (backward compat)
  String get introTitle1 => translate('intro_title_1');
  String get introDesc1 => translate('intro_desc_1');
  String get introTitle2 => translate('intro_title_2');
  String get introDesc2 => translate('intro_desc_2');
  String get introTitle3 => translate('intro_title_3');
  String get introDesc3 => translate('intro_desc_3');

  // Home
  String get gpsCameraTitle => translate('gps_camera_title');
  String get photoLibrary => translate('photo_library');
  String get librarySubtitle => translate('library_subtitle');
  String get locationNearby => translate('location_nearby');
  String get popularDestination => translate('popular_destination');
  String get viewAll => translate('view_all');
  String get captureEveryJourney => translate('capture_every_journey');
  String get gpsStampedPhotos => translate('gps_stamped_photos');
  String get captureNow => translate('capture_now');
  String get captureEveryMoment => translate('capture_every_moment');
  String get gpsStampedSubtitle => translate('gps_stamped_subtitle');
  String get gpsVideo => translate('gps_video');

  // Notifications
  String get notificationsTitle => translate('notifications_title');
  String get notificationsEmpty => translate('notifications_empty');
  String notifFriendRequest(String name) =>
      translate('notif_friend_request', params: {'name': name});
  String notifRequestAccepted(String name) =>
      translate('notif_request_accepted', params: {'name': name});
  String notifSharedPhoto(String name) =>
      translate('notif_shared_photo', params: {'name': name});
  String notifSharedVideo(String name) =>
      translate('notif_shared_video', params: {'name': name});
  String notifSharedLocation(String name) =>
      translate('notif_shared_location', params: {'name': name});
  String get markAllRead => translate('mark_all_read');
  String get view => translate('view');
  String get timeJustNow => translate('time_just_now');
  String timeMinutesAgo(String n) =>
      translate('time_minutes_ago', params: {'n': n});
  String timeHoursAgo(String n) => translate('time_hours_ago', params: {'n': n});
  String timeDaysAgo(String n) => translate('time_days_ago', params: {'n': n});

  // Camera screen
  String get cameraAccessNotEnabled => translate('camera_access_not_enabled');
  String get openSettingsHint => translate('open_settings_hint');
  String get openSettings => translate('open_settings');
  String get retake => translate('retake');
  String get captureFailed => translate('capture_failed');
  String get photoSavedLibrary => translate('photo_saved_library');
  String get latShort => translate('lat_short');
  String get lonShort => translate('lon_short');

  // Photo gallery
  String get photoGallery => translate('photo_gallery');
  String get searchByLocation => translate('search_by_location');
  String get noPhotosYet => translate('no_photos_yet');
  String get takeFirstPhoto => translate('take_first_photo');
  String get latestFirst => translate('latest_first');
  String get showOnMap => translate('show_on_map');
  String get showGrid => translate('show_grid');
  String get oldestFirst => translate('oldest_first');

  // Photo detail
  String get photoNotFound => translate('photo_not_found');
  String get date => translate('date');
  String get time => translate('time');
  String get coordinates => translate('coordinates');
  String get openInMap => translate('open_in_map');

  // Map gallery
  String get viewDetail => translate('view_detail');
  String photosCount(int count) => translate('photos_count', params: {'count': count.toString()});
  String get filterAll => translate('filter_all');
  String get filterPhotos => translate('filter_photos');
  String get filterVideos => translate('filter_videos');
  String get filterMine => translate('filter_mine');
  String get filterFriends => translate('filter_friends');
  String get myGallery => translate('my_gallery');
  String sharedBy(String name) => translate('shared_by', params: {'name': name});
  String get friendMediaLoadError => translate('friend_media_load_error');

  // Location sharing
  String get sendMyLocation => translate('send_my_location');
  String get locationSent => translate('location_sent');
  String get receivedLocations => translate('received_locations');
  String get sharedLocationsTitle => translate('shared_locations_title');
  String get sharedLocationsEmpty => translate('shared_locations_empty');
  String get sharedLocationsEmptyDesc => translate('shared_locations_empty_desc');
  String get deleteLocationShare => translate('delete_location_share');
  String get deleteLocationShareConfirm => translate('delete_location_share_confirm');
  String get locationShareDeleted => translate('location_share_deleted');
  String expiresInHours(int hours) => translate('expires_in_hours', params: {'hours': hours.toString()});
  String get expiresSoon => translate('expires_soon');
  String get changeAvatar => translate('change_avatar');
  String get account => translate('account');
  String get editUsername => translate('edit_username');
  String get newUsername => translate('new_username');
  String get usernameUpdated => translate('username_updated');
  String get deleteAccount => translate('delete_account');
  String get deleteAccountWarning => translate('delete_account_warning');
  String get deleteAccountTypeDelete => translate('delete_account_type_delete');
  String get deleteAccountConfirmHint => translate('delete_account_confirm_hint');
  String get accountDeleted => translate('account_deleted');
  String get deleteAccountReauthNeeded => translate('delete_account_reauth_needed');
  String get deletingAccount => translate('deleting_account');
  String get avatarUpdated => translate('avatar_updated');
  String get avatarUpdateFailed => translate('avatar_update_failed');
  String get locationSendFailed => translate('location_send_failed');
  String get locationDenied => translate('location_denied');

  // GPS History
  String get gpsHistoryTitle => translate('gps_history_title');
  String get noHistoryYet => translate('no_history_yet');
  String get historyEmptyDesc => translate('history_empty_desc');

  // Settings
  String get general => translate('general');
  String get support => translate('support');
  String get shareApp => translate('share_app');
  String get upgradePro => translate('upgrade_pro');
  String get upgradeProDesc => translate('upgrade_pro_desc');
  String get appVersion => translate('app_version');
  String get appSubtitle => translate('app_subtitle');
  String get shareText => translate('share_text');

  // Explore
  String get exploreNearby => translate('explore_nearby');
  String get tapOpenMaps => translate('tap_open_maps');
  String get petrolStation => translate('petrol_station');
  String get hospital => translate('hospital');
  String get schoolLabel => translate('school');
  String get restaurant => translate('restaurant');
  String get cafe => translate('cafe');
  String get hotel => translate('hotel');
  String get supermarket => translate('supermarket');
  String get bank => translate('bank');
  String get police => translate('police');
  String get stadium => translate('stadium');
  String get petrol => translate('petrol');
  String get atm => translate('atm');

  // Destinations
  String get popularDestinations => translate('popular_destinations');
  String placesToExplore(int count) => translate('places_to_explore', params: {'count': count.toString()});
  String get noDestinations => translate('no_destinations');
  String get regionAll => translate('region_all');
  String get regionAsia => translate('region_asia');
  String get regionEurope => translate('region_europe');
  String get regionAmericas => translate('region_americas');
  String get regionAfrica => translate('region_africa');
  String get regionOceania => translate('region_oceania');

  // Direction
  String get directionExplore => translate('direction_explore');
  String get goToMap => translate('go_to_map');

  // Destination detail
  String get bestTime => translate('best_time');
  String get climate => translate('climate');
  String get topHighlights => translate('top_highlights');
  String get gpsCoordinates => translate('gps_coordinates');
  String get locationOnMap => translate('location_on_map');
  String get travelTip => translate('travel_tip');
  String get readMore => translate('read_more');
  String get showLess => translate('show_less');
  String get timezoneLabel => translate('timezone_label');
  String get currencyLabel => translate('currency_label');
  String get directions => translate('directions');
  String get directionLabel => translate('direction');
  String get holdToCopy => translate('hold_to_copy');
  String copiedText(String label) => translate('copied_text', params: {'label': label});

  // Permissions
  String get locationAccess => translate('location_access');
  String get locationDeniedForeverMsg => translate('location_denied_forever_msg');
  String get locationDeniedMsg => translate('location_denied_msg');
  String get locationServicesOff => translate('location_services_off');
  String get locationServicesOffMsg => translate('location_services_off_msg');
  String get cameraAccess => translate('camera_access');
  String get cameraDeniedForeverMsg => translate('camera_denied_forever_msg');
  String get cameraDeniedMsg => translate('camera_denied_msg');
  String get notNow => translate('not_now');

  // Router
  String get pageNotFound => translate('page_not_found');
  String get goHome => translate('go_home');

  // Street View & Earth 3D
  String get streetView => translate('street_view');
  String get streetViewOpen => translate('street_view_open');
  String get earth3d => translate('earth_3d');
  String get earth3dOpen => translate('earth_3d_open');
  String get view360 => translate('view_360');
  String get view360NotAvailable => translate('view_360_not_available');
  String get streetViewSearchHint => translate('street_view_search_hint');
  String get streetViewNoResults => translate('street_view_no_results');
  String get streetViewSearching => translate('street_view_searching');
  String get streetViewTapMap => translate('street_view_tap_map');

  // Traffic Map
  String get trafficMap => translate('traffic_map');
  String get trafficMapSubtitle => translate('traffic_map_subtitle');
  String get trafficLayer => translate('traffic_layer');
  String get trafficLegendFree => translate('traffic_legend_free');
  String get trafficLegendSlow => translate('traffic_legend_slow');
  String get trafficLegendHeavy => translate('traffic_legend_heavy');
  String get trafficLegendJam => translate('traffic_legend_jam');
  String get trafficApiKeyMissing => translate('traffic_api_key_missing');

  // Video Camera
  String get videoCamera => translate('video_camera');
  String get videoCameraTitle => translate('video_camera_title');
  String get videoGallery => translate('video_gallery');
  String get videoGalleryEmpty => translate('video_gallery_empty');
  String get videoRecording => translate('video_recording');
  String get videoStartRecord => translate('video_start_record');
  String get videoStopRecord => translate('video_stop_record');
  String get videoSaved => translate('video_saved');
  String get videoSaveFailed => translate('video_save_failed');
  String get videoDelete => translate('video_delete');
  String get videoShare => translate('video_share');
  String videoDuration(int duration) => translate('video_duration', params: {'duration': duration.toString()});
  String videoMaxDuration(int seconds) => translate('video_max_duration', params: {'seconds': seconds.toString()});

  // Friends
  String get friends => translate('friends');
  String get friendsTitle => translate('friends_title');
  String get friendsEmpty => translate('friends_empty');
  String get friendsAdd => translate('friends_add');
  String get friendsSearch => translate('friends_search');
  String get friendsSearchHint => translate('friends_search_hint');
  String get friendsRequestSent => translate('friends_request_sent');
  String get friendsRequestReceived => translate('friends_request_received');
  String get friendsAccept => translate('friends_accept');
  String get friendsDecline => translate('friends_decline');
  String get friendsRemove => translate('friends_remove');
  String get friendsNotFound => translate('friends_not_found');
  String get friendsSend => translate('friends_send');
  String get friendsSent => translate('friends_sent');
  String friendsRemoveConfirm(String name) =>
      translate('friends_remove_confirm', params: {'name': name});
  String get friendsRemoved => translate('friends_removed');
  String get friendsShareLocation => translate('friends_share_location');
  String get friendsLocationOff => translate('friends_location_off');
  String get friendsSeeOnMap => translate('friends_see_on_map');
  String friendsLastSeen(String time) => translate('friends_last_seen', params: {'time': time});
  String get friendsOnline => translate('friends_online');

  // Auth
  String get signIn => translate('sign_in');
  String get signInGoogle => translate('sign_in_google');
  String get signInApple => translate('sign_in_apple');
  String get signInSubtitle => translate('sign_in_subtitle');
  String get register => translate('register');
  String get registerSubtitle => translate('register_subtitle');
  String get username => translate('username');
  String get email => translate('email');
  String get password => translate('password');
  String get needAccountRegister => translate('need_account_register');
  String get haveAccountSignIn => translate('have_account_sign_in');
  String get orContinueWith => translate('or_continue_with');
  String get signOut => translate('sign_out');
  String get usernameSetup => translate('username_setup');
  String get usernameHint => translate('username_hint');
  String get usernameTaken => translate('username_taken');
  String get usernameInvalid => translate('username_invalid');
  String get usernameSave => translate('username_save');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi', 'ja', 'ko', 'zh', 'pt', 'hi', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
