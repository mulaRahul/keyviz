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
                top: tuple.item2.dy,
                child: const FractionalTranslation(
                  translation: Offset(-.5, -.5),
                  child: _MouseVisualizer(),
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
