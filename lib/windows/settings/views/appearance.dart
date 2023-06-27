import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../widgets/widgets.dart';

class AppearanceTabView extends StatelessWidget {
  const AppearanceTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: "Alignment",
          subtitle: "Position of the key visualization on the screen",
          action: Selector<KeyStyleProvider, Alignment>(
            selector: (_, keyStyle) => keyStyle.alignment,
            builder: (context, alignment, _) => _AlignmentPicker(
              selected: alignment,
              onChanged: (value) {
                context.keyStyle.alignment = value;
              },
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Margin",
          subtitle:
              "The spacing betweeen the visualization and the edge of the monitor",
          actionFlex: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          action: Selector<KeyStyleProvider, double>(
            selector: (_, keyStyle) => keyStyle.margin,
            builder: (context, margin, _) => XSlider(
              max: 128,
              suffix: "px",
              value: margin,
              onChanged: (value) => context.keyStyle.margin = value,
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Duration",
          subtitle: "Amount of time the keys linger before disappearing",
          actionFlex: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          action: Selector<KeyEventProvider, int>(
            selector: (_, keyEvent) => keyEvent.lingerDurationInSeconds,
            builder: (context, duration, _) => XSlider(
              max: 16,
              suffix: "s",
              value: duration.toDouble(),
              onChanged: (value) {
                context.keyEvent.lingerDurationInSeconds = value.toInt();
              },
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Key Animation",
          subtitle: "The animation used by key cap",
          action: Selector<KeyEventProvider, KeyCapAnimation>(
            selector: (_, keyEvent) => keyEvent.keyCapAnimation,
            builder: (context, animation, _) => XDropdown(
              value: animation,
              options: KeyCapAnimation.values,
              onChanged: (value) => context.keyEvent.keyCapAnimation = value,
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: "Animation Speed",
          subtitle: "Speed of the animations",
          actionFlex: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          action: Selector<KeyEventProvider, int>(
            selector: (_, keyEvent) => keyEvent.animationSpeed,
            builder: (context, duration, _) => XSlider(
              max: 1200,
              suffix: "ms",
              divisions: 24,
              value: duration.toDouble(),
              labelWidth: defaultPadding * 4.5,
              onChanged: (value) {
                context.keyEvent.animationSpeed = value.toInt();
              },
            ),
          ),
        ),
        const ColumnGap(),
      ],
    );
  }
}

class _AlignmentPicker extends StatelessWidget {
  const _AlignmentPicker({required this.selected, required this.onChanged});

  final Alignment selected;
  final ValueChanged<Alignment> onChanged;

  static const _radius = [
    /*0*/ BorderRadius.only(
      topLeft: Radius.circular(defaultPadding * .75),
    ),
    /*1*/ BorderRadius.zero,
    /*2*/ BorderRadius.only(
      topRight: Radius.circular(defaultPadding * .75),
    ),
    /*3*/ BorderRadius.zero,
    /*4*/ BorderRadius.zero,
    /*5*/ BorderRadius.zero,
    /*6*/ BorderRadius.only(
      bottomLeft: Radius.circular(defaultPadding * .75),
    ),
    /*7*/ BorderRadius.zero,
    /*8*/ BorderRadius.only(
      bottomRight: Radius.circular(defaultPadding * .75),
    ),
  ];

  static const _angle = <double>[
    /*0*/ 225,
    /*1*/ 270,
    /*2*/ 315,
    /*3*/ 180,
    /*4*/ 0,
    /*5*/ 0,
    /*6*/ 135,
    /*7*/ 90,
    /*8*/ 45,
  ];

  static const _labels = [
    /*0*/ "Top Left",
    /*1*/ "Top Center",
    /*2*/ "Top Right",
    /*3*/ "Center Left",
    /*4*/ "Center",
    /*5*/ "Center Right",
    /*6*/ "Bottom Left",
    /*7*/ "Bottom Center",
    /*8*/ "Bottom Right",
  ];

  static const _values = [
    /*0*/ Alignment.topLeft,
    /*1*/ Alignment.topCenter,
    /*2*/ Alignment.topRight,
    /*3*/ Alignment.centerLeft,
    /*4*/ Alignment.center,
    /*5*/ Alignment.centerRight,
    /*6*/ Alignment.bottomLeft,
    /*7*/ Alignment.bottomCenter,
    /*8*/ Alignment.bottomRight,
  ];

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int i = 0; i < 9; i++) {
      if (i == 4) {
        // placeholder
        children.add(const SizedBox());
      } else {
        final isSelected = _values[i] == selected;
        children.add(
          IconButton(
            onPressed: () => onChanged(_values[i]),
            style: IconButton.styleFrom(
              backgroundColor: isSelected ? context.colorScheme.primary : null,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: context.colorScheme.outline,
                ),
                borderRadius: _radius[i],
              ),
            ),
            icon: Transform.rotate(
              angle: radians(_angle[i]),
              child: isSelected
                  ? SvgIcon.arrowRight(
                      color: context.colorScheme.onPrimary,
                      size: defaultPadding,
                    )
                  : const SvgIcon.arrowRight(
                      size: defaultPadding,
                    ),
            ),
            tooltip: _labels[i],
          ),
        );
      }
    }

    return SizedBox.square(
      dimension: defaultPadding * 6,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        children: children,
      ),
    );
  }
}
