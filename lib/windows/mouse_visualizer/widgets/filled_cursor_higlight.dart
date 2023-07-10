import 'dart:ui';

import 'package:flutter/material.dart';

import 'cursor_highlight.dart';

class FilledCursorHighlight extends CursorHighlight {
  const FilledCursorHighlight({
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
              color: keepHighlight
                  ? color(context).withOpacity(lerpDouble(.25, .5, value) ?? .5)
                  : color(context).withOpacity(lerpDouble(0, .5, value) ?? 0),
            ),
          ),
        );
      },
    );
  }
}
