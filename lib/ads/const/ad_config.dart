import 'package:flutter/foundation.dart';

/// Central registry of every ad unit ID used in the app.
/// Switch dev/prod via [AdConfig.dev] / [AdConfig.prod] in `service_locator.dart`.
class AdConfig {
  final String appId;
  // ── App open ──
  final String appOpenResume;
  final String openSplash;
  // ── Native ──
  final String nativeFullSplash;
  final String nativeLanguage;
  final String nativeLanguageSelect;
  final String nativeIntro1;
  final String nativeIntro2;
  final String nativeIntro3;
  final String nativeIntro4;
  final String nativeHome;
  final String nativeLibrary;
  final String nativeExplore;
  final String nativeDestination;
  // ── Inter ──
  final String interCapture;
  final String interViewAll;
  final String interBack;

  const AdConfig({
    required this.appId,
    required this.appOpenResume,
    required this.openSplash,
    required this.nativeFullSplash,
    required this.nativeLanguage,
    required this.nativeLanguageSelect,
    required this.nativeIntro1,
    required this.nativeIntro2,
    required this.nativeIntro3,
    required this.nativeIntro4,
    required this.nativeHome,
    required this.nativeLibrary,
    required this.nativeExplore,
    required this.nativeDestination,
    required this.interCapture,
    required this.interViewAll,
    required this.interBack,
  });

  /// Development — Google test ad unit IDs.
  factory AdConfig.dev() {
    const testInterstitial = 'ca-app-pub-3940256099942544/4411468910';
    const testNative = 'ca-app-pub-3940256099942544/3986624511';
    const testAppOpen = 'ca-app-pub-3940256099942544/5575463023';

    return AdConfig(
      appId: defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544~1458002511'
          : 'ca-app-pub-3940256099942544~3347511713',
      appOpenResume: testAppOpen,
      openSplash: testAppOpen,
      nativeFullSplash: testNative,
      nativeLanguage: testNative,
      nativeLanguageSelect: testNative,
      nativeIntro1: testNative,
      nativeIntro2: testNative,
      nativeIntro3: testNative,
      nativeIntro4: testNative,
      nativeHome: testNative,
      nativeLibrary: testNative,
      nativeExplore: testNative,
      nativeDestination: testNative,
      interCapture: testInterstitial,
      interViewAll: testInterstitial,
      interBack: testInterstitial,
    );
  }

  /// Production — replace placeholders with real ad unit IDs.
  factory AdConfig.prod() {
    return const AdConfig(
      appId: 'ca-app-pub-5839511744003864~8232246175',
      appOpenResume: 'ca-app-pub-5839511744003864/8087821658',
      openSplash: 'ca-app-pub-5839511744003864/6774739984',
      nativeFullSplash: 'ca-app-pub-5839511744003864/7150264645',
      nativeLanguage: 'ca-app-pub-5839511744003864/4148576642',
      nativeLanguageSelect: 'ca-app-pub-5839511744003864/8993709215',
      nativeIntro1: 'ca-app-pub-5839511744003864/1583077342',
      nativeIntro2: 'ca-app-pub-5839511744003864/9269995676',
      nativeIntro3: 'ca-app-pub-5839511744003864/7956914008',
      nativeIntro4: 'ca-app-pub-5839511744003864/2592218323',
      nativeHome: 'ca-app-pub-5839511744003864/8340057383',
      interCapture: 'ca-app-pub-5839511744003864/7026975712',
      nativeLibrary: 'ca-app-pub-5839511744003864/1634093948',
      nativeExplore: 'ca-app-pub-5839511744003864/3087730700',
      nativeDestination: 'ca-app-pub-5839511744003864/6835404029',
      interViewAll: 'ca-app-pub-5839511744003864/5522322357',
      interBack: 'ca-app-pub-5839511744003864/8319187726',
    );
  }
}
