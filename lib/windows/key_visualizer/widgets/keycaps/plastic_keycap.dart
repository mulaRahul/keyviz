import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'keycap.dart';
import 'keycap_content.dart';

class PlasticKeyCap extends KeyCap {
  const PlasticKeyCap({super.key, required super.event});

  @override
  Widget build(BuildContext context) {
    final style = keyStyle(context);
    final size = style.minContainerSize;
    final outerSize = style.minOuterContainerSize;

    return Container(
      height: outerSize.height,
      decoration: BoxDecoration(
        border: border(style),
        color: secondaryColor(style),
        gradient: secondaryGradient(
          style,
          transform: GradientRotation(radians(-30)),
        ),
        borderRadius: style.outerBorderRadius,
      ),
      padding: style.containerPadding,
      child: TweenAnimationBuilder(
        duration: animationDuration(context),
        curve: Curves.easeInOutCubicEmphasized,
        tween: Tween<double>(begin: 0, end: event.pressed ? 1 : 0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              0,
              style.fontSize * (lerpDouble(0.0, .25, value) ?? 0),
            ),
            child: child,
          );
        },
        child: Container(
          height: size.height,
          constraints: BoxConstraints(minWidth: size.width),
          padding: style.contentPadding,
          decoration: BoxDecoration(
            border: border(style),
            color: primaryColor(style),
            gradient: primaryGradient(
              style,
              transform: GradientRotation(radians(-30)),
            ),
            borderRadius: style.borderRadius,
          ),
          alignment: style.childrenAlignment,
          child: KeyCapContent(event),
        ),
      ),
    );
  }
}
