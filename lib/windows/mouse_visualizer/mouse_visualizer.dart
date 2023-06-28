import 'package:flutter/material.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class MouseVisualizer extends StatelessWidget {
  const MouseVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, Offset>(
      builder: (context, offset, child) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: child!,
        );
      },
      selector: (_, keyEvent) => keyEvent.cursorOffset,
      child: Selector<KeyEventProvider, bool>(
        builder: (context, buttonDown, child) {
          return FractionalTranslation(
            translation: const Offset(-.5, -.5),
            child: SizedBox.square(
              dimension: buttonDown ? 32 : 64, // use fontSize
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
              ),
            ),
          );
        },
        selector: (_, keyEvent) => keyEvent.mouseButtonDown,
      ),
    );
  }
}
