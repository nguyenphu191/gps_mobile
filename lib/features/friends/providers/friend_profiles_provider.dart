import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user_model.dart';
import 'friend_uids_provider.dart';

/// Live profiles of accepted friends, keyed by uid.
///
/// Avatar/name are copied into share documents at write time, so anything
/// reading those copies shows a stale picture. Reading the profile itself
/// keeps every avatar current, including on old shares.
final friendProfilesProvider = StreamProvider<Map<String, UserModel>>((ref) {
  final uids = ref.watch(friendUidsProvider);
  if (uids.isEmpty) return Stream.value(const {});

  final firestore = FirebaseFirestore.instance;

  // Firestore caps `whereIn` at 30 values; chunk and merge like
  // MediaShareService.friendsMedia does.
  const chunkSize = 10;
  final chunks = <List<String>>[];
  for (var i = 0; i < uids.length; i += chunkSize) {
    chunks.add(
      uids.sublist(
        i,
        i + chunkSize > uids.length ? uids.length : i + chunkSize,
      ),
    );
  }

  final latest = List<Map<String, UserModel>>.filled(chunks.length, const {});
  final controller = StreamController<Map<String, UserModel>>();
  final subs = <StreamSubscription>[];

  void emit() {
    if (controller.isClosed) return;
    controller.add({for (final chunk in latest) ...chunk});
  }

  for (var i = 0; i < chunks.length; i++) {
    final index = i;
    subs.add(
      firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunks[index])
          .snapshots()
          .listen(
            (snapshot) {
              latest[index] = {
                for (final doc in snapshot.docs)
                  doc.id: UserModel.fromMap(doc.data(), doc.id),
              };
              emit();
            },
            onError: (Object e) {
              debugPrint('🔥 [FriendProfiles] stream error: $e');
              latest[index] = const {};
              emit();
            },
          ),
    );
  }

  controller.onCancel = () async {
    for (final sub in subs) {
      await sub.cancel();
    }
  };

  return controller.stream;
});
