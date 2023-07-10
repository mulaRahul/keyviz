import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../../widgets/widgets.dart';

class BorderView extends StatelessWidget {
  const BorderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, bool>(
      selector: (_, keyStyle) => keyStyle.borderEnabled,
      builder: (context, enabled, _) => XExpansionTile(
        title: "Border",
        children: [
          Selector<KeyStyleProvider, bool>(
              selector: (_, keyStyle) => keyStyle.differentColorForModifiers,
              builder: (context, differentColors, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SubPanelItemGroup(
                      items: [
                        RawSubPanelItem(
                          title: "Enable",
                          child: XSwitch(
                            value: enabled,
                            onChange: (value) {
                              context.keyStyle.borderEnabled = value;
                            },
                          ),
                        ),
                        if (!differentColors)
                          RawColorInputSubPanelItem(
                            enabled: enabled,
                            label: "Border Color",
                            defaultValue: context.keyStyle.borderColor,
                            onChanged: (color) {
                              context.keyStyle.borderColor = color;
                            },
                          ),
                      ],
                    ),
                    if (differentColors) ...[
                      const VerySmallColumnGap(),
                      SubPanelItem(
                        enabled: enabled,
                        title: "Normal",
                        child: SizedBox(
                          width: defaultPadding * 10,
                          child: RawColorInputSubPanelItem(
                            label: "Normal Border Color",
                            defaultValue: context.keyStyle.borderColor,
                            onChanged: (color) {
                              context.keyStyle.borderColor = color;
                            },
                          ),
                        ),
                      ),
                      const VerySmallColumnGap(),
                      SubPanelItem(
                        enabled: enabled,
                        title: "Modifier",
                        child: SizedBox(
                          width: defaultPadding * 10,
                          child: RawColorInputSubPanelItem(
                            label: "Modifier Border Color",
                            defaultValue: context.keyStyle.mBorderColor,
                            onChanged: (color) {
                              context.keyStyle.mBorderColor = color;
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
          const VerySmallColumnGap(),
          SubPanelItem(
            enabled: enabled,
            title: "Thickness",
            child: Selector<KeyStyleProvider, double>(
              selector: (_, keyStyle) => keyStyle.borderWidth,
              builder: (context, borderWidth, _) => XSlider(
                suffix: "px",
                min: 1,
                max: 8,
                value: borderWidth,
                onChanged: (value) => context.keyStyle.borderWidth = value,
              ),
            ),
          ),
          const VerySmallColumnGap(),
          SubPanelItem(
            title: "Rounded Corner",
            child: Selector<KeyStyleProvider, double>(
              selector: (_, keyStyle) => keyStyle.cornerSmoothing,
              builder: (context, cornerSmoothing, _) {
                return XSlider(
                  max: 100,
                  suffix: "%",
                  value: cornerSmoothing * 100,
                  onChanged: (value) {
                    context.keyStyle.cornerSmoothing = value / 100;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
