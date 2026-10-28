import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    // debugPrint('🔥 [Analytics] $name ${parameters ?? ''}');
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.map((k, v) => MapEntry(k, _sanitize(v))),
    );
  }

  Object _sanitize(Object value) {
    if (value is bool) return value ? 'true' : 'false';
    return value;
  }

  Future<void> setCurrentScreen(String screenName) async {
    // debugPrint('🔥 [Analytics] screen_view: $screenName');
    await _analytics.logScreenView(screenName: screenName);
  }
}
