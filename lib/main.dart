import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'shared/providers/language_provider.dart' as lang;
import 'shared/providers/theme_provider.dart';
import 'core/di/service_locator.dart';
import 'core/services/push_notification_service.dart';
import 'features/auth/services/auth_service.dart';
import 'features/friends/services/friend_service.dart';
import 'features/video_camera/providers/video_gallery_provider.dart';
import 'shared/providers/gallery_provider.dart';

/// Runs in its own isolate when a push arrives with the app backgrounded or
/// killed. The OS draws the banner itself from the message's `notification`
/// block; this handler exists so data-only messages are not dropped, and it
/// must stay a top-level function with the vm:entry-point pragma.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔔 [Push] background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('photos');
  await Hive.openBox('location_history');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await configureDependencies();
  await initFirebaseAnalyticsForAds();

  runApp(const ProviderScope(child: GPSCameraApp()));
}

class GPSCameraApp extends ConsumerWidget {
  const GPSCameraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Register this device for pushes as soon as somebody is signed in.
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        ref.read(pushNotificationServiceProvider).initialise();
        // Local media captured before photos carried an owner belongs to
        // whoever signs in first — otherwise the next account inherits it.
        ref.read(galleryProvider.notifier).claimUntagged(user.uid);
        ref.read(videoGalleryProvider.notifier).claimUntagged(user.uid);
        // Firestore TTL needs the Blaze plan, so expired location shares are
        // cleaned up from the client — as early as possible after sign-in.
        ref.read(friendServiceProvider)?.purgeExpiredLocationShares();
      }
    });

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(lang.localeProvider);

    return MaterialApp.router(
      title: 'LocaShot GPS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
