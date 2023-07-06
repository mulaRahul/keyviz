import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:keyviz/config/extensions.dart';
import 'package:keyviz/providers/providers.dart';

import 'keycap_wrapper.dart';

class KeyCapGroup extends StatelessWidget {
  const KeyCapGroup({super.key, required this.groupId, required this.events});

  final String groupId;
  final Map<int, KeyEventData> events;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider,
        Tuple6<bool, Color, double, double, double, KeyCapStyle>>(
      builder: (context, tuple, child) {
        // total height + key cap + padding
        final height = tuple.item5 + (tuple.item3 * 2);
        return tuple.item1
            ? Container(
                height: height,
                padding: events.isEmpty
                    ? EdgeInsets.zero
                    : EdgeInsets.all(tuple.item3),
                decoration: BoxDecoration(
                  color: tuple.item2,
                  borderRadius: tuple.item6 == KeyCapStyle.mechanical
                      ? BorderRadius.circular(
                          (height * .5) * tuple.item4.clamp(.0, .32))
                      : BorderRadius.circular(
                          (height * .5) * tuple.item4,
                        ),
                ),
                clipBehavior: Clip.none,
                child: child!,
              )
            : child!;
      },
      selector: (_, keyStyle) => Tuple6(
        keyStyle.backgroundEnabled,
        keyStyle.backgroundColorWithOpacity,
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
    return Selector<KeyStyleProvider, Tuple4<bool, double, Widget?, Alignment>>(
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

        final row = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );

        return context.keyEvent.noKeyCapAnimation
            ? row
            : AnimatedSize(
                duration: context.keyEvent.animationDuration,
                curve: Curves.easeInOutCubic,
                alignment: tuple.item4,
                child: row,
              );
      },
      selector: (_, keyStyle) => Tuple4(
        keyStyle.keyCapStyle == KeyCapStyle.minimal,
        keyStyle.backgroundSpacing,
        keyStyle.separator,
        keyStyle.alignment,
      ),
    );
  }
}
