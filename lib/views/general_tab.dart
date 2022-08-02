import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/config.dart';
import '../data/properties.dart';
import '../providers/config.dart';
import '../widgets/switch.dart';
import '../widgets/utils.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListItem(
            topRadius: 12,
            description:
                "Only display shortcuts like Ctrl + A, Alt + K, etc. Though key-presses like Shift + A, Shift + 1, etc. will be ignored.",
            children: [
              const Text("Hotkey Filter", style: headingStyle),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    enabled: configData.filterHotkeys,
                    onLabel: "Display only hotkeys",
                    offLabel: "Display all keys",
                    onChanged: (bool value) => configData.filterHotkeys = value,
                  ),
                ],
              ),
            ],
          ),
          ListItem(
            description:
                "Show symbol like '#' when pressed Shift + 3. Doesn't work if Hotkey Filter is on.",
            children: [
              const Text("Shift Symbols", style: headingStyle),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToggleButton(
                    enabled: configData.shiftOEM,
                    onLabel: "Display symbol",
                    offLabel: "Display original",
                    onChanged: (bool value) => configData.shiftOEM = value,
                  ),
                ],
              ),
            ],
          ),
          ListItem(
            bottomMargin: 0,
            bottomRadius: 12,
            description:
                "Replace the previously displayed keys (if any is still lingering) with the new pressed key/s.",
            children: [
              const Text("Replace new key", style: headingStyle),
              ToggleButton(
                enabled: configData.replaceNew,
                onLabel: "Replace",
                offLabel: "Append",
                onChanged: (bool value) => configData.replaceNew = value,
              ),
            ],
          ),
          const SizedBox(height: 32),
          ListItem(
            topRadius: 12,
            bottomMargin: 0,
            bottomRadius: 12,
            children: [
              const Text("Revert to Defaults", style: headingStyle),
              TextButton(
                onPressed: () async {
                  configData.revertToDefaults();
                  Provider.of<ConfigDataProvider>(context, listen: false)
                      .revert();
                },
                child: Text("Revert",
                    style: paragraphStyle.copyWith(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
