import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:keyviz/providers/providers.dart';

import 'widgets/widgets.dart';

class MouseVisualizer extends StatelessWidget {
  const MouseVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, Tuple2<bool, Offset>>(
      builder: (context, tuple, child) {
        final devicePixelRatio = MediaQuery.of(context)
            .devicePixelRatio; // Get the logical pixel ratio

        return tuple.item1
            ? Positioned(
                left: tuple.item2.dx /
                    devicePixelRatio, // Horizontal offset of the cursor divided by the logical pixel ratio

                // On macOS, the mouse offset is from the bottomLeft
                // instead of the topLeft
                top: Platform.isMacOS
                    ? null
                    : tuple.item2.dy /
                        devicePixelRatio, // The vertical offset of the cursor divided by the logical pixel ratio
                bottom: Platform.isMacOS
                    ? tuple.item2.dy /
                        devicePixelRatio // The vertical offset of the cursor divided by the logical pixel ratio
                    : null,
                child: const IgnorePointer(
                  child: FractionalTranslation(
                    translation: Offset(-.5, -.5),
                    child: _MouseVisualizer(),
                  ),
                ),
              )
            : const SizedBox();
      },
      selector: (_, keyEvent) => Tuple2(
        keyEvent.showMouseClicks,
        keyEvent.cursorOffset,
      ),
    );
  }
}

class _MouseVisualizer extends StatelessWidget {
  const _MouseVisualizer();

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, Tuple2<bool, bool>>(
      builder: (context, tuple, _) => MouseHighlightWrapper(
        clicked: tuple.item1,
        keepHighlight: tuple.item2,
      ),
      selector: (_, keyEvent) => Tuple2(
        keyEvent.mouseButtonDown,
        keyEvent.highlightCursor,
      ),
    );
  }
}
