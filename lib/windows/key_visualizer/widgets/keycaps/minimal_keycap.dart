import 'package:flutter/material.dart';

import 'package:keyviz/config/extensions.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import 'keycap.dart';

class MinimalKeyCap extends KeyCap {
  const MinimalKeyCap({super.key, required super.event});

  @override
  Widget build(BuildContext context) {
    final style = keyStyle(context);

    final fontColor = style.differentColorForModifiers && event.isModifier
        ? style.mFontColor
        : style.fontColor;

    final textStyle = TextStyle(
      height: 1.2,
      fontFamily: "Inter",
      color: fontColor,
      fontSize: style.fontSize,
    );

    // show icon
    if (event.isModifier &&
        style.modifierTextLength == ModifierTextLength.iconOnly) {
      if (event.glyph == null) {
        return event.icon == null
            ? Text(_label(style), style: textStyle)
            : SvgIcon(
                icon: event.icon!,
                color: fontColor,
                size: style.fontSize,
              );
      } else {
        return Text(event.glyph!, style: textStyle);
      }
    }

    return Text(_label(style), style: textStyle);
  }

  String _label(KeyStyleProvider style) {
    final value = style.modifierTextLength == ModifierTextLength.shortLength
        ? event.shortLabel ?? event.label
        : event.label;

    switch (style.textCap) {
      case TextCap.lower:
        return value.toLowerCase();

      case TextCap.capitalize:
        return value.capitalize();

      case TextCap.upper:
        return value.toUpperCase();
    }
  }
}
