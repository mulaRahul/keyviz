import 'dart:ui';

import 'package:flutter/material.dart';

import 'key_cap_animation.dart';

class WhamKeyCapAnimation extends KeyCapAnimation {
  const WhamKeyCapAnimation({
    super.key,
    required super.show,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: show ? 1 : 0),
      duration: animationDuration(context),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, value, child) {
        return Transform.scale(
          scale: lerpDouble(1.25, 1, value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
