import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/aurora.dart';
import '../../core/localization/app_localizations.dart';
import '../auth/services/account_deletion_service.dart';
import '../auth/services/auth_service.dart';
import '../auth/services/avatar_service.dart';
import '../friends/providers/friend_uids_provider.dart';
import '../map_gallery/providers/map_media_provider.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/aurora_button.dart';
import '../../shared/widgets/aurora_dialog.dart';

/// Account actions shared by the Settings tab and the Personal Information
/// screen: both need to change the avatar, rename the account and delete it.

Future<void> changeAvatar(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final uid = ref.read(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return;

  final result = await ref.read(avatarServiceProvider).pickAndUpload(uid);
  switch (result) {
    case AvatarUploadResult.success:
      ref.invalidate(currentUserProvider);
      messenger.showSuccessSnack(t.avatarUpdated);
    case AvatarUploadResult.failed:
      messenger.showErrorSnack(t.avatarUpdateFailed);
    case AvatarUploadResult.cancelled:
      break;
  }
}

/// One confirmation card (type DELETE), then a blocking progress dialog:
/// deleting an account cannot be undone, and backing out halfway would leave
/// it half-deleted.
Future<void> handleDeleteAccount(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  final media = ref.read(mapMediaProvider).where((m) => m.isMine);
  final photos = media.where((m) => !m.isVideo).length;
  final videos = media.where((m) => m.isVideo).length;
  final friends = ref.read(friendUidsProvider).length;

  final confirmed = await showAuroraDialog<bool>(
    context,
    builder: (ctx) => _DeleteConfirmCard(
      t: t,
      photos: photos,
      videos: videos,
      friends: friends,
    ),
  );
  if (confirmed != true || !context.mounted) return;

  showAuroraDialog<void>(
    context,
    barrierDismissible: false,
    builder: (ctx) => _DeleteProgressCard(label: t.deletingAccount),
  );

  final result = await ref.read(accountDeletionServiceProvider).deleteAccount();

  router.pop(); // close the progress dialog

  switch (result) {
    case AccountDeletionResult.success:
      messenger.showSuccessSnack(t.accountDeleted);
      router.go('/auth');
    case AccountDeletionResult.needsReauth:
      messenger.showErrorSnack(t.deleteAccountReauthNeeded);
    case AccountDeletionResult.failed:
      messenger.showErrorSnack(t.errorGeneral);
  }
}

const _deleteRed = Color(0xFFFF4757);

class _DeleteConfirmCard extends StatefulWidget {
  const _DeleteConfirmCard({
    required this.t,
    required this.photos,
    required this.videos,
    required this.friends,
  });

  final AppLocalizations t;
  final int photos;
  final int videos;
  final int friends;

  @override
  State<_DeleteConfirmCard> createState() => _DeleteConfirmCardState();
}

class _DeleteConfirmCardState extends State<_DeleteConfirmCard> {
  final _controller = TextEditingController();

  bool get _matches => _controller.text.trim().toUpperCase() == 'DELETE';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _lossRow(IconData icon, Color tint, Color bg, String text) => Row(
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: tint),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Aurora.text(13, weight: FontWeight.w600),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final matches = _matches;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0x66FFDAD6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_rounded,
            size: 34,
            color: Color(0xFFBA1A1A),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t.deleteAccount,
          textAlign: TextAlign.center,
          style: Aurora.text(20, weight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          t.deleteAccountWarning,
          textAlign: TextAlign.center,
          style: Aurora.text(13, color: Aurora.subText, height: 1.4),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _lossRow(
                Icons.photo_library_rounded,
                Aurora.primary,
                const Color(0xFFE6DEFF),
                '${widget.photos} ${t.filterPhotos}',
              ),
              const SizedBox(height: 8),
              _lossRow(
                Icons.videocam_rounded,
                Aurora.secondary,
                const Color(0xFFFFD9E0),
                '${widget.videos} ${t.filterVideos}',
              ),
              const SizedBox(height: 8),
              _lossRow(
                Icons.group_rounded,
                const Color(0xFF005763),
                const Color(0xFFA2EEFF),
                '${widget.friends} ${t.friends}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            t.deleteAccountTypeDelete,
            style: Aurora.text(12, weight: FontWeight.w700, color: Aurora.subText),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          style: Aurora.text(
            14,
            weight: FontWeight.w800,
            color: _deleteRed,
          ).copyWith(letterSpacing: 1.6),
          decoration: InputDecoration(
            hintText: t.deleteAccountConfirmHint,
            hintStyle: Aurora.text(14, color: Aurora.hint),
            filled: true,
            fillColor: const Color(0xFFF1EBFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            suffixIcon: matches
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircleAvatar(
                      backgroundColor: _deleteRed,
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _deleteRed, width: 2),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EBFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t.cancel,
                    style: Aurora.text(13, weight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: matches ? 1 : 0.4,
                child: GestureDetector(
                  onTap: matches ? () => Navigator.pop(context, true) : null,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _deleteRed,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: matches
                          ? [
                              BoxShadow(
                                color: _deleteRed.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete_forever_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            t.deleteAccount,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(
                              13,
                              weight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Non-dismissible progress card. The service reports no real percentage, so
/// the bar is indeterminate rather than showing a made-up number.
class _DeleteProgressCard extends StatelessWidget {
  const _DeleteProgressCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: Aurora.secondary,
                  backgroundColor: Color(0x267C3AED),
                ),
              ),
              const Icon(
                Icons.cloud_sync_rounded,
                size: 22,
                color: Color(0xFFFE4C8C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Aurora.text(18, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            minHeight: 8,
            color: Aurora.primary,
            backgroundColor: Color(0xFFF1EBFF),
          ),
        ),
      ],
    );
  }
}

Widget _dialogTitle(String title, {VoidCallback? onClose}) => Row(
  children: [
    Expanded(
      child: Text(title, style: Aurora.text(20, weight: FontWeight.w800)),
    ),
    if (onClose != null)
      GestureDetector(
        onTap: onClose,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF1EBFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: Color(0xFF4A4455),
          ),
        ),
      ),
  ],
);

Future<void> showEditUsernameDialog(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final currentUsername =
      ref.read(currentUserProvider).valueOrNull?.username ?? '';
  final controller = TextEditingController(text: currentUsername);
  bool isSaving = false;
  String? errorMessage;

  await showAuroraDialog<void>(
    context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> save() async {
          final newUsername = controller.text.trim();
          if (newUsername.length < 3) {
            setState(() => errorMessage = t.usernameInvalid);
            return;
          }
          setState(() {
            isSaving = true;
            errorMessage = null;
          });
          if (newUsername == currentUsername) {
            Navigator.pop(dialogContext);
            return;
          }
          try {
            final authService = ref.read(authServiceProvider);
            final exists = await authService.checkUsernameExists(newUsername);
            if (exists) {
              setState(() {
                errorMessage = t.usernameTaken;
                isSaving = false;
              });
              return;
            }
            final user = authService.currentUser;
            if (user != null) {
              await authService.updateUsername(user.uid, newUsername);
              ref.invalidate(currentUserProvider);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSuccessSnack(t.usernameUpdated);
              }
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showErrorSnack(t.errorGeneral);
            }
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogTitle(
              t.editUsername,
              onClose: isSaving ? null : () => Navigator.pop(dialogContext),
            ),
            const SizedBox(height: 16),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F1FF),
                borderRadius: BorderRadius.circular(16),
                border: errorMessage == null
                    ? null
                    : Border.all(color: const Color(0xFFFF4757), width: 1.5),
              ),
              child: Row(
                children: [
                  Text(
                    '@',
                    style: Aurora.text(
                      17,
                      weight: FontWeight.w800,
                      color: Aurora.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: Aurora.text(15, weight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: t.newUsername,
                        hintStyle: Aurora.text(15, color: Aurora.hint),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() => errorMessage = null),
                    ),
                  ),
                ],
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: Color(0xFFFF4757),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: Aurora.text(
                        12.5,
                        weight: FontWeight.w600,
                        color: const Color(0xFFFF4757),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isSaving ? null : () => Navigator.pop(dialogContext),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE4FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.cancel,
                        style: Aurora.text(13, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AuroraButton(
                    label: t.save,
                    height: 48,
                    isLoading: isSaving,
                    onTap: isSaving ? null : save,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
