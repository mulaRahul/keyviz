import 'package:flutter/material.dart';
import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

class XSlider extends StatefulWidget {
  const XSlider({
    super.key,
    this.defaultValue,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.suffix,
    this.width = defaultPadding * 10,
  });

  final double min;
  final double max;
  final double width;
  final String? suffix;
  final num? defaultValue;
  final ValueChanged<int> onChanged;

  @override
  State<XSlider> createState() => _XSliderState();
}

class _XSliderState extends State<XSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = (widget.defaultValue ?? widget.min).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: widget.width,
          child: Slider.adaptive(
            value: _value,
            min: widget.min,
            max: widget.max,
            onChanged: _onChanged,
          ),
        ),
        SizedBox(
          width: context.textTheme.labelMedium!.fontSize! * 3.5,
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              text: "${_value.toInt()}",
              style: context.textTheme.labelMedium,
              children: widget.suffix == null
                  ? null
                  : [
                      TextSpan(
                        text: widget.suffix,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  void _onChanged(double v) {
    setState(() => _value = v);
    widget.onChanged(v.toInt());
  }
}
