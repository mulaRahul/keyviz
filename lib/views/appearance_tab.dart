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
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "Alignment",
                      style: headingStyle,
                    ),
                    Text(
                      "Choose the side from the bottom where the keys will be displayed.",
                      style: captionStyle,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              AlignmentPicker(
                margin: configDataProvider.margin,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Margin", topMargin: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: 240,
                    child: const Text(
                      "From the bottom and side of the screen.",
                      style: captionStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Space(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(
                text: "Duration",
                topMargin: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Scale(
                    min: 1,
                    max: 8,
                    suffix: "s",
                    divisions: 7,
                    defaultValue:
                        configData.lingerDuration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      configData.lingerDuration = Duration(
                        seconds: value.toInt(),
                      );
                      configData.transitionDuration = Duration(
                        milliseconds: (200 + (value * 50)).toInt(),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: 240,
                    child: const Text(
                      "For how much time keys will linger on the screen",
                      style: captionStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Label(text: "Animation"),
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
