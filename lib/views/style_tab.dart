import 'package:flutter/material.dart';
import 'package:keyviz/data/config.dart';
import 'package:keyviz/providers/config.dart';
import 'package:keyviz/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../data/properties.dart';
import '../widgets/option_menu.dart';
import '../widgets/switch.dart';

class StyleTab extends StatelessWidget {
  const StyleTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigDataProvider configDataProvider =
        Provider.of<ConfigDataProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
      child: Column(
        children: [
          ListItem(
            topRadius: 12,
            children: [
              const Text("Style", style: headingStyle),
              OptionMenu(
                options: keycapStyles,
                selectedOption: styleStringFrom[configData.style],
                onChanged: (String option) {
                  configData.style = styleFrom[option] ?? KeycapStyle.isometric;
                  configDataProvider.style = configData.style;
                },
              ),
            ],
          ),
          ListItem(
            children: [
              const Text("Size", style: headingStyle),
              OptionMenu(
                options: sizeOptions,
                selectedOption: "${configDataProvider.size.toInt()} px",
                onChanged: (String option) {
                  configData.size = double.parse(option.split(' ')[0]);
                  configDataProvider.size = configData.size;
                },
              ),
            ],
          ),
          ListItem(
            children: [
              const Text("Key Color", style: headingStyle),
              ColorMenu(
                options: keycapThemes.keys.toList(),
                selectedOption: configDataProvider.keyColor.name,
                onChanged: (String option) {
                  configDataProvider.keyColor = keycapThemes[option]!;
                  configData.keyColor = keycapThemes[option]!;
                },
              ),
            ],
          ),
          ListItem(
            children: [
              const Text("Modifier Color", style: headingStyle),
              ColorMenu(
                options: keycapThemes.keys.toList(),
                selectedOption: configDataProvider.modifierColor.name,
                onChanged: (String option) {
                  configDataProvider.modifierColor = keycapThemes[option]!;
                  configData.modifierColor = keycapThemes[option]!;
                },
              ),
            ],
          ),
          ListItem(
            bottomMargin: 0,
            bottomRadius: 12,
            children: [
              const Text("Border Color", style: headingStyle),
              OptionMenu(
                isColorOptions: true,
                selectedOption:
                    colorNames[configDataProvider.borderColor.toHex()],
                options: hexcodes.keys.toList(),
                onChanged: (String option) {
                  configData.borderColor = colorFromHex(hexcodes[option]!);
                  configDataProvider.borderColor = configData.borderColor;
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          ListItem(
            topRadius: 12,
            children: [
              const Text("Show Icon", style: headingStyle),
              ToggleButton(
                offLabel: "Display only text",
                onLabel: "Display text with icon",
                enabled: configDataProvider.showIcon,
                onChanged: (bool value) {
                  configDataProvider.showIcon = value;
                  configData.showIcon = value;
                },
              ),
            ],
          ),
          ListItem(
            bottomMargin: 0,
            bottomRadius: 12,
            description:
                "For keys like 1, =, or -, associated symbols will be displayed along with them.",
            children: [
              const Text("Show Symbol", style: headingStyle),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    offLabel: "Display only text",
                    onLabel: "Display symbol with text",
                    enabled: configDataProvider.showSymbol,
                    onChanged: (bool value) {
                      configDataProvider.showSymbol = value;
                      configData.showSymbol = value;
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
