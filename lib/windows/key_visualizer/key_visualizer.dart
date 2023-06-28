import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';

class KeyVisualizer extends StatelessWidget {
  const KeyVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, Axis?>(
      // select the visualization history mode
      selector: (_, keyEvent) => keyEvent.historyDirection,
      builder: (context, direction, _) {
        return direction == null
            ? Selector<KeyEventProvider, List<KeyEventData>>(
                builder: (context, events, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final event in events) _KeyCap(event.label),
                  ],
                ),
                // select the last/latest event list
                selector: (_, keyEvent) => keyEvent.keyboardEvents.isEmpty
                    ? const []
                    : keyEvent.keyboardEvents.values.last.values
                        .toList(growable: false),
              )
            : Selector<KeyEventProvider, Map<String, Map<int, KeyEventData>>>(
                builder: (context, events, _) => Wrap(
                  direction: direction,
                  spacing: defaultPadding,
                  children: [
                    for (final group in events.values)
                      Row(
                        children: [
                          for (final event in group.values) _KeyCap(event.label)
                        ],
                      )
                  ],
                ),
                selector: (_, keyEvent) => keyEvent.keyboardEvents,
                shouldRebuild: (previous, next) => mapEquals(previous, next),
              );
      },
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.only(left: defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(defaultPadding * .5),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Colors.black,
          )
        ],
      ),
      child: Text(label),
    );
  }
}
