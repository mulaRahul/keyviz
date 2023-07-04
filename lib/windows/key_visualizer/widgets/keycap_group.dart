import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:keyviz/providers/providers.dart';

import 'keycap_wrapper.dart';

class KeyCapGroup extends StatelessWidget {
  const KeyCapGroup({super.key, required this.groupId, required this.events});

  final String groupId;
  final Map<int, KeyEventData> events;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider,
        Tuple6<bool, Color, double, double, double, double>>(
      builder: (context, tuple, child) {
        final height = tuple.item6 + (tuple.item4 * 2);
        return tuple.item1
            ? SizedBox(
                // total height + key cap + padding
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tuple.item2.withOpacity(tuple.item3),
                    borderRadius: BorderRadius.circular(
                      (height * .5) * tuple.item5,
                    ),
                  ),
                  child: Padding(
                    padding: events.isEmpty
                        ? EdgeInsets.zero
                        : EdgeInsets.all(tuple.item4),
                    child: child!,
                  ),
                ),
              )
            : child!;
      },
      selector: (_, keyStyle) => Tuple6(
        keyStyle.backgroundEnabled,
        keyStyle.backgroundColor,
        keyStyle.backgroundOpacity,
        keyStyle.backgroundSpacing,
        keyStyle.cornerSmoothing,
        keyStyle.keycapHeight,
      ),
      child: _KeyCapGroup(groupId, events),
    );
  }
}

class _KeyCapGroup extends StatelessWidget {
  const _KeyCapGroup(this.groupId, this.events);

  final String groupId;
  final Map<int, KeyEventData> events;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, Tuple3<bool, double, Widget?>>(
      builder: (context, tuple, _) {
        final isMinimal = tuple.item1;
        final backgroundSpacing = tuple.item2;
        final separator = tuple.item3;

        final children = <Widget>[];

        for (final keyId in events.keys) {
          // add key cap wrapper
          children.add(
            KeyCapWrapper(groupId: groupId, keyId: keyId),
          );
          // add separator/spacing
          if (keyId != events.keys.last) {
            children.add(
              SizedBox(
                width: (isMinimal && separator == null) ? 4 : backgroundSpacing,
                child: separator,
              ),
            );
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        );
      },
      selector: (_, keyStyle) => Tuple3(
        keyStyle.keyCapStyle == KeyCapStyle.minimal,
        keyStyle.backgroundSpacing,
        keyStyle.separator,
      ),
    );
  }
}
