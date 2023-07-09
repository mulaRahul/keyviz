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
          subtitle: "Show clicks when a mouse button is pressed",
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
              action: Selector<KeyStyleProvider, MouseClickAnimation>(
                selector: (_, keyStyle) => keyStyle.clickAnimation,
                builder: (context, value, _) {
                  return XDropdown<MouseClickAnimation>(
                    value: value,
                    options: MouseClickAnimation.values,
                    onChanged: (value) {
                      context.keyStyle.clickAnimation = value;
                    },
                  );
                },
              ),
            );
          },
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (context, enabled, _) => PanelItem(
            enabled: enabled,
            title: "Click Color",
            subtitle: "Color of the highlight around your mouse cursor",
            actionFlex: 2,
            action: RawColorInputSubPanelItem(
              label: "Mouse Click Color",
              defaultValue: context.keyStyle.clickColor,
              onChanged: (color) => context.keyStyle.clickColor = color,
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (_, enabled, __) => PanelItem(
            enabled: enabled,
            title: "Keep Highlight",
            subtitle: "Show the highlight around mouse cursor all time",
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
        ),
        const Divider(),
        PanelItem(
          title: "Show Mouse Events",
          subtitle: "Visualize mouse events like click, drag, etc. "
              "along with key events",
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
