import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';

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
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.filterHotkeys,
            builder: (_, filterHotkeys, __) => XSwitch(
              value: filterHotkeys,
              onChange: (bool value) {
                context.keyEvent.filterHotkeys = value;
              },
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.filterHotkeys,
          builder: (_, filterHotkeys, __) => PanelItem(
            asRow: false,
            enabled: filterHotkeys,
            title: "Ignore Keys",
            action: const _IgnoreKeyOptions(),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Show History",
          subtitle: "Filter out letters and only "
              "display hotkeys/keyboard shortcuts",
          action: Selector<KeyEventProvider, VisualizationHistoryMode>(
            selector: (_, keyEvent) => keyEvent.historyMode,
            builder: (context, historyMode, __) {
              return XDropdown<VisualizationHistoryMode>(
                value: historyMode,
                options: VisualizationHistoryMode.values,
                onChanged: (value) {
                  context.keyEvent.historyMode = value;
                },
              );
            },
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
                  // TODO style alert dialog
                  builder: (_) => AlertDialog(
                    title: const Text(
                      "Do you want to revert to default settings?",
                    ),
                    titleTextStyle: context.textTheme.titleLarge,
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          // TODO: revert settings
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

class _IgnoreKeyOptions extends StatelessWidget {
  const _IgnoreKeyOptions();

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
          for (final modifierKey in ModifierKey.values)
            Selector<KeyEventProvider, bool>(
              selector: (_, keyEvent) => keyEvent.ignoreKeys[modifierKey]!,
              builder: (context, ignoring, __) => _KeyOption(
                name: modifierKey.name.capitalize(),
                ignoring: ignoring,
                onTap: () {
                  context.keyEvent.setModifierKeyIgnoring(
                    modifierKey,
                    !ignoring,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _KeyOption extends StatelessWidget {
  const _KeyOption({
    required this.name,
    required this.ignoring,
    required this.onTap,
  });

  final String name;
  final bool ignoring;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = ignoring
        ? context.colorScheme.tertiary.withOpacity(.5)
        : context.colorScheme.secondary;
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
          color: ignoring
              ? context.colorScheme.secondaryContainer
              : context.colorScheme.primaryContainer,
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
