import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyviz/config/config.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon({
    super.key,
    this.color,
    required this.icon,
    this.size = defaultPadding,
  });

  final String icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(
          color ?? context.colorScheme.secondary, BlendMode.srcIn),
    );
  }

  const SvgIcon.chevronDown({
    super.key,
    this.color,
    this.size = defaultPadding / 2,
  }) : icon = VuesaxIcons.chevronDown;

  const SvgIcon.cross({
    super.key,
    this.color,
    this.size = defaultPadding / 2,
  }) : icon = VuesaxIcons.cross;

  const SvgIcon.arrowRight({
    super.key,
    this.color,
    this.size = defaultPadding / 2,
  }) : icon = VuesaxIcons.arrowRight;
}
