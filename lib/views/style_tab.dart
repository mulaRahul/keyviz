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
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Row(
            children: [
              const Label(text: "Style"),
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
          const Space(),
          Row(
            children: [
              const Label(text: "Size"),
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
          const Space(),
          Row(
            children: [
              const Label(text: "Key Color"),
              ColorMenu(
                options: keyvizThemes.keys.toList(),
                selectedOption: configDataProvider.keyColor.name,
                onChanged: (String option) {
                  configDataProvider.keyColor = keyvizThemes[option]!;
                  configData.keyColor = keyvizThemes[option]!;
                },
              ),
            ],
          ),
          const Space(),
          Row(
            children: [
              const Label(text: "Modifier Color"),
              ColorMenu(
                options: keyvizThemes.keys.toList(),
                selectedOption: configDataProvider.modifierColor.name,
                onChanged: (String option) {
                  configDataProvider.modifierColor = keyvizThemes[option]!;
                  configData.modifierColor = keyvizThemes[option]!;
                },
              ),
            ],
          ),
          const Space(),
          Row(
            children: [
              const Label(text: "Border Color"),
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32),
            height: 2,
            color: grey,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Show Icon"),
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
          const Space(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Show Symbol"),
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
                  const Space(),
                  const SizedBox(
                    width: 296,
                    child: Text(
                      "For keys like 1, =, or -, associated symbols will be displayed along with them.",
                      style: captionStyle,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
