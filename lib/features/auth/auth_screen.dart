import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurora.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/aurora_blob.dart';
import '../../../shared/widgets/aurora_button.dart';
import 'services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String nextRoute;
  const AuthScreen({super.key, this.nextRoute = '/home'});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
      context.showErrorSnack('Vui lòng điền đầy đủ thông tin.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await ref
            .read(authServiceProvider)
            .signInWithEmailAndPassword(email, password);
      } else {
        await ref
            .read(authServiceProvider)
            .registerWithEmailAndPassword(email, password, username);
      }

      if (mounted) {
        if (!_isLogin) {
          context.showSuccessSnack('Đăng ký tài khoản thành công!');
        }
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          final userData = await ref
              .read(authServiceProvider)
              .getUserData(user.uid);
          if (mounted) {
            if (userData != null && userData.username.isEmpty) {
              context.go('/username-setup?next=${widget.nextRoute}');
            } else {
              context.go(widget.nextRoute);
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMsg;
        if (e.code == 'email-already-in-use') {
          errorMsg = 'Email này đã được dùng để đăng ký tài khoản khác.';
        } else if (e.code == 'weak-password') {
          errorMsg = 'Mật khẩu quá yếu, hãy dùng ít nhất 6 ký tự.';
        } else if (e.code == 'invalid-email') {
          errorMsg = 'Địa chỉ email không hợp lệ.';
        } else if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMsg = 'Email hoặc mật khẩu không đúng.';
        } else {
          errorMsg = 'Có lỗi xảy ra, vui lòng thử lại.';
        }
        context.showErrorSnack(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        String errorStr = e.toString();
        if (errorStr.contains('Username already taken')) {
          context.showErrorSnack('Tên người dùng này đã có người sử dụng rồi.');
        } else {
          context.showErrorSnack('Có lỗi xảy ra, vui lòng thử lại.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignIn(Future<void> Function() signInMethod) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await signInMethod();
      if (mounted) {
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          final userData = await ref
              .read(authServiceProvider)
              .getUserData(user.uid);
          if (mounted) {
            if (userData != null && userData.username.isEmpty) {
              context.go('/username-setup?next=${widget.nextRoute}');
            } else {
              context.go(widget.nextRoute);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnack('Có lỗi xảy ra, vui lòng thử lại.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setMode(bool login) {
    if (_isLoading || login == _isLogin) return;
    setState(() => _isLogin = login);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final googleTap = _isLoading
        ? null
        : () => _handleSignIn(ref.read(authServiceProvider).signInWithGoogle);
    final appleTap = _isLoading
        ? null
        : () => _handleSignIn(ref.read(authServiceProvider).signInWithApple);

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -48, right: -48, size: 256, color: Aurora.secondary),
          const AuroraBlob(top: 112, left: -64, size: 224, color: Aurora.primary),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                _Canopy(
                  topPad: topPad,
                  title: _isLogin ? t.signIn : t.register,
                  subtitle: _isLogin ? t.signInSubtitle : t.registerSubtitle,
                  showBack: context.canPop(),
                  onBack: () => context.pop(),
                ),
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Aurora.primary.withValues(alpha: 0.18),
                            blurRadius: 48,
                            spreadRadius: -10,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModeSwitch(
                            isLogin: _isLogin,
                            signInLabel: t.signIn,
                            registerLabel: t.register,
                            onChanged: _setMode,
                          ),
                          const SizedBox(height: 20),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            alignment: Alignment.topCenter,
                            child: _isLogin
                                ? const SizedBox(width: double.infinity)
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _AuthField(
                                      controller: _usernameController,
                                      label: t.username,
                                      hint: t.username,
                                      icon: Icons.badge_outlined,
                                    ),
                                  ),
                          ),
                          _AuthField(
                            controller: _emailController,
                            label: t.email,
                            hint: t.email,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _passwordController,
                            label: t.password,
                            hint: t.password,
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            onToggleObscure: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                          const SizedBox(height: 24),
                          AuroraButton(
                            label: _isLogin ? t.signIn : t.register,
                            trailingIcon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onTap: _handleEmailAuth,
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => _setMode(!_isLogin),
                            child: Text(
                              _isLogin
                                  ? t.needAccountRegister
                                  : t.haveAccountSignIn,
                              style: Aurora.text(
                                14,
                                weight: FontWeight.w700,
                                color: Aurora.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFFE6DEFF)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  t.orContinueWith,
                                  style: Aurora.text(12, color: Aurora.hint),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFFE6DEFF)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  iconAsset: 'assets/auth/google.png',
                                  label: 'Google',
                                  onTap: googleTap,
                                ),
                              ),
                              if (Platform.isIOS) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SocialButton(
                                    iconAsset: 'assets/auth/apple.png',
                                    label: 'Apple',
                                    iconTint: Aurora.darkText,
                                    onTap: appleTap,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _Canopy extends StatelessWidget {
  final double topPad;
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback onBack;

  const _Canopy({
    required this.topPad,
    required this.title,
    required this.subtitle,
    required this.showBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 60),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF630ED4), Aurora.primary, Color(0xFFFE4C8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(44)),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.32),
            blurRadius: 36,
            spreadRadius: -6,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBack)
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: Aurora.primary.withValues(alpha: 0.3),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Aurora.primary,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 44, height: 44),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Icon(Icons.location_on_rounded, size: 16, color: Aurora.sunny),
                    SizedBox(width: 4),
                    Icon(Icons.explore_rounded, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Aurora.text(28, weight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: Aurora.text(
                    14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.flight_takeoff_rounded, size: 18, color: Aurora.sunny),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool isLogin;
  final String signInLabel;
  final String registerLabel;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({
    required this.isLogin,
    required this.signInLabel,
    required this.registerLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool login) => Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(login),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Aurora.text(
              13,
              weight: FontWeight.w700,
              color: isLogin == login ? Aurora.primary : const Color(0xFF4A4455),
            ),
            child: Text(label),
          ),
        ),
      ),
    );

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EBFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Aurora.primary.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(children: [tab(signInLabel, true), tab(registerLabel, false)]),
        ],
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            widget.label,
            style: Aurora.text(
              12,
              weight: FontWeight.w700,
              color: const Color(0xFF4A4455),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: focused ? Colors.white : const Color(0xFFF7F1FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused ? Aurora.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: Aurora.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 20, color: Aurora.primary),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  style: Aurora.text(14),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: Aurora.text(
                      14,
                      color: const Color(0xFF4A4455).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.onToggleObscure != null)
                GestureDetector(
                  onTap: widget.onToggleObscure,
                  child: Icon(
                    widget.obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: const Color(0xFF4A4455).withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color? iconTint;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.iconTint,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFEDE9FE)),
            boxShadow: [
              BoxShadow(
                color: Aurora.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconAsset, width: 20, height: 20, color: iconTint),
              const SizedBox(width: 8),
              Text(label, style: Aurora.text(14, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
