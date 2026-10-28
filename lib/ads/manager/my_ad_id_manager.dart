import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../core/di/service_locator.dart';
import '../const/ad_config.dart';
import '../const/ads_environment.dart';

class MyAdIdManager extends IAdIdManager {
  @override
  AppAdIds? get admobAdIds {
    final adConfig = getIt<AdConfig>();
    return AppAdIds(
      appId: adConfig.appId,
      appOpenId: null,
    );
  }
}
