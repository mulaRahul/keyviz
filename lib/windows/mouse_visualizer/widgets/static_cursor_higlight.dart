import 'package:flutter/material.dart';

import 'cursor_highlight.dart';

class StaticCursorHighlight extends CursorHighlight {
  const StaticCursorHighlight({
    super.key,
    required super.clicked,
    required super.keepHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final size = highlightSize(context);

    return Transform.scale(
      scale: clicked
          ? keepHighlight
              ? .6
              : 1
          : keepHighlight
              ? 1
              : 0,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color(context)),
          ),
        ),
      ),
    );
  }
}
