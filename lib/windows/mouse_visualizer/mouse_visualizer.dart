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
        return tuple.item1
            ? Positioned(
                left: tuple.item2.dx,
                top: Platform.isMacOS ? null : tuple.item2.dy,
                // On macOS, the mouse offset is from the bottomLeft
                // instead of the topLeft
                bottom: Platform.isMacOS ? tuple.item2.dy : null,
                child: IgnorePointer(
                  child: FractionalTranslation(
                    translation: Offset(-.5, Platform.isMacOS ? .5 : -.5),
                    child: const _MouseVisualizer(),
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
