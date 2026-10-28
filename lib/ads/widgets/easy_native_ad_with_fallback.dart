import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

/// Wraps [EasyNativeAd] (and optionally [EasyNativeAdHigh]) with a timeout
/// and a graceful fallback widget.
class EasyNativeAdWithFallback extends StatefulWidget {
  final String factoryId;
  final String adId;
  final String? adIdHigh;
  final double height;
  final Widget? fallbackWidget;
  final Duration timeout;
  final Key? adKey;

  const EasyNativeAdWithFallback({
    super.key,
    required this.factoryId,
    required this.adId,
    this.adIdHigh,
    required this.height,
    this.fallbackWidget,
    this.timeout = const Duration(seconds: 15),
    this.adKey,
  });

  @override
  State<EasyNativeAdWithFallback> createState() =>
      _EasyNativeAdWithFallbackState();
}

class _EasyNativeAdWithFallbackState extends State<EasyNativeAdWithFallback> {
  bool _failed = false;
  Timer? _timeoutTimer;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(widget.timeout, () {
      if (mounted) setState(() => _failed = true);
    });
    _subscription = EasyAds.instance.onEvent.listen((event) {
      final type = event.type;
      if (type == AdEventType.adFailedToLoad ||
          type == AdEventType.adFailedToShow) {
        if (mounted) setState(() => _failed = true);
      }
      if (type == AdEventType.adLoaded) {
        _timeoutTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallbackWidget ??
          SizedBox(
            height: widget.height,
            child: const Center(
              child: Text(
                'Ad not available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
    }

    if (widget.adIdHigh != null) {
      return EasyNativeAdHigh(
        factoryId: widget.factoryId,
        adId: widget.adId,
        adIdHigh: widget.adIdHigh!,
        height: widget.height,
        key: widget.adKey,
      );
    }
    return EasyNativeAd(
      factoryId: widget.factoryId,
      adId: widget.adId,
      height: widget.height,
      key: widget.adKey,
    );
  }
}
