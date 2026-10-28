import '../../../shared/models/map_media_item.dart';

/// A photo or video hosted on Cloudinary and indexed in the `shared_media`
/// Firestore collection so friends can see it on the map.
class SharedMediaModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String ownerPhotoUrl;
  final MediaKind kind;

  /// Cloudinary `public_id` of the asset.
  final String storagePath;

  /// Cloudinary `secure_url`.
  final String downloadUrl;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  const SharedMediaModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.ownerPhotoUrl,
    required this.kind,
    required this.storagePath,
    required this.downloadUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'type': kind.name,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory SharedMediaModel.fromMap(Map<String, dynamic> map, String docId) {
    return SharedMediaModel(
      id: docId,
      ownerUid: map['ownerUid'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhotoUrl: map['ownerPhotoUrl'] as String? ?? '',
      kind: map['type'] == MediaKind.video.name
          ? MediaKind.video
          : MediaKind.photo,
      storagePath: map['storagePath'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      address: map['address'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
