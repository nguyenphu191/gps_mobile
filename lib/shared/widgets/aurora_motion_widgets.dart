import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/aurora_motion.dart';

/// Fades and lifts [child] into place once, after [delay].
/// Pass `AuroraMotion.delayFor(index)` for staggered lists.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double dy;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 16,
    this.duration = const Duration(milliseconds: 420),
  });

  /// Convenience for the n-th item of a list.
  FadeSlideIn.indexed({
    Key? key,
    required int index,
    required Widget child,
    double dy = 16,
  }) : this(
         key: key,
         delay: AuroraMotion.delayFor(index),
         dy: dy,
         child: child,
       );

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );
  bool _skip = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    _skip = AuroraMotion.reduce(context);
    if (_skip) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * widget.dy),
          child: child,
        ),
      ),
    );
  }
}

/// Scale-on-press wrapper with optional haptic tick.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;
  final HitTestBehavior behavior;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.haptic = false,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Number that counts up to [value] when it first appears / changes.
class CountUp extends StatelessWidget {
  final num value;
  final int fractionDigits;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const CountUp({
    super.key,
    required this.value,
    this.fractionDigits = 0,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    final d = AuroraMotion.reduce(context) ? Duration.zero : duration;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: d,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('${v.toStringAsFixed(fractionDigits)}$suffix', style: style),
    );
  }
}
