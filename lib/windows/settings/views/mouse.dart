import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';

import '../widgets/widgets.dart';

class MouseTabView extends StatelessWidget {
  const MouseTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: "Visualize Clicks",
          subtitle: "Show click on mouse down with custom animations",
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showMouseClicks,
            builder: (context, showMouseClicks, _) => XSwitch(
              value: showMouseClicks,
              onChange: (value) {
                context.keyEvent.showMouseClicks = value;
              },
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showMouseClicks,
            builder: (context, enabled, _) {
              return PanelItem(
                enabled: enabled,
                title: "Click Animation",
                asRow: false,
                action: Row(
                  children: [
                    for (final value in MouseClickAnimation.values)
                      Selector<KeyStyleProvider, MouseClickAnimation>(
                        selector: (_, keyStyle) => keyStyle.clickAnimation,
                        builder: (context, clickAnimation, _) {
                          return _ClickAnimationOption(
                            value: value,
                            selected: clickAnimation == value,
                            onTap: () =>
                                context.keyStyle.clickAnimation = value,
                          );
                        },
                        shouldRebuild: (previous, next) {
                          // value selected or unselected
                          return previous == value || next == value;
                        },
                      ),
                  ],
                ),
              );
            }),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (context, enabled, _) => PanelItem(
            enabled: enabled,
            title: "Click Color",
            subtitle: "Show click on mouse down with custom animations",
            actionFlex: 2,
            action: RawColorInputSubPanelItem(
              label: "Mouse Click Color",
              defaultValue: context.keyStyle.clickColor,
              onChanged: (color) => context.keyStyle.clickColor = color,
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Highlight Cursor",
          subtitle: "Keep the highlight on the cursor",
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.highlightCursor,
            builder: (context, highlightCursor, _) => XSwitch(
              value: highlightCursor,
              onChange: (value) {
                context.keyEvent.highlightCursor = value;
              },
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Show Mouse Events",
          subtitle: "Visualize mouse events like click, drag with key events",
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showMouseEvents,
            builder: (context, showMouseEvents, _) => XSwitch(
              value: showMouseEvents,
              onChange: (value) {
                context.keyEvent.showMouseEvents = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ClickAnimationOption extends StatelessWidget {
  const _ClickAnimationOption({
    required this.selected,
    required this.value,
    required this.onTap,
  });

  final bool selected;
  final MouseClickAnimation value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: transitionDuration,
        curve: Curves.easeInOut,
        width: defaultPadding * 6,
        height: defaultPadding * 5,
        margin: const EdgeInsets.only(right: defaultPadding),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          border: selected
              ? Border.all(
                  width: 2,
                  color: context.colorScheme.secondary,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : Border.all(
                  width: 1,
                  color: context.colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
          borderRadius: BorderRadius.circular(
            selected ? defaultPadding : defaultPadding * .5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(value.name),
      ),
    );
  }
}
