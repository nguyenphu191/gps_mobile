import 'dart:convert';

class PhotoModel {
  final String id;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  /// Which account captured it. Null for photos taken before this field
  /// existed, or while signed out — those belong to the device, not a user.
  final String? ownerUid;

  const PhotoModel({
    required this.id,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.ownerUid,
  });

  PhotoModel copyWith({
    String? id,
    String? imagePath,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
    String? ownerUid,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'ownerUid': ownerUid,
    };
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      ownerUid: map['ownerUid'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory PhotoModel.fromJson(String source) =>
      PhotoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PhotoModel(id: $id, imagePath: $imagePath, latitude: $latitude, '
        'longitude: $longitude, address: $address, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
