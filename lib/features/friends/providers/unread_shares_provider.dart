import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../services/friend_service.dart';

const String _lastSeenKey = 'last_seen_location_share';

/// Timestamp (ms) of the newest received location the user has already seen.
/// Kept in Hive so the badge doesn't reappear on every launch.
class LastSeenShareNotifier extends StateNotifier<int> {
  final StorageService _storage;

  LastSeenShareNotifier(this._storage)
    : super(_storage.getSetting<int>(_lastSeenKey) ?? 0);

  Future<void> markSeen(int timestampMs) async {
    if (timestampMs <= state) return;
    state = timestampMs;
    await _storage.saveSetting(_lastSeenKey, timestampMs);
  }
}

final lastSeenShareProvider = StateNotifierProvider<LastSeenShareNotifier, int>(
  (ref) => LastSeenShareNotifier(ref.watch(storageServiceProvider)),
);

/// How many received locations the user hasn't opened the Friends screen for.
final unreadSharesProvider = Provider<int>((ref) {
  final lastSeen = ref.watch(lastSeenShareProvider);
  final shares = ref.watch(receivedLocationsProvider).valueOrNull ?? const [];
  return shares
      .where((s) => s.createdAt.millisecondsSinceEpoch > lastSeen)
      .length;
});
