import 'package:flutter/material.dart';
import 'package:keyviz/config/config.dart';

// modifiers in a keyboard
enum ModifierKey {
  control("Control"),
  shift("Shift"),
  alt("Alt"),
  meta("Meta"),
  function("Fn");

  const ModifierKey(this.keyLabel);
  final String keyLabel;
}

// key visualization history mode
enum VisualizationHistoryMode {
  none,
  vertical,
  horizontal;

  @override
  String toString() {
    return this == VisualizationHistoryMode.none
        ? "None"
        : "${name.capitalize()}ly";
  }
}

/// keyboard event provider and related configurations
class KeyEventProvider extends ChangeNotifier {
  // filter letters, numbers, symbols, etc. and
  // show hotkeys/keyboard shortuts
  bool _filterHotkeys = true;

  // modifiers and function keys to ignore
  // when hotkey filter is turned on
  final Map<ModifierKey, bool> _ignoreKeys = {
    ModifierKey.control: false,
    ModifierKey.shift: true,
    ModifierKey.alt: false,
    ModifierKey.meta: false,
    ModifierKey.function: false,
  };
  // if any key needs to ignored
  bool _ignoreAny = true;

  // whether to show history, if yes
  // then vertically or horizontally
  VisualizationHistoryMode _historyMode = VisualizationHistoryMode.none;

  // keyviz toggle global shortcut
  List<String> _keyvizToggleShortcut = [];

  // amount of time the visualization stays on the screen in seconds
  int _lingerDurationInSeconds = 4;

  // key cap animation speed in milliseconds
  int _animationSpeed = 200;

  // mouse visualize clicks
  bool _showMouseClicks = true;

  // mouse visualize clicks
  bool _highlightCursor = false;

  // show mouse events with keypress like Shift + Drag
  bool _showMouseEvents = true;

  bool get filterHotkeys => _filterHotkeys;
  Map<ModifierKey, bool> get ignoreKeys => _ignoreKeys;
  VisualizationHistoryMode get historyMode => _historyMode;
  List<String> get keyvizToggleShortcut => _keyvizToggleShortcut;
  int get lingerDurationInSeconds => _lingerDurationInSeconds;
  Duration get lingerDuration => Duration(seconds: _lingerDurationInSeconds);
  int get animationSpeed => _animationSpeed;
  Duration get animationDuration => Duration(milliseconds: _animationSpeed);
  bool get showMouseClicks => _showMouseClicks;
  bool get highlightCursor => _highlightCursor;
  bool get showMouseEvents => _showMouseEvents;

  set filterHotkeys(value) {
    _filterHotkeys = value;
    _ignoreAny = value;
    notifyListeners();
  }

  void setModifierKeyIgnoring(ModifierKey key, bool ingnoring) {
    _ignoreKeys[key] = ingnoring;
    _ignoreAny = _ignoreKeys.values.any((ignore) => ignore);
    notifyListeners();
  }

  set historyMode(VisualizationHistoryMode value) {
    _historyMode = value;
    notifyListeners();
  }

  set keyvizToggleShortcut(List<String> value) {
    _keyvizToggleShortcut = value;
    notifyListeners();
  }

  set lingerDurationInSeconds(int value) {
    _lingerDurationInSeconds = value;
    notifyListeners();
  }

  set animationSpeed(value) {
    _animationSpeed = value;
    notifyListeners();
  }

  set showMouseClicks(bool value) {
    _showMouseClicks = value;
    notifyListeners();
  }

  set highlightCursor(bool value) {
    _highlightCursor = value;
    notifyListeners();
  }

  set showMouseEvents(bool value) {
    _showMouseEvents = value;
    notifyListeners();
  }
}
