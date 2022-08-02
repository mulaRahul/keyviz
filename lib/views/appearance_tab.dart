import 'package:flutter/material.dart';
import 'package:keyviz/data/config.dart';
import 'package:keyviz/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../data/properties.dart';
import '../providers/config.dart';
import '../widgets/alignment_picker.dart';
import '../widgets/option_menu.dart';
import '../widgets/scale.dart';

class AppearanceTab extends StatelessWidget {
  const AppearanceTab({
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
            alignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 262,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Alignment",
                      style: headingStyle,
                    ),
                    Space(),
                    Text(
                      "Choose the side from the bottom where the keys will be displayed.",
                      style: captionStyle,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              AlignmentPicker(
                margin: configDataProvider.margin,
              ),
            ],
          ),
          ListItem(
            description: "From the bottom and side of the screen.",
            children: [
              const Text("Margin", style: headingStyle),
              Scale(
                min: 16,
                max: 128,
                suffix: "px",
                divisions: 7,
                defaultValue: configDataProvider.margin,
                onChanged: (double value) {
                  configDataProvider.margin = value;
                  configData.margin = value;
                },
              ),
            ],
          ),
          ListItem(
            description: "For how much time keys will linger on the screen",
            children: [
              const Text("Duration", style: headingStyle),
              Scale(
                min: 1,
                max: 8,
                suffix: "s",
                divisions: 7,
                defaultValue: configData.lingerDuration.inSeconds.toDouble(),
                onChanged: (double value) {
                  configData.lingerDuration = Duration(
                    seconds: value.toInt(),
                  );
                  configData.transitionDuration = Duration(
                    milliseconds: (200 + (value * 50)).toInt(),
                  );
                },
              ),
            ],
          ),
          ListItem(
            bottomMargin: 0,
            bottomRadius: 12,
            children: [
              const Text("Animation", style: headingStyle),
              OptionMenu(
                options: const ["none", "fade", "slide", "grow"],
                selectedOption: animationTypeStringFrom[configData.animation],
                onChanged: (String option) {
                  switch (option) {
                    case "none":
                      configData.animation = AnimationType.none;
                      break;

                    case "fade":
                      configData.animation = AnimationType.fade;
                      break;

                    case "slide":
                      configData.animation = AnimationType.slide;
                      break;

                    case "grow":
                      configData.animation = AnimationType.grow;
                      break;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
