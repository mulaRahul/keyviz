import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../widgets/widgets.dart';

class MouseTabView extends StatelessWidget {
  const MouseTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: "Visualize Clicks",
          subtitle: "Show click on mouse down with custom animations",
          action: XSwitch(onChange: (value) {}),
        ),
        const Divider(),
        PanelItem(
          title: "Animation",
          asRow: false,
          action: Row(
            children: [
              Container(
                width: defaultPadding * 6,
                height: defaultPadding * 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    width: 2,
                    color: context.colorScheme.secondary,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(defaultPadding * .5),
                ),
              ),
              const SmallRowGap(),
              Container(
                width: defaultPadding * 6,
                height: defaultPadding * 5,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: context.colorScheme.outline,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(defaultPadding * .5),
                ),
              ),
              const SmallRowGap(),
              Container(
                width: defaultPadding * 6,
                height: defaultPadding * 5,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: context.colorScheme.outline,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(defaultPadding * .5),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Click Color",
          subtitle: "Show click on mouse down with custom animations",
          actionFlex: 2,
          action: RawColorInputSubPanelItem(
            onChanged: (color) {},
            defaultValue: Colors.white,
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Show Mouse Events",
          subtitle: "Visualize mouse events like click, drag with key events",
          action: XSwitch(onChange: (value) {}),
        ),
      ],
    );
  }
}
