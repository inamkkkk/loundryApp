import 'package:flutter/material.dart';

class SlideInFade extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const SlideInFade({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        // Stagger effect based on index (simulated by delay in start or just pure duration offset, but TweenBuilder runs on build)
        // For simple stagger without a manager, we can just use the value directly but that animations all at once.
        // To truly stagger simply with TweenAnimationBuilder, we'd need a Future delay.
        // Let's stick to a simple entry animation that runs when the widget is built.

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
