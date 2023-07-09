import 'package:flutter/material.dart';
import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

class XIconButton extends StatelessWidget {
  const XIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.selected,
    this.size = 40.0,
    this.tooltip,
    this.iconSize,
  });

  final String icon;
  final double size;
  final double? iconSize;
  final bool selected;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(defaultPadding * .4),
      ),
      tooltip: tooltip,
      icon: SvgIcon(
        icon: icon,
        size: size * .6,
        color: selected
            ? context.colorScheme.primary
            : context.colorScheme.outline,
      ),
    );
  }
}
