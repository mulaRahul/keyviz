import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/data/properties.dart';

import '../data/config.dart';

class ToggleButton extends StatefulWidget {
  final bool enabled;
  final String onLabel;
  final String offLabel;
  final Function(bool) onChanged;

  const ToggleButton({
    Key? key,
    this.enabled = false,
    required this.onChanged,
    required this.onLabel,
    required this.offLabel,
  }) : super(key: key);

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool value;

  @override
  void initState() {
    value = widget.enabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value ? widget.onLabel : widget.offLabel,
          style: paragraphStyle,
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            setState(() => value = !value);
            widget.onChanged(value);
          },
          child: AnimatedContainer(
            duration: configData.transitionDuration,
            curve: Curves.easeOutBack,
            height: 32,
            width: 56,
            padding: const EdgeInsets.all(4),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: value ? darkGrey : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: darkGrey, width: 1),
            ),
            child: Container(
              width: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value ? Colors.white : darkGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                value ? "assets/img/tick.svg" : "assets/img/cross.svg",
                color: value ? Colors.black : darkerGrey,
                width: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
