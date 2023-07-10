import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/domain/vault/vault.dart';

// base preset of the keycap
enum KeyCapStyle {
  minimal,
  flat,
  elevated,
  plastic,
  mechanical;
  // retro;

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

// mouse animation type
enum MouseClickAnimation {
  static,
  focus,
  filled;

  @override
  String toString() => name.capitalize();
}

// style provider of the keycap visualization
class KeyStyleProvider extends ChangeNotifier {
  KeyStyleProvider() {
    _updateFromJson();
  }

  // key cap style for the visualization
  KeyCapStyle _keyCapStyle = KeyCapStyle.elevated;

  // ----- Typography -----
  // literal font size in px/pixels
  double _fontSize = 24;

  // key label text color
  Color _fontColor = Colors.black;

  // key label text color for modifiers
  Color _mFontColor = Colors.white;

  // key label text capitalization
  TextCap _textCap = TextCap.capitalize;

  // modifier key label text style
  ModifierTextLength _modifierTextLength = ModifierTextLength.fullLength;

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

  // color for the above separator
  Color _separatorColor = Colors.black;

  // ----- Color -----
  // fill type of the containers
  bool _isGradient = false;

  // using different color modifier keys
  bool _differentColorForModifiers = false;

  // primary color to be used on flat keycap container
  // and elevated/isometric keycap's upper container
  Color _primaryColor1 = Colors.white;
  // second color for gradient
  Color _primaryColor2 = Colors.white;

  // secondary color to be used on
  // elevated/isometric keycap's bottom container
  Color _secondaryColor1 = Colors.black;
  // second color for gradient
  Color _secondaryColor2 = Colors.grey[600]!;

  // primary color to be used on modifiers keys
  Color _mPrimaryColor1 = const Color(0xffb8b8b8);
  // second color for gradient
  Color _mPrimaryColor2 = Color.fromRGBO(84, 84, 84, 1);

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
  Color _mBorderColor = const Color(0xff1a1a1a);

  // border width
  double _borderWidth = 1;

  // border radius value as percentage
  // 0 - sharp corner, 1.0 - totally circle
  double _cornerSmoothing = .4;

  // ----- Background -----
  // background container enabled
  bool _backgroundEnabled = true;

  // color of the background
  Color _backgroundColor = Colors.white;

  // background color opacity from 0.0 -> 1.0
  double _backgroundOpacity = 1.0;

  // ----- Appearance -----
  // alignment of the visualization
  Alignment _alignment = Alignment.bottomRight;

  // margin from the edge of the screen in px/pixels
  double _margin = 128;

  // ----- Mouse -----
  // mouse click animation type
  MouseClickAnimation _clickAnimation = MouseClickAnimation.focus;

  // mouse click border color
  Color _clickColor = Colors.grey[100]!;

  KeyCapStyle get keyCapStyle => _keyCapStyle;

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
  Widget? get separator {
    return _addPlusSeparator
        ? Text(
            "+",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSize,
              color: _separatorColor,
            ),
          )
        : null;
  }

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
  Color get backgroundColorWithOpacity =>
      _backgroundColor.withOpacity(_backgroundOpacity);
  double get backgroundOpacity => _backgroundOpacity;
  double get backgroundSpacing => _fontSize * .5;

  Alignment get alignment => _alignment;
  double get margin => _margin;

  MouseClickAnimation get clickAnimation => _clickAnimation;
  double get cursorHighlightSize => _fontSize * 4;
  Color get clickColor => _clickColor;

  // key cap properties
  Size get minContainerSize {
    switch (_keyCapStyle) {
      case KeyCapStyle.flat:
      case KeyCapStyle.elevated:
      case KeyCapStyle.plastic:
        return Size.square(_fontSize * 2.25);

      case KeyCapStyle.mechanical:
        return Size(_fontSize * 1.875, _fontSize * 2.35);

      // case KeyCapStyle.retro:
      //   return Size(_fontSize * 1.75, _fontSize * 2.0625);

      default:
        return Size.zero;
    }
  }

  Size get minOuterContainerSize {
    switch (_keyCapStyle) {
      case KeyCapStyle.elevated:
        return Size(_fontSize * 2.25, _fontSize * 2.5);

      case KeyCapStyle.plastic:
      // case KeyCapStyle.retro:
      case KeyCapStyle.mechanical:
        return Size.square(_fontSize * 2.75);

      default:
        return Size.zero;
    }
  }

  double get keycapHeight {
    switch (_keyCapStyle) {
      case KeyCapStyle.minimal:
        return _fontSize * 1.2; // line height

      case KeyCapStyle.flat:
        return _fontSize * 2.25;

      case KeyCapStyle.elevated:
        return _fontSize * 2.5;

      // case KeyCapStyle.retro:
      case KeyCapStyle.plastic:
      case KeyCapStyle.mechanical:
        return _fontSize * 2.75;
    }
  }

  EdgeInsets get contentPadding {
    switch (_keyCapStyle) {
      case KeyCapStyle.flat:
      case KeyCapStyle.elevated:
        return EdgeInsets.symmetric(
          horizontal: _fontSize *
              (_cornerSmoothing < .75 ? .5 : (.5 + (_cornerSmoothing - .75))),
          vertical: _fontSize * .375,
        );

      case KeyCapStyle.plastic:
        return EdgeInsets.symmetric(
          horizontal: _fontSize *
              (_cornerSmoothing < .75 ? .5 : (.5 + (_cornerSmoothing - .75))),
        ).copyWith(top: _fontSize * .25, bottom: _fontSize * .5);

      // case KeyCapStyle.retro:
      case KeyCapStyle.mechanical:
        return EdgeInsets.symmetric(
          horizontal: _fontSize * .5,
        ).copyWith(top: _fontSize * .375, bottom: _fontSize * .5);

      default:
        return EdgeInsets.zero;
    }
  }

  EdgeInsets get containerPadding {
    switch (_keyCapStyle) {
      case KeyCapStyle.elevated:
        return EdgeInsets.only(bottom: _fontSize * .25);

      case KeyCapStyle.plastic:
        return EdgeInsets.symmetric(
          horizontal: _fontSize * .175,
        ).copyWith(bottom: _fontSize * .5);

      // case KeyCapStyle.retro:
      //   return EdgeInsets.symmetric(
      //     horizontal: _fontSize * .5,
      //   ).copyWith(top: _fontSize * 0.125, bottom: _fontSize * 0.5625);

      case KeyCapStyle.mechanical:
        return EdgeInsets.symmetric(
          horizontal: _fontSize * .4375,
        ).copyWith(top: _fontSize * 0.16, bottom: _fontSize * 0.24);

      default:
        return EdgeInsets.zero;
    }
  }

  double get borderRadiusValue =>
      (minContainerSize.height / 2) * _cornerSmoothing;

  BorderRadius get borderRadius {
    switch (_keyCapStyle) {
      case KeyCapStyle.flat:
      // case KeyCapStyle.retro:
      case KeyCapStyle.elevated:
      case KeyCapStyle.mechanical:
        return BorderRadius.circular(borderRadiusValue);

      case KeyCapStyle.plastic:
        if (_cornerSmoothing <= .5) {
          return BorderRadius.vertical(
            top: Radius.circular(borderRadiusValue),
            bottom: Radius.circular(borderRadiusValue * 1.2),
          );
        }
        if (_cornerSmoothing <= .75) {
          return BorderRadius.vertical(
            top: Radius.circular(minContainerSize.height * .25),
            bottom: Radius.circular(borderRadiusValue),
          );
        } else {
          return BorderRadius.circular(borderRadiusValue);
        }

      default:
        return BorderRadius.zero;
    }
  }

  BorderRadius get outerBorderRadius {
    switch (_keyCapStyle) {
      // case KeyCapStyle.retro:
      case KeyCapStyle.plastic:
      case KeyCapStyle.elevated:
        return BorderRadius.circular(
          (minOuterContainerSize.height / 2) * _cornerSmoothing,
        );

      case KeyCapStyle.mechanical:
        return BorderRadius.circular(
          (minOuterContainerSize.height / 2) * _cornerSmoothing.clamp(0, .32),
        );

      default:
        return BorderRadius.zero;
    }
  }

  set keyCapStyle(KeyCapStyle value) {
    _keyCapStyle = value;
    // defaults
    switch (value) {
      case KeyCapStyle.minimal:
        _backgroundColor = Colors.black;
        _fontColor = Colors.white;
        _addPlusSeparator = true;
        break;

      case KeyCapStyle.flat:
        _fontColor = Colors.black;

        _primaryColor1 = Colors.white;
        _primaryColor2 = const Color(0xfff2f2f2);
        _borderColor = const Color(0xffcccccc);

        _mPrimaryColor1 = const Color(0xff76BCEF);
        _mPrimaryColor2 = const Color(0xff1A8FE3);
        _mBorderColor = const Color(0xff1882CE);
        break;

      case KeyCapStyle.elevated:
        _primaryColor1 = Colors.white;
        _secondaryColor1 = _mSecondaryColor1 = Colors.black;
        _borderColor = _mBorderColor = Colors.black;
        _fontColor = _mFontColor = Colors.black;
        _isGradient = false;

        _mPrimaryColor1 = const Color(0xff3A86FF);
        break;

      case KeyCapStyle.plastic:
        _borderColor = const Color(0xffcccccc);
        _mBorderColor = const Color(0xff003180);

        if (_isGradient) {
          _primaryColor1 = const Color(0xffececec);
          _primaryColor2 = Colors.white;

          _secondaryColor1 = const Color(0xfff2f2f2);
          _secondaryColor2 = const Color(0xffc4c4c4);

          _mPrimaryColor1 = const Color(0xff66A1FF);
          _mPrimaryColor2 = const Color(0xff3382FF);

          _mSecondaryColor1 = const Color(0xff0062FF);
          _mSecondaryColor2 = const Color(0xff004FCC);
        } else {
          _primaryColor1 = Colors.white;
          _secondaryColor1 = const Color(0xfff2f2f2);
          _borderColor = const Color(0xffcccccc);

          _mPrimaryColor1 = const Color(0xff3A86ff);
          _mSecondaryColor1 = const Color(0xff0062ff);
          _mBorderColor = const Color(0xff003180);
        }
        break;

      case KeyCapStyle.mechanical:
        _isGradient = false;
        _cornerSmoothing = .8;
        _primaryColor1 = const Color(0xff333f4d);
        _secondaryColor1 = const Color(0xff212932);
        _fontColor = const Color(0xffff9b00);

        _mPrimaryColor1 = const Color(0xfff08200);
        _mSecondaryColor1 = const Color(0xffff8a00);
        _mFontColor = Colors.black;
        break;
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
    if (_modifierTextLength == ModifierTextLength.iconOnly) {
      _showIcon = true;
    }
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
    if (_keyCapStyle == KeyCapStyle.minimal) {
      _separatorColor = _fontColor;
    } else {
      final lightness = HSVColor.fromColor(value).value;
      if (lightness > .5) {
        // light color
        _separatorColor = Colors.black;
      } else {
        // dark color
        _separatorColor = Colors.white;
      }
    }
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

  Map<String, dynamic> get toJson => {
        _JsonKeys.keyCapStyle: _keyCapStyle.name,
        _JsonKeys.fontSize: _fontSize,
        _JsonKeys.fontColor: _fontColor.toHex(),
        _JsonKeys.mFontColor: _mFontColor.toHex(),
        _JsonKeys.textCap: _textCap.name,
        _JsonKeys.modifierTextLength: _modifierTextLength.name,
        _JsonKeys.verticalAlignment: _verticalAlignment.name,
        _JsonKeys.horizontalAlignment: _horizontalAlignment.name,
        _JsonKeys.showIcon: _showIcon,
        _JsonKeys.showSymbol: _showSymbol,
        _JsonKeys.addPlusSeparator: _addPlusSeparator,
        _JsonKeys.isGradient: _isGradient,
        _JsonKeys.primaryColor1: _primaryColor1.toHex(),
        _JsonKeys.primaryColor2: _primaryColor2.toHex(),
        _JsonKeys.secondaryColor1: _secondaryColor1.toHex(),
        _JsonKeys.secondaryColor2: _secondaryColor2.toHex(),
        _JsonKeys.mPrimaryColor1: _mPrimaryColor1.toHex(),
        _JsonKeys.mPrimaryColor2: _mPrimaryColor2.toHex(),
        _JsonKeys.mSecondaryColor1: _mSecondaryColor1.toHex(),
        _JsonKeys.mSecondaryColor2: _mSecondaryColor2.toHex(),
        _JsonKeys.borderEnabled: _borderEnabled,
        _JsonKeys.borderColor: _borderColor.toHex(),
        _JsonKeys.borderWidth: _borderWidth,
        _JsonKeys.cornerSmoothing: _cornerSmoothing,
        _JsonKeys.backgroundEnabled: _backgroundEnabled,
        _JsonKeys.backgroundColor: _backgroundColor.toHex(),
        _JsonKeys.backgroundOpacity: _backgroundOpacity,
        _JsonKeys.alignment: _alignment.toString(),
        _JsonKeys.margin: _margin,
        _JsonKeys.clickAnimation: _clickAnimation.name,
        _JsonKeys.clickColor: _clickColor.toHex(),
      };

  _updateFromJson() async {
    final data = await Vault.loadStyleData();

    if (data == null) return;

    switch (data[_JsonKeys.keyCapStyle]) {
      case "minimal":
        _keyCapStyle = KeyCapStyle.minimal;
        break;

      case "flat":
        _keyCapStyle = KeyCapStyle.flat;
        break;

      case "elevated":
        _keyCapStyle = KeyCapStyle.elevated;
        break;

      case "plastic":
        _keyCapStyle = KeyCapStyle.plastic;
        break;

      case "mechanical":
        _keyCapStyle = KeyCapStyle.mechanical;
        break;
    }

    _fontSize = data[_JsonKeys.fontSize] ?? _Defaults.fontSize;

    _fontColor = HexColor.fromHex(
      data[_JsonKeys.fontColor] ?? "000000",
    );
    _mFontColor = HexColor.fromHex(
      data[_JsonKeys.mFontColor] ?? "000000",
    );

    switch (data[_JsonKeys.textCap]) {
      case "lower":
        _textCap = TextCap.lower;
        break;

      case "capitalize":
        _textCap = TextCap.capitalize;
        break;

      case "upper":
        _textCap = TextCap.upper;
        break;
    }

    switch (data[_JsonKeys.modifierTextLength]) {
      case "fullLength":
        _modifierTextLength = ModifierTextLength.fullLength;
        break;

      case "shortLength":
        _modifierTextLength = ModifierTextLength.shortLength;
        break;

      case "iconOnly":
        _modifierTextLength = ModifierTextLength.iconOnly;
        break;
    }

    switch (data[_JsonKeys.verticalAlignment]) {
      case "top":
        _verticalAlignment = VerticalAlignment.top;
        break;

      case "center":
        _verticalAlignment = VerticalAlignment.center;
        break;

      case "bottom":
        _verticalAlignment = VerticalAlignment.bottom;
        break;
    }

    switch (data[_JsonKeys.horizontalAlignment]) {
      case "left":
        _horizontalAlignment = HorizontalAlignment.left;
        break;

      case "center":
        _horizontalAlignment = HorizontalAlignment.center;
        break;

      case "right":
        _horizontalAlignment = HorizontalAlignment.right;
        break;
    }

    _showIcon = data[_JsonKeys.showIcon] ?? _Defaults.showIcon;
    _showSymbol = data[_JsonKeys.showSymbol] ?? _Defaults.showSymbol;
    _addPlusSeparator =
        data[_JsonKeys.addPlusSeparator] ?? _Defaults.addPlusSeparator;

    _isGradient = data[_JsonKeys.isGradient] ?? _Defaults.isGradient;

    _primaryColor1 = HexColor.fromHex(
      data[_JsonKeys.primaryColor1] ?? "ffffff",
    );
    _primaryColor2 = HexColor.fromHex(
      data[_JsonKeys.primaryColor2] ?? "f2f2f2",
    );
    _secondaryColor1 = HexColor.fromHex(
      data[_JsonKeys.secondaryColor1] ?? "000000",
    );
    _secondaryColor2 = HexColor.fromHex(
      data[_JsonKeys.secondaryColor2] ?? "1a1a1a",
    );
    _mPrimaryColor1 = HexColor.fromHex(
      data[_JsonKeys.mPrimaryColor1] ?? "3a86ff",
    );
    _mPrimaryColor2 = HexColor.fromHex(
      data[_JsonKeys.mPrimaryColor2] ?? "004fcc",
    );
    _mSecondaryColor1 = HexColor.fromHex(
      data[_JsonKeys.mSecondaryColor1] ?? "000000",
    );
    _mSecondaryColor2 = HexColor.fromHex(
      data[_JsonKeys.mSecondaryColor2] ?? "1a1a1a",
    );

    _borderEnabled = data[_JsonKeys.borderEnabled] ?? _Defaults.borderEnabled;
    _borderColor = HexColor.fromHex(data[_JsonKeys.borderColor] ?? "000000");
    _borderWidth = data[_JsonKeys.borderWidth];
    _cornerSmoothing =
        data[_JsonKeys.cornerSmoothing] ?? _Defaults.cornerSmoothing;

    _backgroundEnabled =
        data[_JsonKeys.backgroundEnabled] ?? _Defaults.backgroundEnabled;
    _backgroundColor = HexColor.fromHex(
      data[_JsonKeys.backgroundColor] ?? "ffffff",
    );
    _backgroundOpacity =
        data[_JsonKeys.backgroundOpacity] ?? _Defaults.backgroundOpacity;

    switch (data[_JsonKeys.alignment]) {
      case 'Alignment.topLeft':
        _alignment = Alignment.topLeft;
        break;

      case 'Alignment.topCenter':
        _alignment = Alignment.topCenter;
        break;

      case 'Alignment.topRight':
        _alignment = Alignment.topRight;
        break;

      case 'Alignment.centerLeft':
        _alignment = Alignment.centerLeft;
        break;

      case 'Alignment.center':
        _alignment = Alignment.center;
        break;

      case 'Alignment.centerRight':
        _alignment = Alignment.centerRight;
        break;

      case 'Alignment.bottomLeft':
        _alignment = Alignment.bottomLeft;
        break;

      case 'Alignment.bottomCenter':
        _alignment = Alignment.bottomCenter;
        break;

      case 'Alignment.bottomRight':
        _alignment = Alignment.bottomRight;
        break;
    }

    _margin = data[_JsonKeys.margin] ?? _Defaults.margin;

    switch (data[_JsonKeys.clickAnimation]) {
      case "static":
        _clickAnimation = MouseClickAnimation.static;
        break;

      case "focus":
        _clickAnimation = MouseClickAnimation.focus;
        break;

      case "filled":
        _clickAnimation = MouseClickAnimation.filled;
        break;
    }

    _clickColor = HexColor.fromHex(data[_JsonKeys.clickColor] ?? "e6e6e6");
  }

  reverToDefaults() {
    _keyCapStyle = _Defaults.keyCapStyle;
    _fontSize = _Defaults.fontSize;
    _fontColor = _Defaults.fontColor;
    _mFontColor = _Defaults.mFontColor;
    _textCap = _Defaults.textCap;
    _modifierTextLength = _Defaults.modifierTextLength;
    _verticalAlignment = _Defaults.verticalAlignment;
    _horizontalAlignment = _Defaults.horizontalAlignment;
    _showIcon = _Defaults.showIcon;
    _showSymbol = _Defaults.showSymbol;
    _addPlusSeparator = _Defaults.addPlusSeparator;
    _isGradient = _Defaults.isGradient;
    _primaryColor1 = _Defaults.primaryColor1;
    _primaryColor2 = _Defaults.primaryColor2;
    _secondaryColor1 = _Defaults.secondaryColor1;
    _secondaryColor2 = _Defaults.secondaryColor2;
    _mPrimaryColor1 = _Defaults.mPrimaryColor1;
    _mPrimaryColor2 = _Defaults.mPrimaryColor2;
    _mSecondaryColor1 = _Defaults.mSecondaryColor1;
    _mSecondaryColor2 = _Defaults.mSecondaryColor2;
    _borderEnabled = _Defaults.borderEnabled;
    _borderColor = _Defaults.borderColor;
    _borderWidth = _Defaults.borderWidth;
    _cornerSmoothing = _Defaults.cornerSmoothing;
    _backgroundEnabled = _Defaults.backgroundEnabled;
    _backgroundColor = _Defaults.backgroundColor;
    _backgroundOpacity = _Defaults.backgroundOpacity;
    _alignment = _Defaults.alignment;
    _margin = _Defaults.margin;
    _clickAnimation = _Defaults.clickAnimation;
    _clickColor = _Defaults.clickColor;

    notifyListeners();
  }
}

class _JsonKeys {
  static const keyCapStyle = "keycap_style";
  static const fontSize = "font_size";
  static const fontColor = "font_color";
  static const mFontColor = "mfont_color";
  static const textCap = "text_cap";
  static const modifierTextLength = "modifier_length";
  static const verticalAlignment = "vertical_alignment";
  static const horizontalAlignment = "horizontal_alignment";
  static const showIcon = "show_icon";
  static const showSymbol = "show_symbol";
  static const addPlusSeparator = "add_separator";
  static const isGradient = "is_gradient";
  static const primaryColor1 = "primary_color1";
  static const primaryColor2 = "primary_color2";
  static const secondaryColor1 = "secondary_color1";
  static const secondaryColor2 = "secondary_color2";
  static const mPrimaryColor1 = "mprimary_color1";
  static const mPrimaryColor2 = "mprimary_color2";
  static const mSecondaryColor1 = "msecondary_color1";
  static const mSecondaryColor2 = "msecondary_color2";
  static const borderEnabled = "border_enabled";
  static const borderColor = "border_color";
  static const borderWidth = "border_width";
  static const cornerSmoothing = "corner_smoothing";
  static const backgroundEnabled = "background_enabled";
  static const backgroundColor = "background_color";
  static const backgroundOpacity = "background_opacity";
  static const alignment = "alignment";
  static const margin = "margin";
  static const clickAnimation = "click_animation";
  static const clickColor = "click_color";
}

class _Defaults {
  static const keyCapStyle = KeyCapStyle.elevated;
  static const fontSize = 24.0;
  static const fontColor = Colors.black;
  static const mFontColor = Colors.black;
  static const textCap = TextCap.capitalize;
  static const modifierTextLength = ModifierTextLength.fullLength;
  static const verticalAlignment = VerticalAlignment.center;
  static const horizontalAlignment = HorizontalAlignment.center;
  static const showIcon = true;
  static const showSymbol = true;
  static const addPlusSeparator = true;
  static const isGradient = false;
  static const primaryColor1 = Colors.white;
  static const primaryColor2 = Colors.grey;
  static const secondaryColor1 = Colors.black;
  static const secondaryColor2 = Color(0xff1a1a1a);
  static const mPrimaryColor1 = Color(0xff3A86FF);
  static const mPrimaryColor2 = Color(0xff004FCC);
  static const mSecondaryColor1 = Colors.blueGrey;
  static const mSecondaryColor2 = Colors.blue;
  static const borderEnabled = true;
  static const borderColor = Colors.black;
  static const borderWidth = 1.0;
  static const cornerSmoothing = .5;
  static const backgroundEnabled = true;
  static const backgroundColor = Colors.white;
  static const backgroundOpacity = 1.0;
  static const alignment = Alignment.bottomRight;
  static const margin = 80.0;
  static const clickAnimation = MouseClickAnimation.focus;
  static const clickColor = Color(0xffe6e6e6);
}
