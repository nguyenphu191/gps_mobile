import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';

/// UIDs of accepted friends of the signed-in user.
final friendUidsProvider = Provider<List<String>>((ref) {
  // Watched, not read: on a cold start Firebase restores the session after the
  // first build. With a null uid the mapping below would return *our own* uid
  // for every friendship we sent, and the media query would come back empty.
  final myUid = ref.watch(authStateProvider).value?.uid;
  if (myUid == null) {
    // debugPrint('🔎 [FriendMedia] no uid yet — friend list empty');
    return const [];
  }

  final friends =
      ref.watch(friendsStreamProvider).valueOrNull ?? const <FriendModel>[];
  final accepted = friends
      .where((f) => f.status == FriendStatus.accepted)
      .toList();

  final uids = accepted
      .map((f) => f.senderId == myUid ? f.receiverId : f.senderId)
      .toSet()
      .toList();

  // debugPrint(
  //   '🔎 [FriendMedia] myUid=$myUid  friendships=${friends.length}  '
  //   'accepted=${accepted.length}  friendUids=$uids',
  // );
  return uids;
});
