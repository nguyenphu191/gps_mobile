import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../auth/models/user_model.dart';
import '../auth/services/auth_service.dart';
import 'providers/friend_profiles_provider.dart';

class FriendMapScreen extends ConsumerStatefulWidget {
  /// When opened from a received location, centre on that point.
  final double? focusLatitude;
  final double? focusLongitude;

  const FriendMapScreen({super.key, this.focusLatitude, this.focusLongitude});

  @override
  ConsumerState<FriendMapScreen> createState() => _FriendMapScreenState();
}

class _FriendMapScreenState extends ConsumerState<FriendMapScreen> {
  final MapController _mapController = MapController();
  bool _focusApplied = false;

  LatLng? get _focusPoint =>
      widget.focusLatitude != null && widget.focusLongitude != null
      ? LatLng(widget.focusLatitude!, widget.focusLongitude!)
      : null;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final friendProfiles =
        ref.watch(friendProfilesProvider).valueOrNull ??
        const <String, UserModel>{};
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.friendsSeeOnMap),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const AppErrorView(),
        data: (currentUser) {
          if (currentUser == null)
            return const Center(child: Text('Not logged in'));

          // Live profiles: a one-shot get() here meant friends' positions and
          // avatars froze until the screen was rebuilt.
          final friendUsers = friendProfiles.values.toList();

          // Move to the requested share once the map is up.
          final focus = _focusPoint;
          if (focus != null && !_focusApplied) {
            _focusApplied = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(focus, 16);
            });
          }

          final initialCenter =
              focus ??
              (currentUser.lastLatitude != null &&
                      currentUser.lastLongitude != null
                  ? LatLng(
                      currentUser.lastLatitude!,
                      currentUser.lastLongitude!,
                    )
                  : (friendUsers.isNotEmpty &&
                            friendUsers.first.lastLatitude != null
                        ? LatLng(
                            friendUsers.first.lastLatitude!,
                            friendUsers.first.lastLongitude!,
                          )
                        : const LatLng(0, 0)));

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    subdomains: const ['0', '1', '2', '3'],
                    userAgentPackageName: 'com.gpscamerastamp.app',
                    errorTileCallback: (tile, error, stackTrace) {},
                  ),
                  MarkerLayer(
                    markers: [
                      // Current user marker
                      if (currentUser.lastLatitude != null &&
                          currentUser.lastLongitude != null)
                        Marker(
                          point: LatLng(
                            currentUser.lastLatitude!,
                            currentUser.lastLongitude!,
                          ),
                          width: 60,
                          height: 60,
                          child: _UserMarker(user: currentUser, isSelf: true),
                        ),
                      // The shared location this screen was opened for.
                      if (focus != null)
                        Marker(
                          point: focus,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFF97316),
                            size: 44,
                          ),
                        ),
                      // Friends markers
                      for (final f in friendUsers)
                        if (f.lastLatitude != null &&
                            f.lastLongitude != null &&
                            f.isLocationShared)
                          Marker(
                            point: LatLng(f.lastLatitude!, f.lastLongitude!),
                            width: 60,
                            height: 60,
                            child: _UserMarker(user: f),
                          ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF2563EB),
                  ),
                  onPressed: () {
                    if (currentUser.lastLatitude != null &&
                        currentUser.lastLongitude != null) {
                      _mapController.move(
                        LatLng(
                          currentUser.lastLatitude!,
                          currentUser.lastLongitude!,
                        ),
                        15,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  final UserModel user;
  final bool isSelf;

  const _UserMarker({required this.user, this.isSelf = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(
                  photoUrl: user.photoUrl,
                  name: user.username.isNotEmpty
                      ? user.username
                      : user.displayName,
                  radius: 30,
                ),
                const SizedBox(height: 12),
                Text(
                  isSelf ? 'You (${user.displayName})' : user.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (user.lastSeen != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last seen: ${DateFormat('MMM dd, HH:mm').format(user.lastSeen!)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelf ? Colors.blue : Colors.green,
              shape: BoxShape.circle,
            ),
            child: UserAvatar(
              photoUrl: user.photoUrl,
              name: user.username.isNotEmpty ? user.username : user.displayName,
              radius: 18,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.displayName.split(' ').first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
