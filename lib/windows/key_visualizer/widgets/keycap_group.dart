import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:keyviz/config/extensions.dart';
import 'package:keyviz/providers/providers.dart';

import 'keycap_wrapper.dart';

class KeyCapGroup extends StatelessWidget {
  const KeyCapGroup({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider,
        Tuple6<bool, Color, double, double, double, bool>>(
      builder: (context, tuple, child) {
        // total height + key cap + padding
        final height = tuple.item5 + (tuple.item3 * 2);
        return tuple.item1
            ? Container(
                height: height,
                decoration: BoxDecoration(
                  color: tuple.item2,
                  borderRadius: tuple.item6
                      ? BorderRadius.circular(
                          (height * .5) * tuple.item4.clamp(.0, .32))
                      : BorderRadius.circular(
                          (height * .5) * tuple.item4,
                        ),
                ),
                clipBehavior: context.keyEvent.keyCapAnimation ==
                        KeyCapAnimationType.slide
                    ? Clip.hardEdge
                    : Clip.none,
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
        keyStyle.keyCapStyle == KeyCapStyle.mechanical,
      ),
      child: _KeyCapGroup(groupId),
    );
  }
}

class _KeyCapGroup extends StatelessWidget {
  const _KeyCapGroup(this.groupId);

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final style =
        context.select<KeyStyleProvider, Tuple3<bool, double, Widget?>>(
      (keyStyle) => Tuple3(
        keyStyle.keyCapStyle == KeyCapStyle.minimal,
        keyStyle.backgroundSpacing,
        keyStyle.separator,
        // keyStyle.alignment,
      ),
    );
    final isMinimal = style.item1;
    final backgroundSpacing = style.item2;
    final separator = style.item3;

    return Selector<KeyEventProvider, List<int>>(
      builder: (context, keyIds, _) {
        final children = <Widget>[];

        for (final keyId in keyIds) {
          // add key cap wrapper
          children.add(
            KeyCapWrapper(groupId: groupId, keyId: keyId),
          );
          // add separator/spacing
          if (keyId != keyIds.last) {
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

        return Padding(
          padding: keyIds.isEmpty
              ? EdgeInsets.zero
              : EdgeInsets.all(backgroundSpacing),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
      },
      selector: (_, keyEvent) =>
          keyEvent.keyboardEvents[groupId]?.keys.toList(growable: false) ??
          const [],
      shouldRebuild: (previous, next) => !listEquals(previous, next),
    );
  }
}
