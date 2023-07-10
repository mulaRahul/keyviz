import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../../widgets/widgets.dart';

class LayoutView extends StatelessWidget {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return XExpansionTile(
      title: "Layout",
      children: [
        SubPanelItemGroup(
          items: [
            // vertical align
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final value in VerticalAlignment.values)
                  Padding(
                    padding: EdgeInsets.only(
                      right: value == VerticalAlignment.values.last
                          ? 0
                          : defaultPadding,
                    ),
                    child: Selector<KeyStyleProvider, VerticalAlignment>(
                      selector: (_, keyStyle) => keyStyle.verticalAlignment,
                      builder: (context, verticalAlignment, _) {
                        return XIconButton(
                          icon: value.iconName,
                          tooltip: value.name,
                          onTap: () {
                            context.keyStyle.verticalAlignment = value;
                          },
                          selected: verticalAlignment == value,
                        );
                      },
                    ),
                  ),
              ],
            ),
            // horizontal align
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final value in HorizontalAlignment.values)
                  Padding(
                    padding: EdgeInsets.only(
                      right: value == HorizontalAlignment.values.last
                          ? 0
                          : defaultPadding,
                    ),
                    child: Selector<KeyStyleProvider, HorizontalAlignment>(
                      selector: (_, keyStyle) {
                        return keyStyle.horizontalAlignment;
                      },
                      builder: (context, horizontalAlignment, _) {
                        return XIconButton(
                          icon: value.iconName,
                          tooltip: value.name,
                          onTap: () {
                            context.keyStyle.horizontalAlignment = value;
                          },
                          selected: horizontalAlignment == value,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
        const VerySmallColumnGap(),
        SubPanelItem(
          title: "Icon",
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.showIcon,
            builder: (context, showIcon, _) {
              return XSwitch(
                value: showIcon,
                onChange: (value) => context.keyStyle.showIcon = value,
              );
            },
          ),
        ),
        const VerySmallColumnGap(),
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) =>
              keyStyle.keyCapStyle != KeyCapStyle.minimal,
          builder: (_, enabled, child) => SubPanelItem(
            enabled: enabled,
            title: "Symbol",
            child: child!,
          ),
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.showSymbol,
            builder: (context, showSymbol, _) {
              return XSwitch(
                value: showSymbol,
                onChange: (value) => context.keyStyle.showSymbol = value,
              );
            },
          ),
        ),
        const VerySmallColumnGap(),
        SubPanelItem(
          title: 'Add  "+"  Separator',
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.addPlusSeparator,
            builder: (context, addPlusSeparator, _) {
              return XSwitch(
                value: addPlusSeparator,
                onChange: (value) {
                  context.keyStyle.addPlusSeparator = value;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
