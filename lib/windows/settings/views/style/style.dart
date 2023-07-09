import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../../widgets/widgets.dart';
import 'typography.dart';
import 'background.dart';
import 'border.dart';
import 'color.dart';
import 'layout.dart';

class StyleTabView extends StatelessWidget {
  const StyleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    const div = Divider(height: defaultPadding);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding * .5),
          child: PanelItem(
            title: "Preset",
            action: Selector<KeyStyleProvider, KeyCapStyle>(
              selector: (_, keyStyle) => keyStyle.keyCapStyle,
              builder: (context, preset, _) {
                return XDropdown<KeyCapStyle>(
                  value: preset,
                  options: KeyCapStyle.values,
                  onChanged: (value) => context.keyStyle.keyCapStyle = value,
                );
              },
            ),
          ),
        ),
        div,
        const TypographyView(),
        div,
        const LayoutView(),
        div,
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) {
            return keyStyle.keyCapStyle == KeyCapStyle.minimal;
          },
          builder: (_, isMinimal, __) {
            return isMinimal
                ? const SizedBox()
                : const Column(
                    children: [ColorView(), div, BorderView(), div],
                  );
          },
        ),
        const BackgroundView(),
        const SmallColumnGap(),
      ],
    );
  }
}
