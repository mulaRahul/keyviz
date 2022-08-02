import 'package:flutter/material.dart';

enum AnimationType { none, slide, fade, grow }

enum KeycapStyle { solid, isometric }

// ? colors
const Color lightGrey = Color(0xffF0F0F0);
const Color grey = Color(0xffE0E0E0);
const Color darkGrey = Color(0xff808080);
const Color darkerGrey = Color(0xff404040);
const Color veryDarkGrey = Color(0xff1a1a1a);

// ? text styles
final ButtonStyle elevatedButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.black),
);
const TextStyle headingStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
);
const TextStyle paragraphStyle = TextStyle(
  color: grey,
  fontSize: 16,
);
const TextStyle captionStyle = TextStyle(
  fontWeight: FontWeight.w300,
  color: darkGrey,
  fontSize: 16,
);

// ? options
const List<String> keycapStyles = ["default", "solid", "isometric"];
const List<String> sizeOptions = ["32 px", "36 px", "40 px", "44 px", "48 px"];

class KeycapTheme {
  String name;
  Color baseColor;
  Color fontColor;
  KeycapTheme(this.name, this.baseColor, this.fontColor);
}

final Map<String, KeycapTheme> keycapThemes = {
  "silver": KeycapTheme(
    "silver",
    const Color(0xfff8f8f8),
    const Color(0xff000000),
  ),
  "stone": KeycapTheme(
    "stone",
    const Color(0xff606060),
    const Color(0xfff8f8f8),
  ),
  "lime": KeycapTheme(
    "lime",
    const Color(0xff606060),
    const Color(0xffD6ED17),
  ),
  "cyber": KeycapTheme(
    "cyber",
    const Color(0xff00B1D2),
    const Color(0xffFDDB27),
  ),
  "turquoise": KeycapTheme(
    "turquoise",
    const Color(0xff42EADD),
    const Color(0xffffffff),
  ),
  "blue": KeycapTheme(
    "blue",
    const Color(0xff2196f3),
    const Color(0xffffffff),
  ),
  "yellow": KeycapTheme(
    "yellow",
    const Color(0xffFDDB27),
    const Color(0xff000000),
  ),
  "green": KeycapTheme(
    "green",
    const Color(0xff66bb6a),
    const Color(0xffffffff),
  ),
  "pink": KeycapTheme(
    "pink",
    const Color(0xfff06292),
    const Color(0xffffffff),
  ),
  "red": KeycapTheme(
    "red",
    const Color(0xffef5350),
    const Color(0xffffffff),
  ),
  "pansy": KeycapTheme(
    "pansy",
    const Color(0xff673ab7),
    const Color(0xffffc107),
  ),
  "eclipse": KeycapTheme(
    "eclipse",
    const Color(0xff343148),
    const Color(0xffD7C49E),
  ),
  "bumblebee": KeycapTheme(
    "bumblebee",
    const Color(0xff404040),
    const Color(0xffFDDB27),
  ),
  "charcoal": KeycapTheme(
    "charcoal",
    const Color(0xff404040),
    const Color(0xffFFFFFF),
  ),
};
final Map<String, String> hexcodes = {
  "silver": "0xfff8f8f8",
  "glass": "0x33f8f8f8",
  "soybean": "0xffD7C49E",
  "lightblue": "0xff00B1D2",
  "cyan": "0xff00d2bf",
  "pink": "0xfff06292",
  "green": "0xff66bb6a",
  "yellow": "0xffFDDB27",
  "blue": "0xff2196f3",
  "turquoise": "0xff42EADD",
  "amber": "0xffffc107",
  "lime": "0xffD6ED17",
  "red": "0xffef5350",
  "grey": "0xff606060",
  "eclipse": "0xff343148",
  "darkpurple": "0xff673ab7",
  "darkgrey": "0xff303030",
  "black": "0xff000000",
  "transparent": "0x00000000",
};
final Map<String, String> colorNames = {
  "0xfff8f8f8": "silver",
  "0x33f8f8f8": "glass",
  "0xffd7c49e": "soybean",
  "0xff00b1d2": "cyan",
  "0xff00d2bf": "lightblue",
  "0xfff06292": "pink",
  "0xff66bb6a": "green",
  "0xfffddb27": "yellow",
  "0xff2196f3": "blue",
  "0xff42eadd": "turquoise",
  "0xffffc107": "amber",
  "0xffd6ed17": "lime",
  "0xffef5350": "red",
  "0xff606060": "grey",
  "0xff343148": "eclipse",
  "0xff673ab7": "darkpurple",
  "0xff404040": "darkgrey",
  "0xff000000": "black",
};
const Map<String, Alignment> alignmentFrom = {
  "right": Alignment.bottomRight,
  "center": Alignment.bottomCenter,
  "left": Alignment.bottomLeft,
};
final Map<Alignment, String> alignmentStringFrom = {
  Alignment.bottomRight: "right",
  Alignment.bottomCenter: "center",
  Alignment.bottomLeft: "left",
};
const Map<String, KeycapStyle> styleFrom = {
  "solid": KeycapStyle.solid,
  "isometric": KeycapStyle.isometric,
};
const Map<KeycapStyle, String> styleStringFrom = {
  KeycapStyle.solid: "solid",
  KeycapStyle.isometric: "isometric",
};
const Map<String, AnimationType> animationTypeFrom = {
  "none": AnimationType.none,
  "slide": AnimationType.slide,
  "fade": AnimationType.fade,
  "grow": AnimationType.grow,
};
const Map<AnimationType, String> animationTypeStringFrom = {
  AnimationType.none: "none",
  AnimationType.slide: "slide",
  AnimationType.fade: "fade",
  AnimationType.grow: "grow",
};
// ? defaults
final Map<String, dynamic> defaultConfigData = {
  "filterHotkeys": false,
  "shiftOEM": true,
  "replaceNew": true,
  "style": KeycapStyle.isometric,
  "keyColor": "stone",
  "modifierColor": "charcoal",
  "size": 36.0,
  "showIcon": true,
  "showSymbol": true,
  "alignment": Alignment.bottomRight,
  "margin": 64.0,
  "animation": AnimationType.fade,
  "borderColor": "0x33f8f8f8",
  "lingerDuration": 4,
  "transitionDuration": 400,
};
// ? utility functions
Color colorFromHex(String hex) {
  return Color(int.parse(hex));
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  HSLColor hsl = HSLColor.fromColor(color);

  if (color == Colors.black) {
    hsl = hsl.withSaturation(0.0);
  }

  final HSLColor hslLight =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

double grayscaleValue(Color color) =>
    (0.299 * color.red) + (0.587 * color.blue) + (0.114 * color.green);

bool isDark(Color color) => grayscaleValue(color) < 36;
