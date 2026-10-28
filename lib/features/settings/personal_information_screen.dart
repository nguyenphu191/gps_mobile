import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/aurora.dart';
import '../../core/theme/aurora_motion.dart';
import '../../core/utils/time_ago.dart';
import '../../shared/widgets/aurora_blob.dart';
import '../../shared/widgets/aurora_motion_widgets.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/models/user_model.dart';
import '../auth/services/auth_service.dart';
import '../friends/providers/friend_profiles_provider.dart';
import '../friends/providers/friend_uids_provider.dart';
import '../map_gallery/providers/map_media_provider.dart';
import 'account_actions.dart';

/// A profile that has to be looked up because it is not (yet) in the streamed
/// friend profiles.
final _profileByUidProvider = FutureProvider.family<UserModel?, String>(
  (ref, uid) => ref.read(authServiceProvider).getUserData(uid),
);

/// Profile screen. With no [uid] (or my own uid) it is **my** profile: change
/// the photo, rename the account, delete it. With a friend's [uid] it is a
/// read-only view of that friend — no edit and no delete controls, and no
/// email address.
class PersonalInformationScreen extends ConsumerWidget {
  final String? uid;

  const PersonalInformationScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(authStateProvider).value?.uid;
    final isMine = uid == null || uid == myUid;

    UserModel? user;
    if (isMine) {
      user = ref.watch(currentUserProvider).valueOrNull;
    } else {
      user =
          (ref.watch(friendProfilesProvider).valueOrNull ?? const {})[uid] ??
          ref.watch(_profileByUidProvider(uid!)).valueOrNull;
    }

    final media = ref.watch(mapMediaProvider);
    final photos = media
        .where(
          (m) => !m.isVideo && (isMine ? m.isMine : m.ownerUid == uid),
        )
        .length;
    final videos = media
        .where((m) => m.isVideo && (isMine ? m.isMine : m.ownerUid == uid))
        .length;
    final friends = isMine ? ref.watch(friendUidsProvider).length : null;

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 100, right: -96, size: 300, color: Aurora.secondary),
          const AuroraBlob(top: 420, left: 60, size: 300, color: Aurora.aqua),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
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
                  ),
                ),
                Expanded(
                  child: user == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Aurora.primary,
                          ),
                        )
                      : _Body(
                          user: user,
                          isMine: isMine,
                          photos: photos,
                          videos: videos,
                          friends: friends,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final UserModel user;
  final bool isMine;
  final int photos;
  final int videos;
  final int? friends;

  const _Body({
    required this.user,
    required this.isMine,
    required this.photos,
    required this.videos,
    required this.friends,
  });

  bool get _online {
    final seen = user.lastSeen;
    if (seen == null) return false;
    return DateTime.now().difference(seen) < const Duration(minutes: 5);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final name = user.displayName.isNotEmpty ? user.displayName : user.username;
    final hasLocation =
        user.lastLatitude != null &&
        user.lastLongitude != null &&
        (isMine || user.isLocationShared);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          FadeSlideIn.indexed(
            index: 0,
            child: Column(
              children: [
                _AvatarHero(
                  user: user,
                  isMine: isMine,
                  online: _online,
                  onChange: () => changeAvatar(context, ref),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Aurora.text(22, weight: FontWeight.w800),
                ),
                if (user.username.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: Aurora.text(
                      14,
                      weight: FontWeight.w700,
                      color: Aurora.primary,
                    ),
                  ),
                ],
                if (!isMine && !_online && user.lastSeen != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(t, user.lastSeen!),
                    style: Aurora.text(12, color: Aurora.subText),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn.indexed(
            index: 1,
            child: _StatsCard(
              stats: [
                _Stat(
                  Icons.photo_library_rounded,
                  const Color(0xFFEADDFF),
                  Aurora.primary,
                  photos,
                  t.filterPhotos,
                ),
                _Stat(
                  Icons.videocam_rounded,
                  const Color(0xFFFFD9E0),
                  const Color(0xFFB90A5A),
                  videos,
                  t.filterVideos,
                ),
                if (friends != null)
                  _Stat(
                    Icons.group_rounded,
                    const Color(0xFFA2EEFF),
                    const Color(0xFF005763),
                    friends!,
                    t.friends,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (user.username.isNotEmpty || isMine)
            FadeSlideIn.indexed(
              index: 2,
              child: _InfoCard(
                children: [
                  if (user.username.isNotEmpty)
                    _InfoRow(
                      icon: Icons.alternate_email_rounded,
                      background: const Color(0xFFEADDFF),
                      color: Aurora.primary,
                      label: t.username,
                      value: '@${user.username}',
                      onEdit: isMine
                          ? () => showEditUsernameDialog(context, ref)
                          : null,
                    ),
                  if (isMine && user.email.isNotEmpty)
                    _InfoRow(
                      icon: Icons.mail_rounded,
                      background: const Color(0xFFFFD9E0),
                      color: const Color(0xFFB90A5A),
                      label: t.email,
                      value: user.email,
                    ),
                ],
              ),
            ),
          if (hasLocation) ...[
            const SizedBox(height: 16),
            FadeSlideIn.indexed(
              index: 3,
              child: _LocationCard(
                point: LatLng(user.lastLatitude!, user.lastLongitude!),
                onTap: () => isMine
                    ? context.push('/map-gallery')
                    : context.push(
                        '/friend-map?lat=${user.lastLatitude}&lng=${user.lastLongitude}',
                      ),
              ),
            ),
          ],
          if (isMine) ...[
            const SizedBox(height: 24),
            FadeSlideIn.indexed(
              index: 4,
              child: Pressable(
                onTap: () => handleDeleteAccount(context, ref),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_forever_rounded,
                        size: 20,
                        color: Color(0xFFBA1A1A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.deleteAccount,
                        style: Aurora.text(
                          14,
                          weight: FontWeight.w700,
                          color: const Color(0xFFBA1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar with a slowly rotating gradient ring.
class _AvatarHero extends StatefulWidget {
  final UserModel user;
  final bool isMine;
  final bool online;
  final VoidCallback onChange;

  const _AvatarHero({
    required this.user,
    required this.isMine,
    required this.online,
    required this.onChange,
  });

  @override
  State<_AvatarHero> createState() => _AvatarHeroState();
}

class _AvatarHeroState extends State<_AvatarHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (context, child) => Transform.rotate(
              angle: AuroraMotion.reduce(context)
                  ? 0
                  : _spin.value * 2 * math.pi,
              child: child,
            ),
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Aurora.primary,
                    Aurora.secondary,
                    Aurora.aqua,
                    Aurora.primary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Aurora.primary.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: -6,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 116,
            height: 116,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: UserAvatar(
              photoUrl: user.photoUrl,
              name: user.username.isNotEmpty ? user.username : user.displayName,
              radius: 55,
            ),
          ),
          if (widget.isMine)
            Positioned(
              right: 2,
              bottom: 2,
              child: Pressable(
                onTap: widget.onChange,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: Aurora.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Aurora.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (widget.online)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF2FD9F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final Color background;
  final Color color;
  final int value;
  final String label;

  const _Stat(this.icon, this.background, this.color, this.value, this.label);
}

class _StatsCard extends StatelessWidget {
  final List<_Stat> stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final s in stats)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s.icon, size: 18, color: s.color),
                  ),
                  const SizedBox(height: 4),
                  CountUp(
                    value: s.value,
                    style: Aurora.text(18, weight: FontWeight.w800),
                  ),
                  Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Aurora.text(12, color: Aurora.subText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _InfoRow({
    required this.icon,
    required this.background,
    required this.color,
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x99F7F1FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Aurora.text(12, color: Aurora.subText)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(15, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Pressable(
              onTap: onEdit,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEADDFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_rounded,
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

class _LocationCard extends StatelessWidget {
  final LatLng point;
  final VoidCallback onTap;

  const _LocationCard({required this.point, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: Aurora.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                      subdomains: const ['0', '1', '2', '3'],
                      userAgentPackageName: AppConstants.appPackage,
                      errorTileCallback: (tile, error, stackTrace) {},
                      tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Aurora.primary.withValues(alpha: 0.06),
                          BlendMode.srcATop,
                        ),
                        child: tileWidget,
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 40,
                          height: 40,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: Aurora.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Aurora.secondary.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Aurora.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${point.latitude.toStringAsFixed(4)}°, ${point.longitude.toStringAsFixed(4)}°',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: Aurora.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
