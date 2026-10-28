import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/aurora_motion.dart';

/// Page factories for the router.
///
/// * [fadeThrough] – onboarding-style hand-offs (splash → language → intro).
/// * [slideUp] – full-screen "modal" flows (camera, sign-in).
/// * [push] – ordinary drill-down; uses the platform route so iOS keeps its
///   native slide and edge-swipe-back (see [AuroraPageTransitionsBuilder]).
class AuroraPage {
  AuroraPage._();

  static Page<T> fadeThrough<T>(GoRouterState state, Widget child) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: AuroraMotion.slow,
        reverseTransitionDuration: AuroraMotion.normal,
        transitionsBuilder: (context, animation, secondary, child) {
          if (AuroraMotion.reduce(context)) return child;
          final inCurve = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
          );
          final outCurve = CurvedAnimation(
            parent: secondary,
            curve: const Interval(0, 0.5, curve: Curves.easeIn),
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(outCurve),
            child: FadeTransition(
              opacity: inCurve,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(inCurve),
                child: child,
              ),
            ),
          );
        },
      );

  static Page<T> slideUp<T>(GoRouterState state, Widget child) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: AuroraMotion.slow,
        reverseTransitionDuration: AuroraMotion.normal,
        transitionsBuilder: (context, animation, secondary, child) {
          if (AuroraMotion.reduce(context)) return child;
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0, 0.6)),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      );

  /// Platform route: theme-driven, keeps iOS swipe-back.
  static Page<T> push<T>(GoRouterState state, Widget child) =>
      MaterialPage<T>(key: state.pageKey, child: child);
}

/// Android transition for the app: a short slide + fade with the page below
/// receding slightly. (iOS uses the native Cupertino transition.)
class AuroraPageTransitionsBuilder extends PageTransitionsBuilder {
  const AuroraPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AuroraMotion.reduce(context)) return child;
    final enter = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final recede = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.06, 0),
      ).animate(recede),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.85).animate(recede),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(enter),
          child: FadeTransition(opacity: enter, child: child),
        ),
      ),
    );
  }
}

/// Theme entry: native on iOS, [AuroraPageTransitionsBuilder] elsewhere.
const PageTransitionsTheme auroraPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.android: AuroraPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AuroraPageTransitionsBuilder(),
    TargetPlatform.linux: AuroraPageTransitionsBuilder(),
    TargetPlatform.windows: AuroraPageTransitionsBuilder(),
  },
);
