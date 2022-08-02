import 'package:flutter/material.dart';
import 'package:keyviz/data/properties.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension ColorExtension on Color {
  String toHex() => toString().substring(6, 16);
}

class ConfigData {
  late final Size screenSize;

  late bool shiftOEM;
  late bool replaceNew;
  late bool filterHotkeys;
  late KeycapStyle style;
  late double size;
  late bool showIcon;
  late bool showSymbol;
  late KeycapTheme keyColor;
  late KeycapTheme modifierColor;
  late double margin;
  late Color borderColor;
  late Alignment alignment;
  late AnimationType animation;
  late Duration lingerDuration;
  late Duration transitionDuration;

  bool configuring = false;

  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    screenSize = (await screenRetriever.getPrimaryDisplay()).size;

    filterHotkeys = prefs.getBool("filterHotkeys") ?? false;
    shiftOEM = prefs.getBool("shiftOEM") ?? true;
    replaceNew = prefs.getBool("replaceNew") ?? true;
    style = styleFrom[prefs.getString("style")] ?? KeycapStyle.isometric;
    keyColor = keycapThemes[prefs.getString("keyColor") ?? "stone"]!;
    modifierColor =
        keycapThemes[prefs.getString("modifierColor") ?? "charcoal"]!;
    size = prefs.getDouble("size") ?? 36.0;
    showIcon = prefs.getBool("showIcon") ?? true;
    showSymbol = prefs.getBool("showSymbol") ?? true;
    alignment =
        alignmentFrom[prefs.getString("alignment")] ?? Alignment.bottomRight;
    margin = prefs.getDouble("margin") ?? 64.0;
    animation =
        animationTypeFrom[prefs.getString("animation")] ?? AnimationType.fade;
    borderColor = colorFromHex(prefs.getString("borderColor") ?? "0x33f8f8f8");
    lingerDuration = Duration(seconds: prefs.getInt("lingerDuration") ?? 4);
    transitionDuration = Duration(
      milliseconds: (200 + (prefs.getInt("lingerDuration") ?? 4) * 50).toInt(),
    );
  }

  void saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("shiftOEM", shiftOEM);
    prefs.setBool("replaceNew", replaceNew);
    prefs.setBool("filterHotkeys", filterHotkeys);
    prefs.setString("style", styleStringFrom[style] ?? "isometric");
    prefs.setDouble("size", size);
    prefs.setBool("showIcon", showIcon);
    prefs.setBool("showSymbol", showSymbol);
    prefs.setString("keyColor", keyColor.name);
    prefs.setString("modifierColor", modifierColor.name);
    prefs.setDouble("margin", margin);
    prefs.setString("borderColor", borderColor.toHex());
    prefs.setString("alignment", alignmentStringFrom[alignment] ?? "left");
    prefs.setString("animation", animationTypeStringFrom[animation] ?? "fade");
    prefs.setInt("lingerDuration", lingerDuration.inSeconds);
  }
}

final ConfigData configData = ConfigData();
