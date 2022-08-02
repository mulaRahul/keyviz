import 'package:flutter/material.dart';
import 'package:keyviz/data/config.dart';

import '../data/properties.dart';

class ConfigDataProvider extends ChangeNotifier {
  late KeycapStyle _style;
  late KeycapTheme _keyColor;
  late KeycapTheme _modifierColor;
  late double _size;
  late bool _showIcon;
  late bool _showSymbol;
  late Alignment _alignment;
  late double _margin;
  late Color _borderColor;

  ConfigDataProvider() {
    _init();
  }

  void _init() {
    _style = configData.style;
    _keyColor = configData.keyColor;
    _modifierColor = configData.modifierColor;
    _size = configData.size;
    _showIcon = configData.showIcon;
    _showSymbol = configData.showSymbol;
    _alignment = configData.alignment;
    _margin = configData.margin;
    _borderColor = configData.borderColor;
  }

  void revert() {
    _init();
    notifyListeners();
  }

  // getters
  KeycapStyle get style => _style;
  KeycapTheme get keyColor => _keyColor;
  KeycapTheme get modifierColor => _modifierColor;
  double get size => _size;
  bool get showIcon => _showIcon;
  bool get showSymbol => _showSymbol;
  Alignment get alignment => _alignment;
  double get margin => _margin;
  Color get borderColor => _borderColor;

  //setters
  set style(KeycapStyle value) {
    _style = value;
    notifyListeners();
  }

  set keyColor(KeycapTheme value) {
    _keyColor = value;
    notifyListeners();
  }

  set modifierColor(KeycapTheme value) {
    _modifierColor = value;
    notifyListeners();
  }

  set size(double value) {
    _size = value;
    notifyListeners();
  }

  set showIcon(bool value) {
    _showIcon = value;
    notifyListeners();
  }

  set showSymbol(bool value) {
    _showSymbol = value;
    notifyListeners();
  }

  set alignment(Alignment value) {
    _alignment = value;
    notifyListeners();
  }

  set margin(double value) {
    _margin = value;
    notifyListeners();
  }

  set borderColor(Color value) {
    _borderColor = value;
    notifyListeners();
  }
}
