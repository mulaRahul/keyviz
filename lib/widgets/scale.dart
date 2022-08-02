import 'package:flutter/material.dart';

import '../data/properties.dart';

class Scale extends StatefulWidget {
  final String suffix;
  final double min;
  final double max;
  final int divisions;
  final double defaultValue;
  final Function(double) onChanged;

  const Scale({
    Key? key,
    required this.suffix,
    required this.min,
    required this.max,
    required this.divisions,
    required this.defaultValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<Scale> createState() => _ScaleState();
}

class _ScaleState extends State<Scale> {
  late double _value;

  @override
  void initState() {
    _value = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 256,
      child: Slider(
        value: _value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        inactiveColor: darkerGrey,
        activeColor: grey,
        label: "${_value.toInt()}${widget.suffix}",
        onChanged: (value) => setState(() => _value = value),
        onChangeEnd: (value) => widget.onChanged(_value),
      ),
    );
  }
}
