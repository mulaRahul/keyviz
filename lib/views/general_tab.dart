import 'package:flutter/material.dart';

import '../data/config.dart';
import '../data/properties.dart';
import '../widgets/switch.dart';
import '../widgets/utils.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Hotkey Filter"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    enabled: configData.filterHotkeys,
                    onLabel: "Display only hotkeys",
                    offLabel: "Display all keys",
                    onChanged: (bool value) => configData.filterHotkeys = value,
                  ),
                  const Space(),
                  const SizedBox(
                    width: 290,
                    child: Text(
                      "Only display shortcuts like Ctrl + A, Alt + K, etc. Though key-presses like Shift + A, Shift + 1, etc. will be ignored.",
                      style: captionStyle,
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Shift Symbols"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    enabled: configData.shiftOEM,
                    onLabel: "Display symbol",
                    offLabel: "Display original",
                    onChanged: (bool value) => configData.shiftOEM = value,
                  ),
                  const Space(),
                  const SizedBox(
                    width: 296,
                    child: Text(
                      "Show symbol like '#' when pressed Shift + 3. Doesn't work if Hotkey Filter is on.",
                      style: captionStyle,
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Label(text: "Replace new key"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    enabled: configData.replaceNew,
                    onLabel: "Replace",
                    offLabel: "Append",
                    onChanged: (bool value) => configData.replaceNew = value,
                  ),
                  const Space(),
                  const SizedBox(
                    width: 296,
                    child: Text(
                      "Replace the previously displayed keys (if any is still lingering) with the new pressed key/s.",
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
