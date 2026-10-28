enum NotificationType {
  friendMedia('friend_media'),
  friendRequest('friend_request'),
  friendRequestAccepted('friend_request_accepted'),
  locationShare('location_share'),
  unknown('unknown');

  final String wire;
  const NotificationType(this.wire);

  /// Never throws: a type written by a newer build simply renders as a plain
  /// row instead of crashing the whole list.
  static NotificationType fromWire(String? value) {
    for (final type in NotificationType.values) {
      if (type.wire == value) return type;
    }
    return NotificationType.unknown;
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String fromUid;
  final String fromName;
  final String fromPhotoUrl;
  final DateTime createdAt;
  final bool read;

  // friend_media
  final String? mediaId;
  final String? mediaKind; // 'photo' | 'video'
  final String? thumbnailUrl;

  // friend_request — the friends/{id} doc the Accept/Delete buttons act on
  final String? friendDocId;

  // location_share
  final double? latitude;
  final double? longitude;
  final String? address;

  const AppNotification({
    required this.id,
    required this.type,
    required this.fromUid,
    required this.fromName,
    required this.fromPhotoUrl,
    required this.createdAt,
    required this.read,
    this.mediaId,
    this.mediaKind,
    this.thumbnailUrl,
    this.friendDocId,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      type: NotificationType.fromWire(map['type'] as String?),
      fromUid: map['fromUid'] as String? ?? '',
      fromName: map['fromName'] as String? ?? '',
      fromPhotoUrl: map['fromPhotoUrl'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      read: map['read'] as bool? ?? false,
      mediaId: map['mediaId'] as String?,
      mediaKind: map['mediaKind'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      friendDocId: map['friendDocId'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.wire,
    'fromUid': fromUid,
    'fromName': fromName,
    'fromPhotoUrl': fromPhotoUrl,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'read': read,
    if (mediaId != null) 'mediaId': mediaId,
    if (mediaKind != null) 'mediaKind': mediaKind,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (friendDocId != null) 'friendDocId': friendDocId,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (address != null) 'address': address,
  };
}
