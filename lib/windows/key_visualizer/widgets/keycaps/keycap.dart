import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/extensions.dart';
import 'package:keyviz/providers/providers.dart';

// abstract class to be implemented by every key cap class
abstract class KeyCap extends StatelessWidget {
  const KeyCap({super.key, required this.event});

  // key event data
  final KeyEventData event;

  // utility getter key style provider
  KeyStyleProvider keyStyle(BuildContext context) =>
      Provider.of<KeyStyleProvider>(context);

  // primary color
  Color? primaryColor(KeyStyleProvider style) {
    if (style.isGradient) return null;

    return style.differentColorForModifiers && event.isModifier
        ? style.mPrimaryColor1
        : style.primaryColor1;
  }

  // primary gradient
  LinearGradient? primaryGradient(
    KeyStyleProvider style, {
    GradientTransform? transform,
  }) {
    if (!style.isGradient) return null;

    return LinearGradient(
      transform: transform,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: (style.differentColorForModifiers && event.isModifier)
          ? [style.mPrimaryColor1, style.mPrimaryColor2]
          : [style.primaryColor1, style.primaryColor2],
    );
  }

  // secondary color
  Color? secondaryColor(KeyStyleProvider style) {
    if (style.isGradient) return null;

    return style.differentColorForModifiers && event.isModifier
        ? style.mSecondaryColor1
        : style.secondaryColor1;
  }

  // secondary gradient
  LinearGradient? secondaryGradient(
    KeyStyleProvider style, {
    GradientTransform? transform,
  }) {
    if (!style.isGradient) return null;

    return LinearGradient(
      transform: transform,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: (style.differentColorForModifiers && event.isModifier)
          ? [style.mSecondaryColor1, style.mSecondaryColor2]
          : [style.secondaryColor1, style.secondaryColor2],
    );
  }

  // border
  Border? border(KeyStyleProvider style) {
    if (!style.borderEnabled) return null;

    return Border.all(
      color: borderColor(style),
      width: style.borderWidth,
      strokeAlign: BorderSide.strokeAlignOutside,
    );
  }

  // border color
  Color borderColor(KeyStyleProvider style) {
    return style.differentColorForModifiers && event.isModifier
        ? style.mBorderColor
        : style.borderColor;
  }

  // utility getter animation duration
  Duration animationDuration(BuildContext context) =>
      context.keyEvent.animationDuration;
}
