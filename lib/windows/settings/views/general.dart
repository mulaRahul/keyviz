import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import '../widgets/widgets.dart';

class GeneralTabView extends StatelessWidget {
  const GeneralTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: "Hotkey Filter",
          subtitle: "Filter out letters and only "
              "display hotkeys/keyboard shortcuts",
          action: XSwitch(
            onChange: (bool value) {},
          ),
        ),
        const Divider(),
        const PanelItem(
          asRow: false,
          enabled: false,
          title: "Ignore Keys",
          action: _IgnoreKeyOptions(),
        ),
        const Divider(),
        PanelItem(
          title: "Shift Symbol",
          subtitle: "Filter out letters and only "
              "display hotkeys/keyboard shortcuts",
          action: XSwitch(
            onChange: (bool value) {},
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Show History",
          subtitle: "Filter out letters and only "
              "display hotkeys/keyboard shortcuts",
          action: XDropdown(
            option: "None",
            options: ["None", "Vertically", "Horizontally"],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: defaultPadding),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                      "Do you want to revert to default settings?",
                    ),
                    titleTextStyle: context.textTheme.titleLarge,
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          // revert settings
                        },
                        child: const Text("Revert"),
                      ),
                      OutlinedButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text("Cancel"),
                      ),
                    ],
                    elevation: 0,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(.2),
                textStyle: context.textTheme.labelSmall,
                padding: const EdgeInsets.all(defaultPadding * .5),
                minimumSize: const Size(defaultPadding, defaultPadding * 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultPadding * .6),
                ),
              ),
              child: const Text("Revert to defaults"),
            ),
          ),
        ),
      ],
    );
  }
}

class _IgnoreKeyOptions extends StatefulWidget {
  const _IgnoreKeyOptions();

  @override
  State<_IgnoreKeyOptions> createState() => _IgnoreKeyOptionsState();
}

class _IgnoreKeyOptionsState extends State<_IgnoreKeyOptions> {
  final _modifiers = <String, bool>{
    "Ctrl": true,
    "Alt": true,
    "Shift": false,
    "Caps Lock": true,
    "Scroll Lock": true,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding * .5),
      decoration: BoxDecoration(
        color: context.colorScheme.background,
        borderRadius: BorderRadius.circular(defaultPadding * .5),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        children: [
          for (final name in _modifiers.keys)
            _KeyOption(
              name: name,
              isSelected: _modifiers[name]!,
              onTap: () =>
                  setState(() => _modifiers[name] = !_modifiers[name]!),
            ),
        ],
      ),
    );
  }
}

class _KeyOption extends StatelessWidget {
  const _KeyOption({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? context.colorScheme.secondary
        : context.colorScheme.tertiary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: defaultPadding * 1.5,
        margin: const EdgeInsets.only(
          right: defaultPadding * .5,
          bottom: defaultPadding * .2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding * .5),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primaryContainer
              : context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(defaultPadding * .4),
          border: Border.all(color: bgColor),
          boxShadow: [
            BoxShadow(
              color: bgColor,
              offset: const Offset(0, defaultPadding * .2),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: TextStyle(
            color: bgColor,
            fontSize: defaultPadding * .75,
          ),
        ),
      ),
    );
  }
}
