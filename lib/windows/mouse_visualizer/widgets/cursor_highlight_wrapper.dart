import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/key_style.dart';

import 'widgets.dart';

class MouseHighlightWrapper extends StatelessWidget {
  const MouseHighlightWrapper({
    super.key,
    required this.clicked,
    required this.keepHighlight,
  });

  final bool clicked;
  final bool keepHighlight;

  @override
  Widget build(BuildContext context) {
    final clickAnimationType =
        context.select<KeyStyleProvider, MouseClickAnimation>(
      (keyStyle) => keyStyle.clickAnimation,
    );

    switch (clickAnimationType) {
      case MouseClickAnimation.static:
        return StaticCursorHighlight(
          clicked: clicked,
          keepHighlight: keepHighlight,
        );

      case MouseClickAnimation.focus:
        return FocusCursorHighlight(
          clicked: clicked,
          keepHighlight: keepHighlight,
        );

      case MouseClickAnimation.filled:
        return FilledCursorHighlight(
          clicked: clicked,
          keepHighlight: keepHighlight,
        );
    }
  }
}
