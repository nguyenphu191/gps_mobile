import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/aurora.dart';
import '../../shared/widgets/aurora_blob.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/models/user_model.dart';
import '../auth/services/auth_service.dart';
import 'models/friend_model.dart';
import 'services/friend_service.dart';
import '../notifications/services/notification_service.dart';

/// Profile of a user who is not a friend yet, so `friendProfilesProvider`
/// (accepted friends only) cannot supply it.
final _userProfileProvider = FutureProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  return ref.read(authServiceProvider).getUserData(uid);
});

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final username = _controller.text.trim();
    debugPrint('🔍 [AddFriendScreen] _search triggered with username: "$username"');
    if (username.isEmpty) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UserSearchDialog(username: username),
    );
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() => _controller.text = text.startsWith('@') ? text.substring(1) : text);
    await _search();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final myUid = ref.watch(authStateProvider).value?.uid;
    final incoming =
        (ref.watch(friendsStreamProvider).valueOrNull ?? const <FriendModel>[])
            .where(
              (f) => f.status == FriendStatus.pending && f.receiverId == myUid,
            )
            .toList();

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 220, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -48, left: 60, size: 280, color: Aurora.aqua),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: Aurora.cardShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Aurora.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          t.friendsAdd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(22, weight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _searchField(t),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (incoming.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.friendsRequestReceived,
                                  style: Aurora.text(18, weight: FontWeight.w800),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Aurora.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final request in incoming)
                          _RequestRow(request: request),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: Aurora.primaryGradient,
            ),
            child: const Icon(Icons.search_rounded, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              onChanged: (_) => setState(() {}),
              style: Aurora.text(15),
              decoration: InputDecoration(
                hintText: t.friendsSearchHint,
                hintStyle: Aurora.text(15, color: Aurora.hint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() {
                _controller.clear();
              }),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFECE4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF4A4455),
                ),
              ),
            ),
          GestureDetector(
            onTap: _paste,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F1FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.content_paste_rounded,
                size: 18,
                color: Aurora.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }



}

/// Gradient (primary) or soft red (danger) pill used for row actions.
class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  final bool danger;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = danger ? const Color(0xFF93000A) : Colors.white;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: danger ? null : Aurora.primaryGradient,
          color: danger ? const Color(0xFFFFDAD6) : null,
          borderRadius: BorderRadius.circular(999),
          boxShadow: danger
              ? null
              : [
                  BoxShadow(
                    color: Aurora.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: Aurora.text(13, weight: FontWeight.w700, color: fg),
                  ),
                ],
              ),
      ),
    );
  }
}

/// One incoming friend request, with the actions the old friends list was
/// missing: a busy state and a snackbar telling you what happened.
class _RequestRow extends ConsumerStatefulWidget {
  final FriendModel request;

  const _RequestRow({required this.request});

  @override
  ConsumerState<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends ConsumerState<_RequestRow> {
  bool _busy = false;

  Future<void> _respond({required bool accept}) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(friendServiceProvider);
    // Read before the awaits: accepting flips the friendship status, the
    // request drops out of the list, and this row is disposed before they
    // return — touching `ref` afterwards throws.
    final notifService = ref.read(notificationServiceProvider);
    if (service == null || _busy) return;

    setState(() => _busy = true);
    try {
      if (accept) {
        await service.acceptFriendRequest(widget.request.id);
        messenger.showSuccessSnack(t.friendsAccept);
      } else {
        await service.declineFriendRequest(widget.request.id);
        messenger.showSuccessSnack(t.friendsRemoved);
      }

      await notifService?.deleteByFriendDocId(widget.request.id);
    } catch (e) {
      debugPrint('🔥 [AddFriend] respond failed: $e');
      messenger.showErrorSnack(t.errorGeneral);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profileAsync = ref.watch(
      _userProfileProvider(widget.request.senderId),
    );
    final profile = profileAsync.valueOrNull;
    if (profile == null) return const SizedBox.shrink();

    return _PersonCard(
      profile: profile,
      badge: Icons.mail_rounded,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionPill(
            label: t.friendsDecline,
            icon: Icons.close_rounded,
            danger: true,
            onTap: _busy ? null : () => _respond(accept: false),
          ),
          const SizedBox(width: 6),
          _ActionPill(
            label: t.friendsAccept,
            icon: Icons.check_rounded,
            loading: _busy,
            onTap: _busy ? null : () => _respond(accept: true),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final UserModel profile;
  final Widget trailing;
  final IconData? badge;

  const _PersonCard({
    required this.profile,
    required this.trailing,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.username;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.09),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (badge != null)
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9E0).withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Column(
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Aurora.primary,
                              Aurora.secondary,
                              Aurora.aqua,
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: UserAvatar(
                            photoUrl: profile.photoUrl,
                            name: profile.username.isNotEmpty
                                ? profile.username
                                : profile.displayName,
                            radius: 25,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Aurora.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(badge, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(16, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${profile.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(
                            12,
                            weight: FontWeight.w800,
                            color: Aurora.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
            ],
          ),
        ],
      ),
    );
  }
}


class UserSearchDialog extends ConsumerStatefulWidget {
  final String username;
  const UserSearchDialog({required this.username});

  @override
  ConsumerState<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends ConsumerState<UserSearchDialog> {
  bool _isLoading = true;
  List<UserModel> _results = [];
  String? _addingUid;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      final service = ref.read(friendServiceProvider);
      if (service != null) {
        final results = await service.searchUsers(widget.username);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('🔥 [SearchDialog] failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addFriend(UserModel user) async {
    if (_addingUid != null) return;
    setState(() => _addingUid = user.uid);
    try {
      final service = ref.read(friendServiceProvider);
      await service?.sendFriendRequest(user.uid);
      if (mounted) {
        context.showSuccessSnack(
          AppLocalizations.of(context).friendsRequestSent,
        );
        Navigator.of(context).pop(); // close dialog
      }
    } catch (e) {
      debugPrint('🔥 [AddFriend] request failed: $e');
      if (mounted) {
        context.showErrorSnack(AppLocalizations.of(context).errorGeneral);
      }
    } finally {
      if (mounted) setState(() => _addingUid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    
    return Dialog(
      backgroundColor: Aurora.bgSoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search Results',
              style: Aurora.text(18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: Aurora.primary)),
              )
            else if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F1FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 32,
                        color: Aurora.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.friendsNotFound,
                      textAlign: TextAlign.center,
                      style: Aurora.text(16, weight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return _PersonCard(
                      profile: user,
                      trailing: _ActionPill(
                        label: t.friendsAdd,
                        icon: Icons.person_add_rounded,
                        loading: _addingUid == user.uid,
                        onTap: () => _addFriend(user),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t.cancel,
                style: Aurora.text(15, weight: FontWeight.w700, color: Aurora.subText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
