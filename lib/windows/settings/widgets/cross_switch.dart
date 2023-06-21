import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class XSwitch extends StatefulWidget {
  const XSwitch({super.key, this.defaultValue, required this.onChange});

  final bool? defaultValue;
  final ValueChanged<bool>? onChange;

  @override
  State<XSwitch> createState() => _XSwitchState();
}

class _XSwitchState extends State<XSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.defaultValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: defaultPadding * 1.5,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: _value,
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChange?.call(v);
          },
        ),
      ),
    );
  }
}
