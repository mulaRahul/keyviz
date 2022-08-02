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
    screenSize = (await screenRetriever.getPrimaryDisplay()).size;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    filterHotkeys =
        prefs.getBool("filterHotkeys") ?? defaultConfigData["filterHotkeys"];
    shiftOEM = prefs.getBool("shiftOEM") ?? defaultConfigData["shiftOEM"];
    replaceNew = prefs.getBool("replaceNew") ?? defaultConfigData["replaceNew"];
    style = styleFrom[prefs.getString("style")] ?? defaultConfigData["style"];
    keyColor = keycapThemes[
        prefs.getString("keyColor") ?? defaultConfigData["keyColor"]]!;
    modifierColor = keycapThemes[prefs.getString("modifierColor") ??
        defaultConfigData["modifierColor"]]!;
    size = prefs.getDouble("size") ?? defaultConfigData["size"];
    showIcon = prefs.getBool("showIcon") ?? defaultConfigData["showIcon"];
    showSymbol = prefs.getBool("showSymbol") ?? defaultConfigData["showSymbol"];
    alignment = alignmentFrom[prefs.getString("alignment")] ??
        defaultConfigData["alignment"];
    margin = prefs.getDouble("margin") ?? defaultConfigData["margin"];
    animation = animationTypeFrom[prefs.getString("animation")] ??
        defaultConfigData["animation"];
    borderColor = colorFromHex(
        prefs.getString("borderColor") ?? defaultConfigData["borderColor"]);
    lingerDuration = Duration(
        seconds: prefs.getInt("lingerDuration") ??
            defaultConfigData["lingerDuration"]);
    transitionDuration = Duration(
      milliseconds: prefs.getInt("transitionDuration") ??
          defaultConfigData["transitionDuration"],
    );
  }

  void revertToDefaults() {
    filterHotkeys = defaultConfigData["filterHotkeys"];
    shiftOEM = defaultConfigData["shiftOEM"];
    replaceNew = defaultConfigData["replaceNew"];
    style = defaultConfigData["style"];
    keyColor = keycapThemes[defaultConfigData["keyColor"]]!;
    modifierColor = keycapThemes[defaultConfigData["modifierColor"]]!;
    size = defaultConfigData["size"];
    showIcon = defaultConfigData["showIcon"];
    showSymbol = defaultConfigData["showSymbol"];
    alignment = defaultConfigData["alignment"];
    margin = defaultConfigData["margin"];
    animation = defaultConfigData["animation"];
    borderColor = colorFromHex(defaultConfigData["borderColor"]);
    lingerDuration = Duration(seconds: defaultConfigData["lingerDuration"]);
    transitionDuration =
        Duration(milliseconds: defaultConfigData["transitionDuration"]);
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
    prefs.setInt("transitionDuration", transitionDuration.inMilliseconds);
  }
}

final ConfigData configData = ConfigData();
