import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';

// base preset of the keycap
enum KeyCapStyle {
  minimal,
  flat,
  elevated,
  isometric;

  @override
  String toString() => name.capitalize();
}

// text capitalization
enum TextCap {
  upper("TT"),
  capitalize("Tt"),
  lower("tt");

  const TextCap(this.symbol);
  final String symbol;

  @override
  String toString() => name.capitalize();
}

// modifier text length
enum ModifierTextLength {
  iconOnly("Icon Only"),
  shortLength("Short Text"),
  fullLength("Full Text");

  const ModifierTextLength(this.label);
  final String label;

  @override
  String toString() => label;
}

// alignment in vertical axis
enum VerticalAlignment {
  top(VuesaxIcons.alignTop),
  center(VuesaxIcons.alignVertically),
  bottom(VuesaxIcons.alignBottom);

  const VerticalAlignment(this.iconName);
  final String iconName;
}

// alignment in horizontal axis
enum HorizontalAlignment {
  left(VuesaxIcons.alignLeft),
  center(VuesaxIcons.alignHorizontally),
  right(VuesaxIcons.alignRight);

  const HorizontalAlignment(this.iconName);
  final String iconName;
}

// keycap animation
enum KeyCapAnimation {
  none,
  fade,
  wham,
  grow,
  slide;

  @override
  String toString() => name.capitalize();
}

// mouse animation type
enum MouseClickAnimation { static, ripple, focus, filled }

// style provider of the keycap visualization
class KeyStyleProvider extends ChangeNotifier {
  // key cap style for the visualization
  KeyCapStyle _preset = KeyCapStyle.elevated;

  // ----- Typography -----
  // literal font size in px/pixels
  double _fontSize = 32;

  // key label text color
  Color _fontColor = Colors.black;

  // key label text color for modifiers
  Color _mFontColor = Colors.white;

  // key label text capitalization
  TextCap _textCap = TextCap.capitalize;

  // modifier key label text style
  ModifierTextLength _modifierTextLength = ModifierTextLength.shortLength;

  // ----- Layout -----
  // vertical alignment of the keycap children
  VerticalAlignment _verticalAlignment = VerticalAlignment.center;

  // horizontal alignment of the keycap children
  HorizontalAlignment _horizontalAlignment = HorizontalAlignment.center;

  // show icons for modifiers and other keys
  bool _showIcon = true;

  // show symbol with numbers, oem and numpad keys
  bool _showSymbol = true;

  // add the "+" separator between keys
  bool _addPlusSeparator = false;

  // ----- Color -----
  // fill type of the containers
  bool _isGradient = false;

  // using different color modifier keys
  bool _differentColorForModifiers = false;

  // primary color to be used on flat keycap container
  // and elevated/isometric keycap's upper container
  Color _primaryColor1 = Colors.white;
  // second color for gradient
  Color _primaryColor2 = Colors.grey;

  // secondary color to be used on
  // elevated/isometric keycap's bottom container
  Color _secondaryColor1 = Colors.black;
  // second color for gradient
  Color _secondaryColor2 = Colors.black;

  // primary color to be used on modifiers keys
  Color _mPrimaryColor1 = Colors.purple;
  // second color for gradient
  Color _mPrimaryColor2 = Colors.deepPurple;

  // secondary color to be used on
  // elevated/isometric keycap's bottom container
  Color _mSecondaryColor1 = Colors.deepPurple;
  // second color for gradient
  Color _mSecondaryColor2 = Colors.deepPurple;

  // ----- Border -----
  // add border to the keycap containers
  bool _borderEnabled = true;

  // border color
  Color _borderColor = Colors.black;

  // border color for modifier keys
  Color _mBorderColor = Colors.deepPurple;

  // border width
  double _borderWidth = 1;

  // border radius value as percentage
  // 0% - sharp corner, 100% - totally circle
  double _cornerSmoothing = 50;

  // ----- Background -----
  // background container enabled
  bool _backgroundEnabled = true;

  // color of the background
  Color _backgroundColor = Colors.white;

  // background color opacity from 0.0 -> 1.0
  double _backgroundOpacity = .75;

  // ----- Appearance -----
  // alignment of the visualization
  Alignment _alignment = Alignment.bottomRight;

  // margin from the edge of the screen in px/pixels
  double _margin = 64;

  // keycap animation type
  KeyCapAnimation _keyCapAnimation = KeyCapAnimation.slide;

  // ----- Mouse -----
  // mouse click animation type
  MouseClickAnimation _clickAnimation = MouseClickAnimation.focus;

  // mouse click border color
  Color _clickColor = Colors.grey[100]!;

  KeyCapStyle get preset => _preset;

  bool get differentColorForModifiers => _differentColorForModifiers;

  double get fontSize => _fontSize;
  Color get fontColor => _fontColor;
  Color get mFontColor => _mFontColor;
  TextCap get textCap => _textCap;
  ModifierTextLength get modifierTextLength => _modifierTextLength;

  VerticalAlignment get verticalAlignment => _verticalAlignment;
  HorizontalAlignment get horizontalAlignment => _horizontalAlignment;
  Alignment get childrenAlignment {
    switch (_verticalAlignment) {
      case VerticalAlignment.top:
        switch (_horizontalAlignment) {
          case HorizontalAlignment.left:
            return Alignment.topLeft;

          case HorizontalAlignment.center:
            return Alignment.topCenter;

          case HorizontalAlignment.right:
            return Alignment.topRight;
        }

      case VerticalAlignment.center:
        switch (_horizontalAlignment) {
          case HorizontalAlignment.left:
            return Alignment.centerLeft;

          case HorizontalAlignment.center:
            return Alignment.center;

          case HorizontalAlignment.right:
            return Alignment.centerRight;
        }

      case VerticalAlignment.bottom:
        switch (_horizontalAlignment) {
          case HorizontalAlignment.left:
            return Alignment.bottomLeft;

          case HorizontalAlignment.center:
            return Alignment.bottomCenter;

          case HorizontalAlignment.right:
            return Alignment.bottomRight;
        }
    }
  }

  bool get showIcon => _showIcon;
  bool get showSymbol => _showSymbol;
  bool get addPlusSeparator => _addPlusSeparator;

  bool get isGradient => _isGradient;
  Color get primaryColor1 => _primaryColor1;
  Color get primaryColor2 => _primaryColor2;
  Color get secondaryColor1 => _secondaryColor1;
  Color get secondaryColor2 => _secondaryColor2;
  Color get mPrimaryColor1 => _mPrimaryColor1;
  Color get mPrimaryColor2 => _mPrimaryColor2;
  Color get mSecondaryColor1 => _mSecondaryColor1;
  Color get mSecondaryColor2 => _mSecondaryColor2;

  bool get borderEnabled => _borderEnabled;
  Color get borderColor => _borderColor;
  Color get mBorderColor => _mBorderColor;
  double get borderWidth => _borderWidth;
  double get cornerSmoothing => _cornerSmoothing;

  bool get backgroundEnabled => _backgroundEnabled;
  Color get backgroundColor => _backgroundColor;
  double get backgroundOpacity => _backgroundOpacity;

  Alignment get alignment => _alignment;
  double get margin => _margin;
  KeyCapAnimation get keyCapAnimation => _keyCapAnimation;

  MouseClickAnimation get clickAnimation => _clickAnimation;
  Color get clickColor => _clickColor;

  set preset(KeyCapStyle value) {
    _preset = value;

    if (_preset == KeyCapStyle.elevated) {
      _isGradient = false;
    }

    notifyListeners();
  }

  set differentColorForModifiers(bool value) {
    _differentColorForModifiers = value;
    notifyListeners();
  }

  set fontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  set fontColor(Color value) {
    _fontColor = value;
    notifyListeners();
  }

  set mFontColor(Color value) {
    _mFontColor = value;
    notifyListeners();
  }

  set textCap(TextCap value) {
    _textCap = value;
    notifyListeners();
  }

  set modifierTextLength(ModifierTextLength value) {
    _modifierTextLength = value;
    notifyListeners();
  }

  set verticalAlignment(VerticalAlignment value) {
    _verticalAlignment = value;
    notifyListeners();
  }

  set horizontalAlignment(HorizontalAlignment value) {
    _horizontalAlignment = value;
    notifyListeners();
  }

  set showIcon(value) {
    _showIcon = value;
    notifyListeners();
  }

  set showSymbol(value) {
    _showSymbol = value;
    notifyListeners();
  }

  set addPlusSeparator(value) {
    _addPlusSeparator = value;
    notifyListeners();
  }

  set isGradient(bool value) {
    _isGradient = value;
    notifyListeners();
  }

  set primaryColor1(Color value) {
    _primaryColor1 = value;
    notifyListeners();
  }

  set primaryColor2(Color value) {
    _primaryColor2 = value;
    notifyListeners();
  }

  set secondaryColor1(Color value) {
    _secondaryColor1 = value;
    notifyListeners();
  }

  set secondaryColor2(Color value) {
    _secondaryColor2 = value;
    notifyListeners();
  }

  set mPrimaryColor1(Color value) {
    _mPrimaryColor1 = value;
    notifyListeners();
  }

  set mPrimaryColor2(Color value) {
    _mPrimaryColor2 = value;
    notifyListeners();
  }

  set mSecondaryColor1(Color value) {
    _mSecondaryColor1 = value;
    notifyListeners();
  }

  set mSecondaryColor2(Color value) {
    _mSecondaryColor2 = value;
    notifyListeners();
  }

  set borderEnabled(bool value) {
    _borderEnabled = value;
    notifyListeners();
  }

  set borderColor(Color value) {
    _borderColor = value;
    notifyListeners();
  }

  set mBorderColor(Color value) {
    _mBorderColor = value;
    notifyListeners();
  }

  set borderWidth(value) {
    _borderWidth = value;
    notifyListeners();
  }

  set cornerSmoothing(value) {
    _cornerSmoothing = value;
    notifyListeners();
  }

  set backgroundEnabled(bool value) {
    _backgroundEnabled = value;
    notifyListeners();
  }

  set backgroundColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }

  set backgroundOpacity(double value) {
    _backgroundOpacity = value;
    notifyListeners();
  }

  set clickAnimation(MouseClickAnimation value) {
    _clickAnimation = value;
    notifyListeners();
  }

  set clickColor(Color value) {
    _clickColor = value;
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

  set keyCapAnimation(KeyCapAnimation value) {
    _keyCapAnimation = value;
    notifyListeners();
  }
}
