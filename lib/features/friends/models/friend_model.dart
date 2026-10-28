enum FriendStatus { pending, accepted, declined }

class FriendModel {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendStatus status;
  final DateTime createdAt;

  FriendModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map, String docId) {
    return FriendModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: FriendStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => FriendStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }
}
