import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/aurora.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/aurora_blob.dart';
import '../../shared/widgets/aurora_button.dart';
import '../auth/services/auth_service.dart';
import 'models/friend_model.dart';
import 'providers/friend_profiles_provider.dart';
import 'providers/latest_share_provider.dart';
import 'services/friend_service.dart';
import 'widgets/friend_tile.dart';
import '../../shared/widgets/aurora_motion_widgets.dart';
import 'widgets/received_locations_section.dart';
import 'add_friend_screen.dart';

/// The Friend tab — accepted friends only. Incoming requests are handled on
/// the Add Friend screen and in the notification inbox.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final myUid = ref.watch(authStateProvider).value?.uid;
    final friendsAsync = ref.watch(friendsStreamProvider);
    final profiles = ref.watch(friendProfilesProvider).valueOrNull ?? const {};
    final latestShares = ref.watch(latestShareByFriendProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 120, size: 300, color: Aurora.aqua),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(context, t),
                Expanded(
                  child: friendsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Aurora.primary),
                    ),
                    error: (_, _) => Center(
                      child: Text(
                        t.errorGeneral,
                        style: Aurora.text(14, color: Aurora.subText),
                      ),
                    ),
                    data: (friends) {
                      final accepted = myUid == null
                          ? const <FriendModel>[]
                          : friends
                                .where((f) => f.status == FriendStatus.accepted)
                                .toList();
                      if (accepted.isEmpty) return _emptyState(context, t);

                      final rawQ = _query.trim().toLowerCase();
                      final q = rawQ.startsWith('@') ? rawQ.substring(1) : rawQ;
                      debugPrint('🔍 [FriendsSearch] query="$q" accepted=${accepted.length} profiles=${profiles.length}');
                      final rows = <Widget>[];
                      var shown = 0;
                      for (final friend in accepted) {
                        final otherUid = friend.senderId == myUid
                            ? friend.receiverId
                            : friend.senderId;
                        final profile = profiles[otherUid];
                        // Skip while profile is still loading from Firestore.
                        if (profile == null) {
                          debugPrint('🔍 [FriendsSearch] profile null for uid=$otherUid');
                          continue;
                        }
                        debugPrint('🔍 [FriendsSearch] checking uid=$otherUid username="${profile.username}" displayName="${profile.displayName}"');
                        if (q.isNotEmpty &&
                            !profile.username.toLowerCase().contains(q) &&
                            !profile.displayName.toLowerCase().contains(q) &&
                            !profile.email.toLowerCase().contains(q) &&
                            // Also try matching the raw query against username in case they didn't start with @ but included it
                            !profile.username.toLowerCase().contains(rawQ)) {
                          continue;
                        }
                        rows.add(
                          FadeSlideIn.indexed(
                            key: ValueKey(friend.id),
                            index: shown++,
                            child: FriendTile(
                              friendDocId: friend.id,
                              profile: profile,
                              latestShare: latestShares[otherUid],
                            ),
                          ),
                        );
                      }

                      // Search returned nothing → show a hint
                      if (q.isNotEmpty && rows.isEmpty) {
                        rows.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Aurora.primary.withValues(alpha: 0.08),
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    size: 34,
                                    color: Aurora.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No friends match "$q"',
                                  style: Aurora.text(
                                    15,
                                    weight: FontWeight.w600,
                                    color: Aurora.darkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try a different name or username',
                                  style: Aurora.text(13, color: Aurora.subText),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: Aurora.primary,
                        onRefresh: () async {
                          debugPrint(
                            '🔄 [FriendsScreen] Pull-to-refresh triggered.',
                          );
                          try {
                            ref.invalidate(friendsStreamProvider);
                            ref.invalidate(friendProfilesProvider);
                            ref.invalidate(latestShareByFriendProvider);
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            final newFriends =
                                ref.read(friendsStreamProvider).valueOrNull ??
                                [];
                            debugPrint(
                              '✅ [FriendsScreen] Refreshed successfully. Found ${newFriends.length} friends.',
                            );
                          } catch (e, st) {
                            debugPrint(
                              '❌ [FriendsScreen] Error refreshing data: $e\n$st',
                            );
                          }
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: kAppBottomNavHeight,
                          ),
                          children: [
                            const ReceivedLocationsSection(),
                            ...rows,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    t.friends,
                    style: Aurora.text(24, weight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Aurora.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: t.friendsAdd,
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.addFriend),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Aurora.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Aurora.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: -2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => UserSearchDialog(username: v.trim()),
                  );
                }
              },
              onChanged: (v) => setState(() => _query = v),
              style: Aurora.text(14),
              decoration: InputDecoration(
                hintText: t.friendsSearchHint,
                hintStyle: Aurora.text(
                  14,
                  color: const Color(0xFF7B7487).withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7B7487),
                  size: 20,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: const Color(0xFF7B7487),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations t) {
    Widget bubble(Color c, IconData icon, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: Aurora.cardShadow,
      ),
      child: Icon(icon, size: size * 0.55, color: Colors.white),
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, kAppBottomNavHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 6,
                    top: 20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: bubble(
                        const Color(0xFF2FD9F4),
                        Icons.person_rounded,
                        54,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 14,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: bubble(
                        Aurora.sunnyEnd,
                        Icons.person_rounded,
                        50,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Aurora.primaryGradient,
                      boxShadow: Aurora.glow,
                    ),
                    child: const Icon(
                      Icons.group_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 40,
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 30,
                      color: Aurora.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.friendsEmpty,
              textAlign: TextAlign.center,
              style: Aurora.text(15, color: Aurora.subText, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: AuroraButton(
                label: t.friendsAdd,
                height: 52,
                trailingIcon: Icons.group_add_rounded,
                onTap: () => context.push(AppRoutes.addFriend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
