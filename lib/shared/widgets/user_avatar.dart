import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular profile picture with a coloured initial as the fallback, so users
/// without a photo are still told apart at a glance.
class UserAvatar extends StatelessWidget {
  static const Color fallbackColor = Color(0xFF0EA5E9);

  final String? photoUrl;

  /// Username preferably; pass the display name when there is no username.
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
  });

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim() ?? '';
    final size = radius * 2;

    final Widget avatar = url.isEmpty
        ? _initialAvatar()
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => _initialAvatar(),
              errorWidget: (_, _, _) => _initialAvatar(),
            ),
          );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }

  Widget _initialAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: fallbackColor,
      child: Text(
        _initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
