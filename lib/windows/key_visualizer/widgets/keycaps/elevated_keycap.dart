import 'package:flutter/material.dart';

import 'keycap.dart';
import 'keycap_content.dart';

class ElevatedKeyCap extends KeyCap {
  const ElevatedKeyCap({super.key, required super.event});

  @override
  Widget build(BuildContext context) {
    final style = keyStyle(context);
    final size = style.minContainerSize;

    return SizedBox(
      height: style.keycapHeight,
      child: IntrinsicWidth(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: size.height,
              constraints: BoxConstraints(
                minWidth: size.width,
              ),
              decoration: BoxDecoration(
                color: secondaryColor(style),
                border: border(style),
                borderRadius: style.outerBorderRadius,
              ),
            ),
            AnimatedPadding(
              curve: Curves.easeInOutCubicEmphasized,
              duration: animationDuration(context),
              padding: event.pressed ? EdgeInsets.zero : style.containerPadding,
              child: Container(
                height: size.height,
                constraints: BoxConstraints(minWidth: size.width),
                padding: style.contentPadding,
                decoration: BoxDecoration(
                  color: primaryColor(style),
                  border: border(style),
                  borderRadius: style.borderRadius,
                ),
                alignment: style.childrenAlignment,
                child: KeyCapContent(event),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
