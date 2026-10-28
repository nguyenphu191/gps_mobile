import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_bottom_nav.dart';
import '../theme/aurora_motion.dart';

/// Hosts the four tabbed screens under one floating bottom nav.
///
/// The nav bar floats over the content (as in the design), so the branch
/// content is given extra bottom padding through [MediaQuery] — that way every
/// tab screen's own scroll view keeps its last item clear of the bar without
/// each screen having to know the bar exists.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                bottom: media.padding.bottom + kAppBottomNavHeight,
              ),
              viewPadding: media.viewPadding.copyWith(
                bottom: media.viewPadding.bottom + kAppBottomNavHeight,
              ),
            ),
            child: shell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: media.padding.bottom,
            child: AppBottomNav(
              currentIndex: shell.currentIndex,
              onTap: (index) => shell.goBranch(
                index,
                // Tapping the active tab pops that branch back to its root.
                initialLocation: index == shell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps every tab alive (like an IndexedStack) but cross-fades and nudges
/// the incoming tab in the direction of travel.
class AnimatedBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer> {
  int _previous = 0;

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) _previous = old.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final reduce = AuroraMotion.reduce(context);
    final dir = widget.currentIndex >= _previous ? 1.0 : -1.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _BranchFade(
            active: i == widget.currentIndex,
            direction: dir,
            reduce: reduce,
            child: widget.children[i],
          ),
      ],
    );
  }
}

class _BranchFade extends StatefulWidget {
  final bool active;
  final double direction;
  final bool reduce;
  final Widget child;

  const _BranchFade({
    required this.active,
    required this.direction,
    required this.reduce,
    required this.child,
  });

  @override
  State<_BranchFade> createState() => _BranchFadeState();
}

class _BranchFadeState extends State<_BranchFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: widget.active ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant _BranchFade old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) {
      if (widget.reduce) {
        _c.value = widget.active ? 1 : 0;
      } else {
        widget.active ? _c.forward() : _c.reverse();
      }
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
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        // Hidden tabs are removed from layout/paint/hit-testing once faded out.
        return Offstage(
          offstage: !widget.active && _c.isDismissed,
          child: TickerMode(
            enabled: widget.active || !_c.isDismissed,
            child: IgnorePointer(
              ignoring: !widget.active,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset((1 - t) * 14 * widget.direction, 0),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
