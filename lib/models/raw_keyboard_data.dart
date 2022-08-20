import 'package:flutter/material.dart' hide KeyEvent;

import '../data/keymaps.dart';
import '../widgets/wrapper.dart';
import '../data/config.dart';

extension StringExtension on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  String last() => substring(length - 1);
}

class RawKeyboardData {
  // * initialization
  final String vkName;

  late final String name;
  late final String? symbol;
  late final String? iconPath;
  bool unknownKey = false;

  RawKeyboardData(this.vkName) {
    const String iconsDir = "assets/symbols";

    // sets the name
    if (isNumber) {
      name = vkName;
      symbol = numbers[vkName];
    } else if (isOEMKey) {
      name = oemKeys[vkName]!;
      symbol = oemKeySymbols[vkName]!;
    } else if (isNumpadKey) {
      if (vkName.startsWith("NUMPAD")) {
        name = vkName.last();
        symbol = numpadKeys[vkName];
      } else {
        name = numpadKeys[vkName]!;
        symbol = null;
      }
    } else if (isLetter) {
      name = vkName;
      symbol = null;
    } else {
      if (allKeys.containsKey(vkName)) {
        name = allKeys[vkName]!;
      } else {
        name = vkName.capitalize().replaceAll(RegExp(r'_'), ' ');
        unknownKey = true;
      }
      symbol = null;
    }

    // ? WithIcon
    if (hasIcon) {
      if (isModifierKey && vkName != "TAB") {
        // dealing with LMENU, RSHIFT
        // and converting to menu, shift
        final iconName = vkName.toLowerCase().substring(1);
        iconPath = "$iconsDir/$iconName.svg";
      } else {
        iconPath = "$iconsDir/${vkName.toLowerCase()}.svg";
      }
    }
  }

  // * setters/getters
  bool get isNumber => numbers.containsKey(vkName);
  bool get isOEMKey => oemKeys.containsKey(vkName);
  bool get isArrowKey => arrowKeys.containsKey(vkName);
  bool get isNavKey => navKeys.containsKey(vkName);
  bool get isNormalKey => normalKeys.containsKey(vkName);
  bool get isModifierKey => modifiers.containsKey(vkName);
  bool get isLockKey => lockKeys.containsKey(vkName);
  bool get isLetter => alphabets.contains(vkName);
  bool get isNumpadKey => numpadKeys.containsKey(vkName);
  bool get isFunctionKey => functionKeys.containsKey(vkName);
  bool get hasSymbol => isNumber || isOEMKey || vkName.startsWith("NUMPAD");
  bool get hasIcon =>
      isNormalKey || isModifierKey || isNavKey || isLockKey || isArrowKey;

  // * methods
  @override
  String toString() => "[ RawKeyboardData ] $vkName: $name($symbol)";

  Animatedkeyviz toWidget({
    Key? key,
    int id = 0,
    bool onlySymbol = false,
    bool skipTransition = false,
  }) {
    final double width = configData.size * getWidthCoefficient();
    if (configData.showIcon && hasIcon) {
      return Animatedkeyviz(
        id: id,
        key: key,
        width: width,
        textAlignment: (isModifierKey && !vkName.endsWith("WIN"))
            ? vkName.startsWith("L") || vkName == "TAB"
                ? Alignment.centerRight
                : Alignment.centerLeft
            : Alignment.center,
        iconPath: iconPath,
        fontSize: configData.size,
        keyName: isModifierKey
            ? vkName.endsWith("MENU")
                ? "alt"
                : vkName.substring(vkName == "TAB" ? 0 : 1).toLowerCase()
            : name.toLowerCase(),
        baseColor: isModifierKey
            ? configData.modifierColor.baseColor
            : configData.keyColor.baseColor,
        fontColor: isModifierKey
            ? configData.modifierColor.fontColor
            : configData.keyColor.fontColor,
        skipTransition: skipTransition,
        onlyIcon: isArrowKey || vkName.endsWith("WIN"),
      );
    } else if (vkName.startsWith("NUMPAD")) {
      return Animatedkeyviz(
        id: id,
        key: key,
        width: width,
        keyName: name,
        fontSize: configData.size,
        skipTransition: skipTransition,
        isNumpad: true,
        symbol: symbol,
        baseColor: isModifierKey
            ? configData.modifierColor.baseColor
            : configData.keyColor.baseColor,
        fontColor: isModifierKey
            ? configData.modifierColor.fontColor
            : configData.keyColor.fontColor,
      );
    } else {
      return Animatedkeyviz(
        id: id,
        key: key,
        width: width,
        keyName: name,
        onlySymbol: onlySymbol,
        fontSize: configData.size,
        skipTransition: skipTransition,
        isNumpad: vkName.startsWith("NUMPAD"),
        symbol: (configData.showSymbol || onlySymbol) ? symbol : null,
        baseColor: isModifierKey
            ? configData.modifierColor.baseColor
            : configData.keyColor.baseColor,
        fontColor: isModifierKey
            ? configData.modifierColor.fontColor
            : configData.keyColor.fontColor,
      );
    }
  }

  double getWidthCoefficient() {
    if (vkName == "SPACE") {
      return 8;
    } else if (vkName.endsWith("MENU")) {
      return 2.5;
    } else if (vkName.endsWith("WIN") || isFunctionKey || isNavKey) {
      return 2.5;
    } else if (isModifierKey || isNormalKey || isLockKey) {
      return 4;
    } else if (isLockKey) {
      return 7;
    } else if (unknownKey) {
      return 2.5 + (vkName.length * 0.64);
    } else {
      return 2.5;
    }
  }
}
