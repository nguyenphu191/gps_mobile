import 'dart:convert';

class LocationHistoryModel {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  const LocationHistoryModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  LocationHistoryModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
  }) {
    return LocationHistoryModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory LocationHistoryModel.fromMap(Map<String, dynamic> map) {
    return LocationHistoryModel(
      id: map['id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationHistoryModel.fromJson(String source) =>
      LocationHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LocationHistoryModel(id: $id, latitude: $latitude, '
        'longitude: $longitude, address: $address, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationHistoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
