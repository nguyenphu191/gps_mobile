import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

import '../const/ad_id_name.dart';

class NativeFullScreen extends StatefulWidget {
  final String nativeFullId;
  final String? nativeFullHighId;
  final VoidCallback handleNavigate;

  const NativeFullScreen({
    super.key,
    required this.nativeFullId,
    required this.handleNavigate,
    this.nativeFullHighId,
  });

  @override
  State<NativeFullScreen> createState() => _NativeFullScreenState();
}

class _NativeFullScreenState extends State<NativeFullScreen>
    with RouteAware, WidgetsBindingObserver {
  bool _closeLocked = true;
  int _secondsLeft = 2;
  Timer? _timer;
  bool _shouldNavigateOnResume = false;
  Timer? _impressionTimer;
  bool _navigated = false;
  bool _showCloseButton = false;

  @override
  void dispose() {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _impressionTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _shouldNavigateOnResume = true;
    } else if (state == AppLifecycleState.resumed && _shouldNavigateOnResume) {
      _shouldNavigateOnResume = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNavigate();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  void _startCountdown() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        setState(() {
          _closeLocked = false;
          _secondsLeft = 0;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            widget.nativeFullHighId != null
                ? EasyNativeAdHigh(
                    factoryId: MyAdIdName.nativeFull,
                    adId: widget.nativeFullId,
                    adIdHigh: widget.nativeFullHighId!,
                    height: MediaQuery.sizeOf(context).height,
                    onLoaded: () {
                      _startCountdown();
                      setState(() {
                        _showCloseButton = true;
                      });
                      _impressionTimer?.cancel();
                      _impressionTimer =
                          Timer(const Duration(seconds: 3), () {
                        if (mounted && !_navigated) {
                          _handleNavigate();
                        }
                      });
                    },
                    onImpression: () {},
                    onFailedToLoad: _handleNavigate,
                  )
                : EasyNativeAd(
                    factoryId: MyAdIdName.nativeFull,
                    adId: widget.nativeFullId,
                    height: MediaQuery.sizeOf(context).height,
                    onLoaded: () {
                      _startCountdown();
                      setState(() {
                        _showCloseButton = true;
                      });
                      _impressionTimer?.cancel();
                      _impressionTimer =
                          Timer(const Duration(seconds: 3), () {
                        if (mounted && !_navigated) {
                          _handleNavigate();
                        }
                      });
                    },
                    onImpression: () {},
                    onFailedToLoad: _handleNavigate,
                  ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                ),
                child: Opacity(
                  opacity: _showCloseButton ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: _closeLocked,
                    child: GestureDetector(
                      onTap: _handleNavigate,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigate() {
    if (mounted) {
      _impressionTimer?.cancel();
      _timer?.cancel();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.handleNavigate.call();
      _navigated = true;
    }
  }
}
