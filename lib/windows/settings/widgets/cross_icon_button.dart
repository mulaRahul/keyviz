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
    this.iconSize,
  });

  final String icon;
  final double size;
  final double? iconSize;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? context.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(defaultPadding / 2),
        ),
        alignment: Alignment.center,
        child: SvgIcon(
          icon: icon,
          size: iconSize ?? size * .5,
          color: selected
              ? context.colorScheme.onPrimary
              : context.colorScheme.tertiary,
        ),
      ),
    );
  }
}
