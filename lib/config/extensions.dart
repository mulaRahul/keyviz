import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';

extension Cap on String {
  static const _space = " ";

  String capitalize() {
    if (contains(_space)) {
      final words = [];
      for (final word in split(_space)) {
        words.add(_capitalize(word));
      }
      return words.join(_space);
    } else {
      return _capitalize(this);
    }
  }

  String _capitalize(String txt) {
    return "${txt[0].toUpperCase()}${txt.substring(1).toLowerCase()}";
  }
}

extension Ease on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  KeyEventProvider get keyEvent => read<KeyEventProvider>();
  KeyStyleProvider get keyStyle => read<KeyStyleProvider>();
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      // '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

extension HexCode on HSVColor {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) {
    final rgb = toColor();

    return '${leadingHashSign ? '#' : ''}'
        // '${alpha.toRadixString(16).padLeft(2, '0')}'
        '${rgb.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${rgb.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${rgb.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
}
