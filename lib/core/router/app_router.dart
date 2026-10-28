import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../analytics/analytics_observer.dart';
import '../constants/app_constants.dart';
import '../di/service_locator.dart';
import 'app_shell.dart';
import 'aurora_transitions.dart';
import '../localization/app_localizations.dart';
import '../../shared/widgets/gradient_button.dart';

import '../../features/destination/all_destinations_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/gps_camera/gps_camera_screen.dart';
import '../../features/gps_history/gps_history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/intro/intro_screen.dart';
import '../../features/language/language_screen.dart';
import '../../features/language/language_settings_screen.dart';
import '../../features/map_gallery/map_gallery_screen.dart';
import '../../features/photo_detail/photo_detail_screen.dart';
import '../../features/photo_gallery/gallery_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/personal_information_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/panorama/panorama_screen.dart';
import '../../features/friends/shared_locations_screen.dart';
import '../../features/street_view/street_view_screen.dart';
import '../../features/traffic_map/traffic_map_screen.dart';
import '../../features/video_camera/video_camera_screen.dart';
import '../../features/video_camera/video_gallery_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/username_setup_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/notifications/notification_screen.dart';
import '../../features/friends/add_friend_screen.dart';
import '../../features/friends/friend_map_screen.dart';
import '../../features/auth/services/auth_service.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String intro = '/intro';
  static const String language = '/language';
  static const String languageSettings = '/language-settings';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String mapGallery = '/map-gallery';
  static const String gallery = '/gallery';
  static const String photoDetail = '/photo-detail/:id';
  static const String history = '/history';
  static const String explore = '/explore';
  static const String destinationDetail = '/destination/:id';
  static const String settings = '/settings';
  static const String allDestinations = '/all-destinations';
  static const String panorama = '/panorama';
  static const String streetViewRoute = '/street-view';
  static const String trafficMapRoute = '/traffic';
  static const String videoCamera = '/video-camera';
  static const String videoGallery = '/video-gallery';
  static const String auth = '/auth';
  static const String usernameSetup = '/username-setup';
  static const String friends = '/friends';
  static const String addFriend = '/add-friend';
  static const String friendMap = '/friend-map';
  static const String sharedLocations = '/shared-locations';
  static const String notifications = '/notifications';
  static const String personalInformation = '/personal-information';
  static const String friendProfile = '/friend-profile/:uid';
  static String friendProfilePath(String uid) => '/friend-profile/$uid';

  static String destinationDetailPath(String id) => '/destination/$id';

  static String photoDetailPath(String id) => '/photo-detail/$id';

  /// Street View opened at a known point (destination, photo, video).
  /// One place builds the query so no caller forgets to encode the name.
  static String streetViewAt(
    double latitude,
    double longitude, {
    String? name,
  }) {
    final query = 'lat=$latitude&lng=$longitude';
    if (name == null || name.isEmpty) return '$streetViewRoute?$query';
    return '$streetViewRoute?$query&name=${Uri.encodeComponent(name)}';
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    observers: [getIt<AnalyticsObserver>()],
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => AuroraPage.fadeThrough(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.intro,
        pageBuilder: (context, state) => AuroraPage.fadeThrough(state, const IntroScreen()),
      ),
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => AuroraPage.fadeThrough(state, const LanguageScreen()),
      ),
      GoRoute(
        path: AppRoutes.languageSettings,
        pageBuilder: (context, state) => AuroraPage.push(state, const LanguageSettingsScreen()),
      ),
      // The four tabs live in one shell so switching tabs keeps their state.
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(shell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            AnimatedBranchContainer(
              currentIndex: shell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.gallery,
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const GalleryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.friends,
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const FriendsScreen()),
                redirect: (context, state) {
                  final user = ref.read(authServiceProvider).currentUser;
                  if (user == null) {
                    return '${AppRoutes.auth}?next=${AppRoutes.friends}';
                  }
                  return null;
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
        pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.camera,
        pageBuilder: (context, state) => AuroraPage.slideUp(state, const GpsCameraScreen()),
      ),
      GoRoute(
        path: AppRoutes.mapGallery,
        pageBuilder: (context, state) => AuroraPage.push(state, const MapGalleryScreen()),
      ),
      GoRoute(
        path: AppRoutes.photoDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AuroraPage.push(state, PhotoDetailScreen(photoId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) => AuroraPage.push(state, const GpsHistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.explore,
        pageBuilder: (context, state) => AuroraPage.push(state, const ExploreScreen()),
      ),

      GoRoute(
        path: AppRoutes.allDestinations,
        pageBuilder: (context, state) => AuroraPage.push(state, const AllDestinationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.panorama,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return AuroraPage.push(state, PanoramaScreen(
            url: params['url'] ?? '',
            title: params['title'],
            allowNavigate: params['nav'] == '1',
            latitude: double.tryParse(params['lat'] ?? ''),
            longitude: double.tryParse(params['lng'] ?? ''),
          ));
        },
      ),
      GoRoute(
        path: AppRoutes.streetViewRoute,
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return AuroraPage.push(
            state,
            StreetViewScreen(
              initialLatitude: double.tryParse(params['lat'] ?? ''),
              initialLongitude: double.tryParse(params['lng'] ?? ''),
              initialName: params['name'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trafficMapRoute,
        pageBuilder: (context, state) => AuroraPage.push(state, const TrafficMapScreen()),
      ),
      GoRoute(
        path: AppRoutes.videoCamera,
        pageBuilder: (context, state) => AuroraPage.slideUp(state, const VideoCameraScreen()),
      ),
      GoRoute(
        path: AppRoutes.videoGallery,
        pageBuilder: (context, state) => AuroraPage.push(state, const VideoGalleryScreen()),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) {
          final next = state.uri.queryParameters['next'] ?? AppRoutes.home;
          return AuroraPage.slideUp(state, AuthScreen(nextRoute: next));
        },
      ),
      GoRoute(
        path: AppRoutes.usernameSetup,
        pageBuilder: (context, state) {
          final next = state.uri.queryParameters['next'] ?? AppRoutes.home;
          return AuroraPage.fadeThrough(
            state,
            UsernameSetupScreen(nextRoute: next),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.personalInformation,
        pageBuilder: (context, state) => AuroraPage.push(state, const PersonalInformationScreen()),
      ),
      GoRoute(
        path: AppRoutes.friendProfile,
        pageBuilder: (context, state) => AuroraPage.push(
          state,
          PersonalInformationScreen(uid: state.pathParameters['uid']),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => AuroraPage.push(state, const NotificationScreen()),
      ),
      GoRoute(
        path: AppRoutes.sharedLocations,
        pageBuilder: (context, state) => AuroraPage.push(state, const SharedLocationsScreen()),
        redirect: (context, state) {
          final user = ref.read(authServiceProvider).currentUser;
          if (user == null) {
            return '${AppRoutes.auth}?next=${AppRoutes.sharedLocations}';
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.addFriend,
        pageBuilder: (context, state) => AuroraPage.push(state, const AddFriendScreen()),
      ),
      GoRoute(
        path: AppRoutes.friendMap,
        pageBuilder: (context, state) => AuroraPage.push(
          state,
          FriendMapScreen(
            focusLatitude: double.tryParse(
              state.uri.queryParameters['lat'] ?? '',
            ),
            focusLongitude: double.tryParse(
              state.uri.queryParameters['lng'] ?? '',
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final t = AppLocalizations.of(context);
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                t.pageNotFound,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: t.goHome,
                expand: false,
                height: 48,
                borderRadius: AppConstants.buttonRadius,
                onTap: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      );
    },
  );
});
