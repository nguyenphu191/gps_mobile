import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/push_notification_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/app_notification.dart';

/// Reads and writes the per-user notification inbox
/// (`users/{uid}/notifications`).
///
/// There are no Cloud Functions in this project, so notifications are fanned
/// out by the *sender's* device: it writes a document into each recipient's
/// inbox and then asks the push worker to deliver a banner. Every write here
/// is best-effort — a failed notification must never fail the action that
/// triggered it (posting a photo, sending a friend request).
class NotificationService {
  final String currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PushNotificationService _push = PushNotificationService();

  NotificationService(this.currentUserId);

  CollectionReference<Map<String, dynamic>> _inboxOf(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  // ─── Reading my inbox ─────────────────────────────────────────

  Stream<List<AppNotification>> inboxStream() {
    return _inboxOf(currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> markRead(String id) async {
    try {
      await _inboxOf(currentUserId).doc(id).update({'read': true});
    } catch (e) {
      debugPrint('🔔 [Notif] markRead failed: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      final unread = await _inboxOf(
        currentUserId,
      ).where('read', isEqualTo: false).get();
      if (unread.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('🔔 [Notif] markAllRead failed: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _inboxOf(currentUserId).doc(id).delete();
    } catch (e) {
      debugPrint('🔔 [Notif] delete failed: $e');
    }
  }

  Future<void> deleteByFriendDocId(String friendDocId) async {
    try {
      final snap = await _inboxOf(
        currentUserId,
      ).where('friendDocId', isEqualTo: friendDocId).get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('🔔 [Notif] deleteByFriendDocId failed: $e');
    }
  }

  // ─── Sending ──────────────────────────────────────────────────

  /// Notify one user. [title]/[body] are what the push banner shows; the
  /// in-app row builds its own text from [type] and the sender's name.
  Future<void> notifyUser({
    required String toUid,
    required NotificationType type,
    required String pushTitle,
    required String pushBody,
    String? mediaId,
    String? mediaKind,
    String? thumbnailUrl,
    String? friendDocId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    if (toUid == currentUserId) return;
    await _fanOut(
      toUids: [toUid],
      type: type,
      pushTitle: pushTitle,
      pushBody: pushBody,
      mediaId: mediaId,
      mediaKind: mediaKind,
      thumbnailUrl: thumbnailUrl,
      friendDocId: friendDocId,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  /// Add a row to someone's inbox without sending a push.
  ///
  /// Used where a push has already gone out through another path (location
  /// sharing), so the recipient does not get two banners for one event.
  Future<void> writeInboxOnly({
    required String toUid,
    required NotificationType type,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    if (toUid == currentUserId) return;
    await _fanOut(
      toUids: [toUid],
      type: type,
      latitude: latitude,
      longitude: longitude,
      address: address,
      push: false,
    );
  }

  /// Notify every accepted friend — used when I post a photo or a video.
  Future<void> notifyFriends({
    required NotificationType type,
    required String pushTitle,
    required String pushBody,
    String? mediaId,
    String? mediaKind,
    String? thumbnailUrl,
  }) async {
    try {
      final uids = await _acceptedFriendUids();
      if (uids.isEmpty) return;
      await _fanOut(
        toUids: uids,
        type: type,
        pushTitle: pushTitle,
        pushBody: pushBody,
        mediaId: mediaId,
        mediaKind: mediaKind,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      debugPrint('🔔 [Notif] notifyFriends failed: $e');
    }
  }

  Future<List<String>> _acceptedFriendUids() async {
    final snap = await _firestore
        .collection('friends')
        .where(
          Filter.or(
            Filter('senderId', isEqualTo: currentUserId),
            Filter('receiverId', isEqualTo: currentUserId),
          ),
        )
        .get();

    return snap.docs
        .where((d) => d.data()['status'] == 'accepted')
        .map(
          (d) => d.data()['senderId'] == currentUserId
              ? d.data()['receiverId'] as String
              : d.data()['senderId'] as String,
        )
        .toSet()
        .toList();
  }

  Future<void> _fanOut({
    required List<String> toUids,
    required NotificationType type,
    String pushTitle = '',
    String pushBody = '',
    bool push = true,
    String? mediaId,
    String? mediaKind,
    String? thumbnailUrl,
    String? friendDocId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      final me = await _firestore.collection('users').doc(currentUserId).get();
      final myData = me.data() ?? const <String, dynamic>{};
      final myName = _displayNameOf(myData);
      final myPhoto = myData['photoUrl'] as String? ?? '';

      final notification = AppNotification(
        id: '',
        type: type,
        fromUid: currentUserId,
        fromName: myName,
        fromPhotoUrl: myPhoto,
        createdAt: DateTime.now(),
        read: false,
        mediaId: mediaId,
        mediaKind: mediaKind,
        thumbnailUrl: thumbnailUrl,
        friendDocId: friendDocId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      final payload = notification.toMap();

      final batch = _firestore.batch();
      for (final uid in toUids) {
        batch.set(_inboxOf(uid).doc(), payload);
      }
      await batch.commit();

      if (!push) return;

      // The banner is a bonus: gather everyone's tokens and try once.
      final tokens = <String>[];
      for (final uid in toUids) {
        final doc = await _firestore.collection('users').doc(uid).get();
        final list = doc.data()?['fcmTokens'];
        if (list is List) tokens.addAll(list.whereType<String>());
      }

      await _push.sendPush(
        tokens: tokens,
        title: pushTitle,
        body: pushBody,
        data: {
          'type': type.wire,
          if (mediaId != null) 'mediaId': mediaId,
          if (latitude != null) 'latitude': '$latitude',
          if (longitude != null) 'longitude': '$longitude',
        },
      );
    } catch (e) {
      debugPrint('🔔 [Notif] fan-out failed: $e');
    }
  }

  static String _displayNameOf(Map<String, dynamic> data) {
    final display = data['displayName'] as String? ?? '';
    if (display.isNotEmpty) return display;
    final username = data['username'] as String? ?? '';
    return username.isNotEmpty ? username : 'Someone';
  }
}

final notificationServiceProvider = Provider<NotificationService?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return NotificationService(user.uid);
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((
  ref,
) {
  final service = ref.watch(notificationServiceProvider);
  if (service == null) return Stream.value(const []);
  return service.inboxStream();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsStreamProvider).valueOrNull;
  if (items == null) return 0;
  return items.where((n) => !n.read).length;
});
