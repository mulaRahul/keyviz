import 'package:flutter/material.dart';

import 'style.dart';

// colors
const darkerGrey = Color(0xff1a1a1a);
const darkGrey = Color(0xff545454);
const grey = Color(0xffcccccc);
const lightGrey = Color(0xffe6e6e6);
const lighterGrey = Color(0xfff2f2f2);

// text styles
const _baseTextStyle = TextStyle(
  color: darkerGrey,
  height: 1.25,
  fontFamily: "IBM Plex Sans",
);
final _titleStyle = _baseTextStyle.copyWith(
  fontSize: 18,
  fontWeight: FontWeight.w500, // medium
);
final _labelStyle = _baseTextStyle.copyWith(
  fontSize: 18,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);
final _bodyStyle = _baseTextStyle.copyWith(
  fontSize: 12,
  color: darkGrey,
  fontWeight: FontWeight.w400,
);

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    // font and highlights
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: darkerGrey,
    onSecondary: lightGrey,
    tertiary: darkGrey,
    outline: Color(0xffd9d9d9),
    // containers
    // *container: fill
    // on*Container: border
    primaryContainer: Colors.white,
    secondaryContainer: lighterGrey,
    background: lightGrey,
  ),
  fontFamily: "IBM Plex Sans",
  textTheme: TextTheme(
    // title
    titleLarge: _titleStyle,
    titleMedium: _titleStyle.copyWith(fontSize: 16),
    titleSmall: _titleStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    // label
    labelLarge: _labelStyle,
    labelMedium: _labelStyle.copyWith(fontSize: 16),
    labelSmall: _labelStyle.copyWith(fontSize: 12),
    // body
    bodyLarge: _bodyStyle,
    bodyMedium: _bodyStyle.copyWith(fontSize: 12),
    bodySmall: _bodyStyle.copyWith(fontSize: 10),
  ),
  dividerTheme: const DividerThemeData(
    space: defaultPadding * 2,
    color: grey,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.all(defaultPadding * .5),
    ),
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 2,
    inactiveTrackColor: lightGrey,
    overlayShape: SliderComponentShape.noOverlay,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 6,
      elevation: 0,
    ),
  ),
);

final darkTheme = lightTheme.copyWith(
  colorScheme: const ColorScheme.dark(
    // font and highlights
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: lightGrey,
    onSecondary: darkerGrey,
    tertiary: grey,
    outline: darkGrey,
    // containers
    primaryContainer: Color(0xff252525),
    secondaryContainer: darkerGrey,
    background: Colors.black,
  ),
  textTheme: TextTheme(
    // title
    titleLarge: _titleStyle.copyWith(color: lightGrey),
    titleMedium: _titleStyle.copyWith(fontSize: 16, color: lightGrey),
    titleSmall: _titleStyle.copyWith(
      fontSize: 14,
      color: lightGrey,
      fontWeight: FontWeight.w600,
    ),
    // label
    labelLarge: _labelStyle.copyWith(color: lightGrey),
    labelMedium: _labelStyle.copyWith(fontSize: 16, color: lightGrey),
    labelSmall: _labelStyle.copyWith(fontSize: 12, color: lightGrey),
    // body
    bodyLarge: _bodyStyle.copyWith(color: grey),
    bodyMedium: _bodyStyle.copyWith(fontSize: 12, color: grey),
    bodySmall: _bodyStyle.copyWith(fontSize: 10, color: grey),
  ),
  dividerTheme: const DividerThemeData(
    space: defaultPadding * 2,
    thickness: .5,
    color: darkGrey,
  ),
  sliderTheme: SliderThemeData(
    trackHeight: 2,
    inactiveTrackColor: grey,
    activeTrackColor: lighterGrey,
    thumbColor: Colors.white,
    overlayShape: SliderComponentShape.noOverlay,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 6,
      elevation: 0,
    ),
  ),
);
