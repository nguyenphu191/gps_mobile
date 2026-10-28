import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import '../../ads/const/ad_config.dart';
import '../../ads/const/ads_environment.dart';
import '../analytics/analytics_observer.dart';
import '../analytics/analytics_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Ads config
  final adConfig = AdsEnvironment.isProd ? AdConfig.prod() : AdConfig.dev();
  getIt.registerSingleton<AdConfig>(adConfig);

  // Firebase Analytics
  final analytics = FirebaseAnalytics.instance;
  getIt.registerSingleton<FirebaseAnalytics>(analytics);

  // Analytics Service
  getIt.registerSingleton<AnalyticsService>(AnalyticsService(analytics));

  // Analytics Observer
  getIt.registerSingleton<AnalyticsObserver>(AnalyticsObserver());

}

Future<void> initFirebaseAnalyticsForAds() async {
  final analytics = getIt<FirebaseAnalytics>();
  await EasyAds.instance.initFirebaseAnalytics(analytics);
}
