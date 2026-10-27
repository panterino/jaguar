import 'package:flutter/material.dart';

import '../theme.dart';

/// Fades and lifts its child into place when it first shows. Give each item of
/// a list its [index] and they come in one after another. Uses no timers, so
/// it never leaves anything pending; with animations off it just shows.
class Appear extends StatelessWidget {
  const Appear({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = 60 * index.clamp(0, 8);
    final total = 380 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion(context, Duration(milliseconds: total)),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
      ),
      child: child,
    );
  }
}
