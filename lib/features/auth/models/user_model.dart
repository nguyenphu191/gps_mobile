class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String username;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastSeen;
  final bool isLocationShared;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.username,
    this.lastLatitude,
    this.lastLongitude,
    this.lastSeen,
    this.isLocationShared = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'username': username,
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'isLocationShared': isLocationShared,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      username: map['username'] ?? '',
      lastLatitude: map['lastLatitude']?.toDouble(),
      lastLongitude: map['lastLongitude']?.toDouble(),
      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
          : null,
      isLocationShared: map['isLocationShared'] ?? true,
    );
  }
}
