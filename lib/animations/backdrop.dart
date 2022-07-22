import 'package:flutter/material.dart';
import 'package:keyviz/data/properties.dart';
import 'package:provider/provider.dart';

import '../data/config.dart';
import '../providers/keyboard_event.dart';

class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final KeyboardEventProvider keyEventProvider =
        Provider.of<KeyboardEventProvider>(context);

    return Container(
      height: configData.size * 3.75, // keyvizHeight + fontSize + padding
      padding: keyEventProvider.widgets.isEmpty
          ? EdgeInsets.zero
          : EdgeInsets.all(configData.size / 2),
      decoration: BoxDecoration(
        color: configData.borderColor,
        borderRadius: BorderRadius.circular(configData.size / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: configData.animation == AnimationType.none
          ? Wrap(
              direction: Axis.horizontal, // Row
              spacing: configData.size / 2,
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: keyEventProvider.widgets,
            )
          : AnimatedSize(
              curve: Curves.easeOutCirc,
              duration: configData.transitionDuration,
              alignment: Alignment.centerLeft,
              child: Wrap(
                direction: Axis.horizontal, // Row
                spacing: configData.size / 2,
                alignment: WrapAlignment.end,
                runAlignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: keyEventProvider.widgets,
              ),
            ),
    );
  }
}
