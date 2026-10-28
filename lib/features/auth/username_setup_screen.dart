import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/aurora.dart';
import '../../../shared/widgets/aurora_blob.dart';
import '../../../shared/widgets/aurora_button.dart';
import 'services/auth_service.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  final String nextRoute;
  const UsernameSetupScreen({super.key, this.nextRoute = '/home'});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _isLoading = false;
  String? _errorText;
  static const _valid = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    final username = _controller.text.trim();
    final t = AppLocalizations.of(context);

    if (username.length < 3) {
      setState(() => _errorText = t.usernameInvalid);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final exists = await authService.checkUsernameExists(username);

      if (exists) {
        if (mounted) {
          setState(() {
            _errorText = t.usernameTaken;
            _isLoading = false;
          });
        }
        return;
      }

      final user = authService.currentUser;
      if (user != null) {
        await authService.updateUsername(user.uid, username);
        if (mounted) {
          // Invalidate user provider to refresh data
          ref.invalidate(currentUserProvider);
          context.go(widget.nextRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final len = _controller.text.length;
    final focused = _focus.hasFocus;
    final photoUrl = ref.read(authServiceProvider).currentUser?.photoURL;

    return PopScope(
      canPop: false, // Setup is mandatory: no leaving without a username.
      child: Scaffold(
        backgroundColor: Aurora.bgSoft,
        body: Stack(
          children: [
            const AuroraBlob(top: -64, left: -80, size: 320, color: Aurora.primary),
            const AuroraBlob(top: 200, right: -96, size: 280, color: Aurora.secondary),
            const AuroraBlob(bottom: -48, left: 96, size: 260, color: Aurora.aqua),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Column(
                  children: [
                    _AvatarHero(photoUrl: photoUrl),
                    const SizedBox(height: 20),
                    Text(
                      t.usernameSetup,
                      textAlign: TextAlign.center,
                      style: Aurora.text(24, weight: FontWeight.w800, height: 1.25),
                    ),
                    const SizedBox(height: 28),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Aurora.primary.withValues(
                              alpha: focused ? 0.18 : 0.08,
                            ),
                            blurRadius: focused ? 28 : 24,
                            offset: Offset(0, focused ? 12 : 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECE4FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '@',
                              style: Aurora.text(
                                18,
                                weight: FontWeight.w700,
                                color: Aurora.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              maxLength: 20,
                              autocorrect: false,
                              enableSuggestions: false,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9_]'),
                                ),
                                TextInputFormatter.withFunction(
                                  (old, next) => next.copyWith(
                                    text: next.text.toLowerCase(),
                                  ),
                                ),
                              ],
                              style: Aurora.text(18, weight: FontWeight.w700),
                              decoration: InputDecoration(
                                hintText: t.usernameHint,
                                hintStyle: Aurora.text(
                                  16,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFFCCC3D8),
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (_) => setState(() => _errorText = null),
                              onSubmitted: (_) {
                                if (!_isLoading) _saveUsername();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, left: 4),
                            child: Text(
                              '$len/20',
                              style: Aurora.text(
                                12,
                                weight: FontWeight.w600,
                                color: const Color(0xFF7B7487),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _Status(
                        errorText: _errorText,
                        showValid: len >= 3 && _errorText == null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuroraButton(
                      label: t.usernameSave,
                      trailingIcon: Icons.arrow_forward_rounded,
                      isLoading: _isLoading,
                      enabled: len >= 3,
                      onTap: _saveUsername,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String? errorText;
  final bool showValid;

  const _Status({required this.errorText, required this.showValid});

  @override
  Widget build(BuildContext context) {
    if (errorText != null) {
      return Row(
        children: [
          const SizedBox(width: 4),
          _dot(const Color(0xFFFFDAD6), Icons.close_rounded, const Color(0xFFBA1A1A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorText!,
              style: Aurora.text(
                13,
                weight: FontWeight.w700,
                color: const Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      height: 20,
      child: showValid
          ? Row(
              children: [
                const SizedBox(width: 4),
                _dot(
                  _UsernameSetupScreenState._valid.withValues(alpha: 0.15),
                  Icons.check_rounded,
                  _UsernameSetupScreenState._valid,
                ),
              ],
            )
          : null,
    );
  }

  Widget _dot(Color bg, IconData icon, Color fg) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: Icon(icon, size: 14, color: fg),
  );
}

class _AvatarHero extends StatefulWidget {
  final String? photoUrl;
  const _AvatarHero({this.photoUrl});

  @override
  State<_AvatarHero> createState() => _AvatarHeroState();
}

class _AvatarHeroState extends State<_AvatarHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFF3EBFF),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 52, color: Aurora.primary),
    );
    return SizedBox(
      width: 160,
      height: 110,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            child!,
            Positioned(
              top: -4 + _c.value * 6,
              left: 6,
              child: const Text('✨', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              top: 8 + (1 - _c.value) * 5,
              right: 10,
              child: const Text('⭐', style: TextStyle(fontSize: 16)),
            ),
            const Positioned(
              bottom: 2,
              left: 34,
              child: Text('✦', style: TextStyle(fontSize: 12, color: Aurora.secondary)),
            ),
          ],
        ),
        child: Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Aurora.primary, Aurora.secondary, Aurora.sunny],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
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
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: widget.photoUrl == null
                  ? placeholder
                  : Image.network(
                      widget.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => placeholder,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
