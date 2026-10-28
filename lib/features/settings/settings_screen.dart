import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/constants/app_constants.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/localization/language_options.dart';
import 'package:gpscamerastamp/core/router/app_router.dart';
import 'package:gpscamerastamp/core/services/push_notification_service.dart';
import 'package:gpscamerastamp/features/auth/models/user_model.dart';
import 'package:gpscamerastamp/features/auth/services/auth_service.dart';
import 'package:gpscamerastamp/shared/providers/language_provider.dart';
import 'package:gpscamerastamp/shared/widgets/app_bottom_nav.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_motion_widgets.dart';
import 'package:gpscamerastamp/shared/widgets/user_avatar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = AppConstants.appVersion; // fallback

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {
      // Ignore errors, keep fallback
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Stop pushes for this device before the uid goes away.
    await ref.read(pushNotificationServiceProvider).clearToken();
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) {
      context.go('/auth');
    }
  }

  Future<void> _openPrivacyPolicy() async {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.privacyPolicyClick);
    final uri = Uri.parse('https://dangduykhanh-studio.vercel.app/policy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp(BuildContext buttonContext) async {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.shareAppClick);
    final t = AppLocalizations.of(buttonContext);
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await Share.share(t.shareText, sharePositionOrigin: origin);
  }

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.settingsView);
    final t = AppLocalizations.of(context);
    // Watched once: four separate watches of the same provider used to make
    // the whole Account block blink in and out while it loaded.
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final languageCode = ref.watch(languageNotifierProvider).languageCode;

    return Scaffold(
      backgroundColor: Aurora.bgSoft,
      body: Stack(
        children: [
          const AuroraBlob(top: -96, left: -80, size: 320, color: Aurora.primary),
          const AuroraBlob(top: 260, right: -96, size: 340, color: Aurora.secondary),
          const AuroraBlob(bottom: -64, left: 120, size: 300, color: Aurora.aqua),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                kAppBottomNavHeight,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        t.settings,
                        style: Aurora.text(24, weight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Aurora.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Aurora.secondary.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                FadeSlideIn.indexed(
                  index: 0,
                  child: user != null
                      ? _AccountCard(
                          user: user,
                          onTap: () =>
                              context.push(AppRoutes.personalInformation),
                        )
                      : _SignedOutCard(isLoading: userAsync.isLoading),
                ),

                if (AppConstants.showPremium) ...[
                  const SizedBox(height: 16),
                  _UpgradeProCard(
                    title: t.upgradePro,
                    subtitle: t.upgradeProDesc,
                  ),
                ],

                const SizedBox(height: 28),
                _SectionLabel(t.general),
                const SizedBox(height: 10),
                FadeSlideIn.indexed(
                  index: 2,
                  child: _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: Icons.language_rounded,
                      gradient: const [Color(0xFF00A8B5), Color(0xFF2FD9F4)],
                      label: t.language,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EBFF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              languageDisplayName(languageCode),
                              style: Aurora.text(
                                12,
                                weight: FontWeight.w700,
                                color: Aurora.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _chevron,
                        ],
                      ),
                      onTap: () => context.push(AppRoutes.languageSettings),
                    ),
                  ],
                ),
                ),

                const SizedBox(height: 28),
                _SectionLabel(t.about),
                const SizedBox(height: 10),
                FadeSlideIn.indexed(
                  index: 4,
                  child: _SettingsGroup(
                  items: [
                    _SettingsItem(
                      icon: Icons.security_rounded,
                      gradient: const [Color(0xFFD2BBFF), Color(0xFF630ED4)],
                      label: t.privacyPolicy,
                      trailing: _chevron,
                      onTap: _openPrivacyPolicy,
                    ),
                    _SettingsItem(
                      icon: Icons.ios_share_rounded,
                      gradient: const [Color(0xFFB90A5A), Color(0xFFFE4C8C)],
                      label: t.shareApp,
                      trailing: _chevron,
                      onTapWithContext: _shareApp,
                    ),
                  ],
                ),
                ),

                if (user != null) ...[
                  const SizedBox(height: 28),
                  _LogOutButton(
                    label: t.signOut,
                    onTap: () => _handleLogout(context, ref),
                  ),
                ],

                const SizedBox(height: 16),
                Text(
                  'v$_appVersion',
                  textAlign: TextAlign.center,
                  style: Aurora.text(
                    12,
                    weight: FontWeight.w600,
                    color: const Color(0xFF7B7487),
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

/// File-level so the account card can use it too — it lives outside the
/// state class.
const Widget _chevron = Icon(
  Icons.chevron_right_rounded,
  color: Color(0xFF7B7487),
  size: 22,
);

// ── Account card ───────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _AccountCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user.displayName.isNotEmpty
        ? user.displayName
        : (user.username.isNotEmpty ? user.username : user.email);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Aurora.primary, Color(0xFF630ED4), Color(0xFFFE4C8C)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Aurora.primary.withValues(alpha: 0.3),
              blurRadius: 32,
              spreadRadius: -6,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Aurora.secondary.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Specular sheen over the whole card.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  child: UserAvatar(
                    photoUrl: user.photoUrl,
                    name: user.username.isNotEmpty ? user.username : name,
                    radius: 30,
                  ),
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
                        style: Aurora.text(
                          18,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.username.isNotEmpty
                            ? '@${user.username}'
                            : user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(
                          13,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      if (user.username.isNotEmpty && user.email.isNotEmpty)
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Aurora.text(
                            12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutCard extends StatelessWidget {
  final bool isLoading;

  const _SignedOutCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: Aurora.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Aurora.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/images/logo.png', width: 64, height: 64),
            ),
          ),
          const SizedBox(height: 12),
          Text(t.appName, style: Aurora.text(17, weight: FontWeight.w800)),
          const SizedBox(height: 16),
          if (!isLoading)
            AuroraButton(
              label: t.signIn,
              height: 48,
              onTap: () => context.push('/auth'),
            ),
        ],
      ),
    );
  }
}

// ── Upgrade banner ─────────────────────────────────────────────────────────────

/// Presentation only — the app has no purchase flow yet, so this deliberately
/// does nothing when tapped.
class _UpgradeProCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _UpgradeProCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF8F00), Color(0xFFFF5722)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(
                    17,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(
                    12,
                    weight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
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

// ── Log out ────────────────────────────────────────────────────────────────────

class _LogOutButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LogOutButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFBA1A1A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0x99FFDAD6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20, color: red),
            const SizedBox(width: 8),
            Text(
              label,
              style: Aurora.text(15, weight: FontWeight.w700, color: red),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text.toUpperCase(),
        style: Aurora.text(
          11,
          weight: FontWeight.w700,
          color: const Color(0xFF4A4455),
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

// ── Settings group ─────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: const Color(0xFFECE4FF).withValues(alpha: 0.6),
            );
          }
          return items[i ~/ 2];
        }),
      ),
    );
  }
}

// ── Settings item ──────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final void Function(BuildContext)? onTapWithContext;

  const _SettingsItem({
    required this.icon,
    required this.gradient,
    required this.label,
    this.trailing,
    this.onTap,
    this.onTapWithContext,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapWithContext != null
            ? () => onTapWithContext!(context)
            : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Aurora.text(15, weight: FontWeight.w600),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
