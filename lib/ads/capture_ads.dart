import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/di/service_locator.dart';
import '../core/services/storage_service.dart';
import 'const/ad_config.dart';
import 'const/ads_environment.dart';

/// One interstitial per this many photo captures.
const int kPhotoCapturesPerAd = 3;

/// Safety net for the ad never reporting back — see [_showInterstitial].
const Duration _adWatchdog = Duration(seconds: 12);

/// Interstitial after every [kPhotoCapturesPerAd] photos.
///
/// The counter lives in Hive rather than memory: kept in RAM, a user who
/// closes the app between shots would never reach the third capture.
Future<void> showPhotoCaptureAd(BuildContext context, WidgetRef ref) async {
  if (!AdsEnvironment.showAds) return;

  final storage = ref.read(storageServiceProvider);
  final count =
      (storage.getSetting<int>(AppConstants.captureAdCounterKey) ?? 0) + 1;
  await storage.saveSetting(AppConstants.captureAdCounterKey, count);

  if (count % kPhotoCapturesPerAd != 0) return;
  if (!context.mounted) return;
  await _showInterstitial(context);
}

/// Interstitial after every video recording.
Future<void> showVideoCaptureAd(BuildContext context, WidgetRef ref) async {
  if (!AdsEnvironment.showAds) return;
  await _showInterstitial(context);
}

/// Turns EasyAds' fire-and-forget call into a Future that completes once the
/// ad is gone, so callers can await it before pushing their own screen.
///
/// `showInterstitialAd` pushes a full-screen loading route that never closes
/// itself, so popping it here is mandatory. Three paths can leave it up:
/// `adFailedToShow` invokes no callback at all, the call returns silently when
/// another fullscreen ad is already showing, and nothing times out a slow
/// load. The watchdog covers all three — without it the user is stuck on a
/// splash with back navigation disabled.
Future<void> _showInterstitial(BuildContext context) {
  final completer = Completer<void>();
  final navigator = Navigator.of(context);
  var handled = false;
  Timer? watchdog;

  void finish({required bool popRoute}) {
    if (handled) return;
    handled = true;
    watchdog?.cancel();
    if (popRoute && navigator.canPop()) navigator.pop();
    if (!completer.isCompleted) completer.complete();
  }

  watchdog = Timer(_adWatchdog, () => finish(popRoute: true));

  EasyAds.instance.showInterstitialAd(
    context,
    adId: getIt<AdConfig>().interCapture,
    adDissmissed: () => finish(popRoute: true),
    onFailed: () => finish(popRoute: true),
  );

  return completer.future;
}
