import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/map_media_item.dart';
import '../../../shared/providers/gallery_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../friends/providers/friend_profiles_provider.dart';
import '../../friends/providers/friend_uids_provider.dart';
import '../../sharing/models/shared_media_model.dart';
import '../../sharing/services/media_share_service.dart';
import '../../video_camera/providers/video_gallery_provider.dart';

/// Media shared by accepted friends (live).
final friendsMediaProvider = StreamProvider<List<SharedMediaModel>>((ref) {
  final uids = ref.watch(friendUidsProvider);
  // debugPrint(
  //   '🔎 [FriendMedia] querying shared_media for ${uids.length} uid(s)',
  // );
  if (uids.isEmpty) return Stream.value(const []);
  return ref.watch(mediaShareServiceProvider).friendsMedia(uids);
});

/// Everything shown on the map gallery: own photos + own videos + friends'
/// shared media, newest first.
final mapMediaProvider = Provider<List<MapMediaItem>>((ref) {
  // Watched so the list is rebuilt (and cleared) when the session changes.
  final myUid = ref.watch(authStateProvider).value?.uid;

  final shared = ref.watch(friendsMediaProvider).valueOrNull ?? const [];

  // The server is the authority on who posted a piece of media: a shared
  // document has exactly one owner. Local records made before `ownerUid`
  // existed carry no owner, so they are matched back against these.
  final serverOwnerById = {for (final m in shared) m.id: m.ownerUid};

  /// True when this local record was captured by somebody else — either it is
  /// stamped with another account, or an untagged record turns out to match a
  /// document owned by a friend. Both happen when two accounts are used on one
  /// device, because signing out does not clear the local gallery.
  bool belongsToSomeoneElse(String id, String? ownerUid) {
    // Signed out there is nobody to compare against, and this device's media is
    // all the user has — hiding it would leave them staring at an empty
    // gallery.
    if (myUid == null) return false;
    final owner = ownerUid ?? serverOwnerById[id];
    return owner != null && owner != myUid;
  }

  final items = <MapMediaItem>[
    ...ref
        .watch(galleryProvider)
        .where((p) => !belongsToSomeoneElse(p.id, p.ownerUid))
        .map(MapMediaItem.fromPhoto),
    ...ref
        .watch(videoGalleryProvider)
        .where((v) => !belongsToSomeoneElse(v.id, v.ownerUid))
        .map(MapMediaItem.fromVideo),
  ];

  // Scoped by owner. Media ids are per-device UUIDs, so comparing a friend's
  // id against our local ids drops their item the moment the two collide —
  // which is exactly what happens when two accounts share one device's local
  // gallery. `ownerUid == myUid` is the correct test for "my own copy".
  final seenShared = <String>{};
  var skippedMine = 0;
  var skippedDuplicate = 0;
  for (final media in shared) {
    // Never show our own uploads twice — the local copy wins.
    if (media.ownerUid == myUid) {
      skippedMine++;
      continue;
    }
    final key = '${media.ownerUid}/${media.id}';
    if (!seenShared.add(key)) {
      skippedDuplicate++;
      continue;
    }
    items.add(MapMediaItem.fromShared(media));
  }

  // debugPrint(
  //   '🔎 [FriendMedia] shared docs=${shared.length}  '
  //   'skippedMine=$skippedMine  skippedDuplicate=$skippedDuplicate  '
  //   'shown=${shared.length - skippedMine - skippedDuplicate}',
  // );

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
});

/// A friend who has shared media, with their most recent item — used by the
/// map gallery to jump straight to someone who is far away.
class FriendMediaSummary {
  final String uid;
  final String name;
  final String photoUrl;
  final MapMediaItem latest;
  final int count;

  const FriendMediaSummary({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.latest,
    required this.count,
  });
}

final friendsWithMediaProvider = Provider<List<FriendMediaSummary>>((ref) {
  final byFriend = <String, List<MapMediaItem>>{};
  for (final item in ref.watch(mapMediaProvider)) {
    if (item.isMine) continue;
    byFriend.putIfAbsent(item.ownerUid!, () => []).add(item);
  }

  // Prefer the live profile: the name/avatar stored on each media doc is a
  // snapshot from upload time.
  final profiles = ref.watch(friendProfilesProvider).valueOrNull ?? const {};

  final summaries = byFriend.entries.map((entry) {
    // mapMediaProvider is already newest-first, so the head is the latest.
    final latest = entry.value.first;
    final profile = profiles[entry.key];
    return FriendMediaSummary(
      uid: entry.key,
      name: profile?.username.isNotEmpty == true
          ? profile!.username
          : (profile?.displayName.isNotEmpty == true
                ? profile!.displayName
                : (latest.ownerName ?? '')),
      photoUrl: profile?.photoUrl.isNotEmpty == true
          ? profile!.photoUrl
          : (latest.ownerPhotoUrl ?? ''),
      latest: latest,
      count: entry.value.length,
    );
  }).toList();

  summaries.sort((a, b) => b.latest.timestamp.compareTo(a.latest.timestamp));
  return summaries;
});
