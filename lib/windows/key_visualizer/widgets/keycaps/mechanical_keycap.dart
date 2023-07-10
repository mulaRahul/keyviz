import 'dart:ui';

import 'package:flutter/material.dart';

import 'keycap.dart';
import 'keycap_content.dart';

class MechanicalKeyCap extends KeyCap {
  const MechanicalKeyCap({super.key, required super.event});

  @override
  Widget build(BuildContext context) {
    final style = keyStyle(context);

    final size = style.minContainerSize;
    final outerSize = outerContainerSize(style);

    return TweenAnimationBuilder(
      duration: animationDuration(context),
      curve: Curves.easeInOutCubicEmphasized,
      tween: Tween<double>(begin: 0, end: event.pressed ? 1 : 0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: lerpDouble(1, .95, value),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.multiply,
              gradient: LinearGradient(
                stops: const [.0, .25, .75, 1.0],
                colors: [
                  Colors.black.withOpacity(value.clamp(0, .5)),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(value.clamp(0, .5)),
                ],
              ),
              borderRadius: style.outerBorderRadius,
            ),
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: outerSize.height,
        width: outerSize.width,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                border: border(style),
                color: secondaryColor(style),
                borderRadius: style.outerBorderRadius,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: style.outerBorderRadius,
              ),
            ),
            Column(
              children: [
                // highlight
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: style.fontSize,
                      width: (outerSize.width - (outerSize.height * .5)) * .5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.softLight,
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: [.24, 1.0],
                            colors: [Colors.white54, Colors.transparent],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: style.outerBorderRadius.topLeft,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: outerSize.height * .5,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            backgroundBlendMode: BlendMode.softLight,
                            gradient: LinearGradient(
                              stops: [.6, 1.0],
                              colors: [Colors.white54, Colors.white70],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: style.fontSize,
                      width: (outerSize.width - (outerSize.height * .5)) * .5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.softLight,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [.24, 1.0],
                            colors: [Colors.white70, Colors.transparent],
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: style.outerBorderRadius.topRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // shadow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: style.fontSize * 1.25,
                      width: (outerSize.width - (outerSize.height * .5)) * .5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.multiply,
                          gradient: const LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topCenter,
                            stops: [.24, 1.0],
                            colors: [Colors.black45, Colors.transparent],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: style.outerBorderRadius.bottomLeft,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: outerSize.height * .5,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            backgroundBlendMode: BlendMode.multiply,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: style.fontSize * 1.25,
                      width: (outerSize.width - (outerSize.height * .5)) * .5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.multiply,
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topCenter,
                            stops: [.24, 1.0],
                            colors: [Colors.black45, Colors.transparent],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: style.outerBorderRadius.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: style.containerPadding,
              height: size.height,
              constraints: BoxConstraints(minWidth: size.width),
              padding: style.contentPadding,
              decoration: BoxDecoration(
                color: primaryColor(style),
                borderRadius: style.borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset:
                        Offset(-style.fontSize * .05, -style.fontSize * .05),
                  ),
                  BoxShadow(
                    color: Colors.white24,
                    offset: Offset(style.fontSize * .04, 0),
                  ),
                  BoxShadow(
                    color: Colors.white12,
                    offset: Offset(0, -style.fontSize * .04),
                  ),
                ],
              ),
              foregroundDecoration: event.isModifier
                  ? null
                  : BoxDecoration(
                      backgroundBlendMode: BlendMode.multiply,
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, Colors.black38],
                      ),
                      borderRadius: style.borderRadius,
                    ),
              alignment: style.childrenAlignment,
              child: KeyCapContent(event),
            ),
          ],
        ),
      ),
    );
  }
}

// sweep gradient
// const SweepGradient(
//   stops: [.06, .14, .36, .44, .56, .66, .84, 0.96],
//   colors: [
//     Colors.transparent,
//     Colors.black38,
//     Colors.black38,
//     Colors.transparent,
//     Colors.transparent,
//     Colors.white38,
//     Colors.white30,
//     Colors.transparent,
//   ],
// ),
