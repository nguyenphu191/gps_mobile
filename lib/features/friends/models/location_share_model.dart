import 'package:cloud_firestore/cloud_firestore.dart';

/// A one-shot location a friend sent to another friend
/// (Firestore collection `location_shares`).
///
/// Shares live for [lifetime]; after that they are hidden by the app and
/// removed by the Firestore TTL policy on `expiresAt`.
class LocationShareModel {
  final String id;
  final String fromUid;
  final String fromName;
  final String fromPhotoUrl;
  final String toUid;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;

  const LocationShareModel({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.fromPhotoUrl,
    required this.toUid,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
  });

  static const Duration lifetime = Duration(hours: 24);

  DateTime get expiresAt => createdAt.add(lifetime);
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  Duration get remaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'fromName': fromName,
      'fromPhotoUrl': fromPhotoUrl,
      'toUid': toUid,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.millisecondsSinceEpoch,
      // Must be a Timestamp: Firestore TTL policies only accept that type.
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory LocationShareModel.fromMap(Map<String, dynamic> map, String docId) {
    return LocationShareModel(
      id: docId,
      fromUid: map['fromUid'] as String? ?? '',
      fromName: map['fromName'] as String? ?? '',
      fromPhotoUrl: map['fromPhotoUrl'] as String? ?? '',
      toUid: map['toUid'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      address: map['address'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
