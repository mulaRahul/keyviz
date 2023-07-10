import 'dart:ui';

import 'package:flutter/material.dart';

import 'cursor_highlight.dart';

class FocusCursorHighlight extends CursorHighlight {
  const FocusCursorHighlight({
    super.key,
    required super.clicked,
    required super.keepHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final size = highlightSize(context);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: clicked ? 1 : 0),
      duration: animationDuration(context),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, value, _) {
        return SizedBox.square(
          dimension: size * (lerpDouble(1, .6, value) ?? 1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: lerpDouble(1, 4, value) ?? 1,
                color: keepHighlight
                    ? color(context)
                    : color(context).withOpacity(value),
              ),
            ),
          ),
        );
      },
    );
  }
}
