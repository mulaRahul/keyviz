import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

class XTextButton extends StatelessWidget {
  const XTextButton(
    this.text, {
    super.key,
    required this.onTap,
    required this.selected,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding * .6,
        ),
        decoration: BoxDecoration(
          color: selected ? context.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(defaultPadding * .6),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: context.textTheme.labelSmall?.copyWith(
            fontSize: 14,
            color: selected
                ? context.colorScheme.onPrimary
                : context.colorScheme.tertiary,
            // fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
