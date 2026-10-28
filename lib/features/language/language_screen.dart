import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gpscamerastamp/shared/providers/language_provider.dart';
import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/localization/language_options.dart';
import 'package:gpscamerastamp/core/theme/aurora.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_blob.dart';
import 'package:gpscamerastamp/shared/widgets/aurora_button.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ads_environment.dart';
import '../../ads/widgets/easy_native_ad_with_fallback.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selectedCode;
  final int _entryTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logEvent(AnalyticsEvents.languageView);
  }

  void _onContinue() {
    if (_selectedCode == null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'dismiss',
        barrierColor: Colors.black.withValues(alpha: 0.4),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, _, _) => const _SelectLanguageDialog(),
        transitionBuilder: (ctx, anim, _, child) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12 * anim.value, sigmaY: 12 * anim.value),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(anim),
              child: child,
            ),
          ),
        ),
      );
      return;
    }
    final timeToAction = DateTime.now().millisecondsSinceEpoch - _entryTime;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.languageComplete,
      parameters: {
        'time_to_action': timeToAction,
        'selected_language': _selectedCode!,
      },
    );
    context.go('/intro');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Aurora.bgSoft, Aurora.bgSoftEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const AuroraBlob(top: -64, left: -64, size: 256, color: Aurora.primary),
            const AuroraBlob(top: 160, right: -80, size: 288, color: Aurora.aqua),
            const AuroraBlob(bottom: -64, left: 120, size: 320, color: Aurora.secondary),
            Column(
              children: [
                SizedBox(height: topPad + 24),
                _Header(
                  title: t.selectLanguageTitle,
                  subtitle: t.selectLanguageSubtitle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                      itemCount: kLanguageOptions.length,
                      itemBuilder: (context, index) {
                        final lang = kLanguageOptions[index];
                        return _LangCard(
                          lang: lang,
                          selected: lang.code == _selectedCode,
                          onTap: () {
                            ref
                                .read(languageNotifierProvider.notifier)
                                .setLanguage(lang.code);
                            setState(() => _selectedCode = lang.code);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: AuroraButton(
                    label: t.continueText,
                    trailingIcon: Icons.east_rounded,
                    enabled: _selectedCode != null,
                    onTap: _onContinue,
                  ),
                ),
                if (AdsEnvironment.showAds)
                  Builder(
                    builder: (context) {
                      final currentAdId = _selectedCode == null
                          ? getIt<AdConfig>().nativeLanguage
                          : getIt<AdConfig>().nativeLanguageSelect;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 12),
                        child: EasyNativeAdWithFallback(
                          key: ValueKey(currentAdId),
                          factoryId: MyAdIdName.nativeFull,
                          adId: currentAdId,
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                      );
                    },
                  )
                else
                  SizedBox(height: bottomPad + 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: Aurora.aquaViolet,
                    boxShadow: Aurora.cardShadow,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🌍', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 2,
                  child: Text('✨', style: TextStyle(fontSize: 14)),
                ),
                const Positioned(
                  bottom: 2,
                  left: 4,
                  child: Text(
                    '✦',
                    style: TextStyle(fontSize: 13, color: Aurora.mint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Aurora.text(25, weight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Aurora.text(13.5, color: Aurora.subText),
          ),
        ],
      ),
    );
  }
}

// ── Language card (grid item) ──────────────────────────────────────────────────

class _LangCard extends StatelessWidget {
  final LanguageOption lang;
  final bool selected;
  final VoidCallback onTap;

  const _LangCard({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.02 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: selected ? Aurora.primaryGradient : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected ? Aurora.glow.map((s) => s.copyWith(blurRadius: 18, offset: const Offset(0, 6), color: Aurora.primary.withValues(alpha: 0.22))).toList() : Aurora.cardShadow,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? Aurora.selectedFill : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEDE9FE)),
                  ),
                  child: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(
                          14.5,
                          weight: FontWeight.w700,
                          color: selected ? Aurora.primary : Aurora.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Aurora.text(12, color: Aurora.subText),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      gradient: Aurora.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── "Please select a language" dialog ──────────────────────────────────────────

class _SelectLanguageDialog extends StatelessWidget {
  const _SelectLanguageDialog();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: Aurora.modalShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 96,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: Aurora.sunnyGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Aurora.sunnyEnd.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const Positioned(
                      top: 0,
                      right: 4,
                      child: Text('✦', style: TextStyle(fontSize: 14, color: Aurora.mint)),
                    ),
                    const Positioned(
                      top: 16,
                      left: 4,
                      child: CircleAvatar(radius: 5, backgroundColor: Aurora.sunny),
                    ),
                    const Positioned(
                      bottom: 4,
                      right: 2,
                      child: Text('✨', style: TextStyle(fontSize: 16)),
                    ),
                    const Positioned(
                      bottom: 10,
                      left: 6,
                      child: Text('◆', style: TextStyle(fontSize: 11, color: Aurora.mint)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.pleaseSelectLanguage,
                textAlign: TextAlign.center,
                style: Aurora.text(20, weight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                t.chooseLanguageContinue,
                textAlign: TextAlign.center,
                style: Aurora.text(14, color: Aurora.subText, height: 1.4),
              ),
              const SizedBox(height: 24),
              AuroraButton(
                label: t.ok,
                height: 52,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
