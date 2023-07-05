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
        Tuple7<bool, Color, double, double, double, double, KeyCapStyle>>(
      builder: (context, tuple, child) {
        final height = tuple.item6 + (tuple.item4 * 2);
        return SizedBox(
          // total height + key cap + padding
          height: height,
          child: tuple.item1
              ? ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tuple.item2.withOpacity(tuple.item3),
                      borderRadius: tuple.item7 == KeyCapStyle.mechanical
                          ? BorderRadius.circular(
                              (height * .5) * tuple.item5.clamp(.0, .32))
                          : BorderRadius.circular(
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
              : child!,
        );
      },
      selector: (_, keyStyle) => Tuple7(
        keyStyle.backgroundEnabled,
        keyStyle.backgroundColor,
        keyStyle.backgroundOpacity,
        keyStyle.backgroundSpacing,
        keyStyle.cornerSmoothing,
        keyStyle.keycapHeight,
        keyStyle.keyCapStyle,
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
                width: backgroundSpacing *
                    (separator == null
                        ? isMinimal
                            ? .25
                            : 1
                        : isMinimal
                            ? 1.5
                            : 2),
                child: separator,
              ),
            );
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
