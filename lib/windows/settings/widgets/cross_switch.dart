import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

class XSwitch extends StatelessWidget {
  const XSwitch({
    super.key,
    required this.value,
    required this.onChange,
  });

  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: defaultPadding * 1.5,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChange,
        ),
      ),
    );
  }
}
