import 'package:flutter/material.dart';

import 'keycap.dart';
import 'keycap_content.dart';

class FlatKeyCap extends KeyCap {
  const FlatKeyCap({super.key, required super.event});

  @override
  Widget build(BuildContext context) {
    final style = keyStyle(context);
    final size = style.minContainerSize;

    return AnimatedScale(
      scale: event.pressed ? .75 : 1,
      duration: animationDuration(context),
      curve: Curves.easeInOutCubicEmphasized,
      child: Container(
        height: size.height,
        constraints: BoxConstraints(
          minWidth: size.width,
        ),
        padding: style.contentPadding,
        decoration: BoxDecoration(
          color: primaryColor(style),
          border: border(style),
          gradient: primaryGradient(style),
          borderRadius: style.borderRadius,
        ),
        alignment: style.childrenAlignment,
        child: KeyCapContent(event),
      ),
    );
  }
}
