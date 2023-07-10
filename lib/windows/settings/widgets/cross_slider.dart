import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class XSlider extends StatelessWidget {
  const XSlider({
    super.key,
    required this.value,
    this.defaultValue,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.suffix,
    this.divisions,
    this.labelWidth,
    this.width = defaultPadding * 10,
  });

  final double value;
  final double min;
  final double max;
  final double width;
  final String? suffix;
  final num? defaultValue;
  final int? divisions;
  final double? labelWidth;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: width,
          child: Slider.adaptive(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: labelWidth ?? context.textTheme.labelMedium!.fontSize! * 3.5,
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              text: "${value.toInt()}",
              style: context.textTheme.labelMedium,
              children: suffix == null
                  ? null
                  : [
                      TextSpan(
                        text: suffix,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
