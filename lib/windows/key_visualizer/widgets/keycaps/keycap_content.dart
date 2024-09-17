import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyviz/config/extensions.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/providers.dart';
import 'package:keyviz/windows/shared/shared.dart';

class KeyCapContent extends StatelessWidget {
  const KeyCapContent(this.event, {super.key});

  final KeyEventData event;

  @override
  Widget build(BuildContext context) {
    final style = Provider.of<KeyStyleProvider>(context);

    final icon = style.showIcon ? event.icon : null;
    final isNumpad = icon == null ? event.isNumpad : false;
    final symbol =
        isNumpad || (style.showSymbol && icon == null) ? event.symbol : null;

    final fontColor = style.differentColorForModifiers && event.isModifier
        ? style.mFontColor
        : style.fontColor;

    final textStyle = TextStyle(
      height: 1.2,
      fontFamily: "Inter",
      color: fontColor,
      fontSize: style.fontSize,
    );
    // spacebar
    if (event.isSpacebar) {
      if (icon != null) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: style.fontSize * 2),
          child: SizedBox.square(
            dimension: style.fontSize * .8,
            child: SvgIcon(
              icon: icon,
              color: fontColor,
              size: style.fontSize * .8,
            ),
          ),
        );
      }
      String spaceLabel = 'space';

      if (style.textCap == TextCap.capitalize) {
        spaceLabel = spaceLabel.capitalize();
      } else if (style.textCap == TextCap.upper) {
        spaceLabel = spaceLabel.toUpperCase();
      }
      return Text("    $spaceLabel    ", style: textStyle);
    }
    // has icon
    else if (icon != null) {
      return (style.modifierTextLength == ModifierTextLength.iconOnly) ||
              event.isArrow
          ? SvgIcon(
              icon: icon,
              color: fontColor,
              size: style.fontSize * .8,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: _crossAxisAlignment(style),
              children: [
                SvgIcon(
                  icon: icon,
                  size: style.fontSize * .45,
                  color: fontColor,
                ),
                Text(
                  _label(style),
                  style: textStyle.copyWith(fontSize: style.fontSize * .5),
                ),
              ],
            );
    }
    // numpad key
    else if (isNumpad) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: _crossAxisAlignment(style),
        children: [
          Text(
            event.label,
            style: textStyle.copyWith(fontSize: style.fontSize * .5),
          ),
          if (symbol != null)
            FittedBox(
              child: Text(
                symbol,
                style: textStyle.copyWith(fontSize: style.fontSize * .5),
              ),
            ),
        ],
      );
    }
    // has symbol
    else if (symbol != null) {
      return RichText(
        textAlign: _textAlign(style),
        text: TextSpan(
          style: textStyle.copyWith(fontSize: style.fontSize * .6),
          children: [
            TextSpan(
              text: event.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: "\n"),
            TextSpan(text: symbol),
          ],
        ),
      );
    }

    return Text(_label(style), style: textStyle);
  }

  String _label(KeyStyleProvider style) {
    if (event.isSpacebar) return event.label;

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

  CrossAxisAlignment _crossAxisAlignment(KeyStyleProvider style) {
    if (event.isModifier) {
      bool isLeftSide =
          event.rawEvent.logicalKey == LogicalKeyboardKey.controlLeft ||
              event.rawEvent.logicalKey == LogicalKeyboardKey.metaLeft ||
              event.rawEvent.logicalKey == LogicalKeyboardKey.altLeft ||
              event.rawEvent.logicalKey == LogicalKeyboardKey.shiftLeft;

      return isLeftSide ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    }

    switch (style.horizontalAlignment) {
      case HorizontalAlignment.right:
        return CrossAxisAlignment.end;
      case HorizontalAlignment.center:
        return CrossAxisAlignment.center;
      case HorizontalAlignment.left:
        return CrossAxisAlignment.start;
    }
  }

  TextAlign _textAlign(KeyStyleProvider style) {
    switch (style.horizontalAlignment) {
      case HorizontalAlignment.right:
        return TextAlign.end;
      case HorizontalAlignment.center:
        return TextAlign.center;
      case HorizontalAlignment.left:
        return TextAlign.start;
    }
  }
}
