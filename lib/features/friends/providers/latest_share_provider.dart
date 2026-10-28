import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_share_model.dart';
import '../services/friend_service.dart';

/// fromUid → the newest unexpired location that friend shared with me.
///
/// `receivedLocationsProvider` already orders newest-first and drops expired
/// shares, so the first entry seen for a uid is the one to keep.
final latestShareByFriendProvider = Provider<Map<String, LocationShareModel>>((
  ref,
) {
  final shares = ref.watch(receivedLocationsProvider).valueOrNull;
  if (shares == null) return const {};

  final latest = <String, LocationShareModel>{};
  for (final share in shares) {
    latest.putIfAbsent(share.fromUid, () => share);
  }
  return latest;
});
