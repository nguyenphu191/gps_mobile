import 'dart:convert';
import 'package:flutter/foundation.dart';

class VideoModel {
  final String id;
  final String videoPath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String address;

  /// Which account recorded it. Null for videos made before this field
  /// existed, or while signed out — those belong to the device, not a user.
  final String? ownerUid;

  const VideoModel({
    required this.id,
    required this.videoPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.address,
    this.ownerUid,
  });

  VideoModel copyWith({
    String? id,
    String? videoPath,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? address,
    String? ownerUid,
  }) {
    return VideoModel(
      id: id ?? this.id,
      videoPath: videoPath ?? this.videoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoPath': videoPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'address': address,
      'ownerUid': ownerUid,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      videoPath: map['videoPath'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      address: map['address'] ?? '',
      ownerUid: map['ownerUid'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoModel.fromJson(String source) =>
      VideoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'VideoModel(id: $id, videoPath: $videoPath, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        videoPath.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        timestamp.hashCode ^
        address.hashCode;
  }
}
