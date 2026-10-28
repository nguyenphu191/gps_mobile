import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../router/app_router.dart';

/// The Android channel a push lands in. Must match the
/// `default_notification_channel_id` meta-data in AndroidManifest.xml,
/// otherwise Android silently drops backgrounded notifications.
const String kNotificationChannelId = 'gpscam_default';
const String kNotificationChannelName = 'General notifications';

/// FCM plumbing: keeps this device's token on the user doc, shows a banner
/// while the app is in the foreground, and relays pushes through the small
/// signing endpoint (see server/README.md — a push can't be sent from the
/// client because it must be signed with a service account).
class PushNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  /// Ask for permission, store the token, and wire up tap handling.
  /// Safe to call on every sign-in; does its work only once.
  Future<void> initialise() async {
    if (_initialised) return;
    _initialised = true;

    try {
      await _messaging.requestPermission();
      await _initLocalNotifications();

      // iOS shows nothing in the foreground unless it is asked to.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _saveToken(await _messaging.getToken());
      _messaging.onTokenRefresh.listen(_saveToken);

      // Arrived while the app is open: the OS does not draw a banner for us
      // on Android, so one is drawn locally.
      FirebaseMessaging.onMessage.listen(_showForegroundBanner);

      // Tapped while the app was in the background.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

      // Tapped while the app was terminated.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _handleTap(initial);
    } catch (e) {
      debugPrint('🔥 [Push] init failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // firebase_messaging already asked; asking twice shows nothing.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = (jsonDecode(payload) as Map).cast<String, dynamic>();
          _routeForData(data.map((k, v) => MapEntry(k, v?.toString())));
        } catch (_) {
          // A malformed payload should never take the app down.
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            kNotificationChannelId,
            kNotificationChannelName,
            importance: Importance.high,
          ),
        );
  }

  void _showForegroundBanner(RemoteMessage message) {
    // iOS already draws its own banner in the foreground via setForegroundNotificationPresentationOptions.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return;

    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      // Same id per message so a rapid burst does not stack endlessly.
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kNotificationChannelId,
          kNotificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _saveToken(String? token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || token == null || token.isEmpty) return;
    try {
      // A user can be signed in on several devices.
      await _firestore.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('🔥 [Push] could not save token: $e');
    }
  }

  /// Drop this device's token so it stops receiving pushes after sign-out.
  Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
      debugPrint('🔥 [Push] could not clear token: $e');
    }
  }

  void _handleTap(RemoteMessage message) {
    _routeForData(message.data.map((k, v) => MapEntry(k, v?.toString())));
  }

  void _routeForData(Map<String, String?> data) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    switch (data['type']) {
      case 'location_share':
        final lat = data['latitude'];
        final lng = data['longitude'];
        if (lat != null && lng != null) {
          context.push('/friend-map?lat=$lat&lng=$lng');
        } else {
          context.push('/friend-map');
        }
      case 'friend_media':
        context.push('/map-gallery');
      default:
        // Friend requests and anything unrecognised: the inbox explains it.
        context.push('/notifications');
    }
  }

  /// Relay a push through the signing endpoint.
  ///
  /// Fire and forget: the Firestore document is the source of truth, so a
  /// failed push only costs the banner, never the notification itself.
  /// The worker caps each call at 20 tokens, so callers are batched here.
  Future<void> sendPush({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    if (tokens.isEmpty) return;
    if (AppConstants.pushEndpoint.isEmpty) {
      debugPrint('🔥 [Push] endpoint not configured, skipping notification');
      return;
    }

    for (var i = 0; i < tokens.length; i += 20) {
      final batch = tokens.sublist(i, (i + 20).clamp(0, tokens.length));
      try {
        await http
            .post(
              Uri.parse(AppConstants.pushEndpoint),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'tokens': batch,
                'title': title,
                'body': body,
                'data': data,
              }),
            )
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint('🔥 [Push] notify failed: $e');
      }
    }
  }

  /// Notify a friend that a location was shared with them.
  Future<void> notifyLocationShared({
    required List<String> tokens,
    required String fromName,
    required String address,
    required double latitude,
    required double longitude,
  }) {
    return sendPush(
      tokens: tokens,
      title: fromName,
      body: address,
      data: {
        'type': 'location_share',
        'latitude': '$latitude',
        'longitude': '$longitude',
      },
    );
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);
