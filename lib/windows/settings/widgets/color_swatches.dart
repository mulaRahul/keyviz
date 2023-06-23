import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:keyviz/config/config.dart';

class ColorSwatches extends StatefulWidget {
  const ColorSwatches({
    super.key,
    required this.show,
    required this.onSelected,
  });

  final bool show;
  final void Function(Color color) onSelected;

  @override
  State<ColorSwatches> createState() => _ColorSwatchesState();
}

class _ColorSwatchesState extends State<ColorSwatches> {
  double get _target => widget.show ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: defaultPadding * 16.65,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: defaultBorderRadius,
        border: Border.all(color: context.colorScheme.outline),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, defaultPadding * 0.5),
            color: Colors.black12,
            blurRadius: defaultPadding * 2,
          )
        ],
      ),
      child: Wrap(
        spacing: defaultPadding * .5,
        runSpacing: defaultPadding * .5,
        children: [
          for (final color in [
            Colors.white,
            const Color(0xfff2f2f2),
            const Color(0xffcccccc),
            const Color(0xff545454),
            const Color(0xff1a1a1a),
            Colors.black,
            ...Colors.primaries,
          ])
            GestureDetector(
              onTap: () => widget.onSelected(color),
              child: SizedBox.square(
                dimension: defaultPadding * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    border: color == context.colorScheme.primaryContainer
                        ? Border.all(color: context.colorScheme.outline)
                        : null,
                    borderRadius: BorderRadius.circular(defaultPadding * .5),
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate(target: _target)
        .effect(
          duration: transitionDuration,
          curve: Curves.easeInOutCubicEmphasized,
        )
        .scaleXY(begin: .6, end: 1)
        .fade();
  }
}
