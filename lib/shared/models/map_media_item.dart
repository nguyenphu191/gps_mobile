import '../../features/sharing/models/shared_media_model.dart';
import '../../features/video_camera/models/video_model.dart';
import 'photo_model.dart';

enum MediaKind { photo, video }

/// Read-only view of a piece of media placed on the map — either a local
/// photo/video of the current user, or one shared by a friend.
class MapMediaItem {
  final String id;
  final MediaKind kind;

  /// Set for the current user's own media.
  final String? localPath;

  /// Set for media shared by a friend (Cloudinary secure URL).
  final String? remoteUrl;

  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  /// Null when the item belongs to the current user.
  final String? ownerUid;
  final String? ownerName;
  final String? ownerPhotoUrl;

  const MapMediaItem({
    required this.id,
    required this.kind,
    this.localPath,
    this.remoteUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
    this.ownerUid,
    this.ownerName,
    this.ownerPhotoUrl,
  });

  bool get isMine => ownerUid == null;
  bool get isVideo => kind == MediaKind.video;

  factory MapMediaItem.fromPhoto(PhotoModel photo) => MapMediaItem(
    id: photo.id,
    kind: MediaKind.photo,
    localPath: photo.imagePath,
    latitude: photo.latitude,
    longitude: photo.longitude,
    address: photo.address,
    timestamp: photo.timestamp,
  );

  factory MapMediaItem.fromVideo(VideoModel video) => MapMediaItem(
    id: video.id,
    kind: MediaKind.video,
    localPath: video.videoPath,
    latitude: video.latitude,
    longitude: video.longitude,
    address: video.address,
    timestamp: video.timestamp,
  );

  factory MapMediaItem.fromShared(SharedMediaModel media) => MapMediaItem(
    id: media.id,
    kind: media.kind,
    remoteUrl: media.downloadUrl,
    latitude: media.latitude,
    longitude: media.longitude,
    address: media.address,
    timestamp: media.timestamp,
    ownerUid: media.ownerUid,
    ownerName: media.ownerName,
    ownerPhotoUrl: media.ownerPhotoUrl,
  );
}
