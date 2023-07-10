import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:keyviz/config/extensions.dart';

import 'key_cap_animation.dart';

class SlideKeyCapAnimation extends KeyCapAnimation {
  const SlideKeyCapAnimation({
    super.key,
    required super.show,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return context.keyStyle.backgroundEnabled
        // clipping in place
        ? AnimatedSlide(
            offset: Offset(0, show ? 0 : 1.25),
            duration: animationDuration(context),
            curve: Curves.easeInOutCubicEmphasized,
            child: child,
          )
        // no clipping, add fade effect
        : TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: show ? 1 : 0),
            duration: animationDuration(context),
            curve: Curves.easeInOutCubicEmphasized,
            builder: (_, value, child) {
              return FractionalTranslation(
                translation: Offset(0, lerpDouble(1.25, 0, value) ?? 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: child,
          );
  }
}
