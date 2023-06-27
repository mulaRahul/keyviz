import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:hid_listener/hid_listener.dart';

import 'package:keyviz/config/config.dart';

import 'key_event_data.dart';

export 'key_event_data.dart';

// modifiers in a keyboard
enum ModifierKey {
  control("Control"),
  shift("Shift"),
  alt("Alt"),
  meta("Meta");

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

// keycap animation style
enum KeyCapAnimation {
  none,
  fade,
  wham,
  grow,
  slide;

  @override
  String toString() => name.capitalize();
}

/// keyboard event provider and related configurations
class KeyEventProvider extends ChangeNotifier {
  KeyEventProvider() {
    // TODO: load data
    // register keyboard listener
    _registerKeyboardListener();
  }

  // keyboard event listener id
  int? _keyboardListenerId;

  // list of key id's currently hold down
  final List<LogicalKeyboardKey> _keyDown = [];

  // id for each key events group
  String? _groupId;

  // main list of key events to be consumed by the visualizer
  // may not include history is historyMode is set to none
  final Map<String, Map<int, KeyEventData>> _keyboardEvents = {};

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
  };

  // whether to show history, if yes
  // then vertically or horizontally
  VisualizationHistoryMode _historyMode = VisualizationHistoryMode.none;

  // keyviz toggle global shortcut
  List<String> _keyvizToggleShortcut = [];

  // amount of time the visualization stays on the screen in seconds
  int _lingerDurationInSeconds = 4;

  // key cap animation speed in milliseconds
  int _animationSpeed = 200;

  // keycap animation type
  KeyCapAnimation _keyCapAnimation = KeyCapAnimation.slide;

  // mouse visualize clicks
  bool _showMouseClicks = true;

  // mouse visualize clicks
  bool _highlightCursor = false;

  // show mouse events with keypress like Shift + Drag
  bool _showMouseEvents = true;

  Map<String, Map<int, KeyEventData>> get keyboardEvents => _keyboardEvents;

  bool get filterHotkeys => _filterHotkeys;
  Map<ModifierKey, bool> get ignoreKeys => _ignoreKeys;
  VisualizationHistoryMode get historyMode => _historyMode;
  Axis? get historyDirection {
    switch (_historyMode) {
      case VisualizationHistoryMode.none:
        return null;

      case VisualizationHistoryMode.horizontal:
        return Axis.horizontal;

      case VisualizationHistoryMode.vertical:
        return Axis.vertical;
    }
  }

  List<String> get keyvizToggleShortcut => _keyvizToggleShortcut;
  int get lingerDurationInSeconds => _lingerDurationInSeconds;
  Duration get lingerDuration => Duration(seconds: _lingerDurationInSeconds);
  int get animationSpeed => _animationSpeed;
  Duration get animationDuration => Duration(milliseconds: _animationSpeed);
  KeyCapAnimation get keyCapAnimation => _keyCapAnimation;
  bool get _noKeyCapAnimation => _keyCapAnimation == KeyCapAnimation.none;
  bool get showMouseClicks => _showMouseClicks;
  bool get highlightCursor => _highlightCursor;
  bool get showMouseEvents => _showMouseEvents;

  bool get _ignoreHistory => _historyMode == VisualizationHistoryMode.none;

  set filterHotkeys(value) {
    _filterHotkeys = value;
    notifyListeners();
  }

  void setModifierKeyIgnoring(ModifierKey key, bool ingnoring) {
    _ignoreKeys[key] = ingnoring;
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

  set keyCapAnimation(KeyCapAnimation value) {
    _keyCapAnimation = value;
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

  // register listener
  _registerKeyboardListener() {
    _keyboardListenerId = registerKeyboardListener(_onRawKeyEvent);

    if (_keyboardListenerId == null) {
      debugPrint("cannot register keyboard listener!");
    } else {
      debugPrint("keyboard listener registered");
    }
  }

  _onRawKeyEvent(RawKeyEvent event) {
    // key pressed
    if (event is RawKeyDownEvent && !_keyDown.contains(event.logicalKey)) {
      _onKeyDown(event);
    }
    // key released
    else if (event is RawKeyUpEvent) {
      _onKeyUp(event);
    }
  }

  _onKeyDown(RawKeyDownEvent event) {
    // filter hotkey
    if (_filterHotkeys && !_eventIsHotkey(event)) return;
    // {
    //   debugPrint("⬇️ [${event.logicalKey.keyLabel}] not hotkey, returning...");
    //   return;
    // }

    // filter unknown key
    if (event.logicalKey.keyLabel == "") {
      // TODO: handle unknown key
      debugPrint("⬇️ ignoring [${event.logicalKey.keyLabel}]");
      return;
    }

    // reference event's logical key id
    final keyId = event.logicalKey.keyId;

    // init group id
    _groupId ??= _timestamp;
    // create group if not created
    if (!_keyboardEvents.containsKey(_groupId)) {
      _keyboardEvents[_groupId!] = {};
    }

    // key pressed again
    if (_ignoreHistory && _keyboardEvents[_groupId]!.containsKey(keyId)) {
      // track key pressed down
      _keyDown.add(event.logicalKey);

      // animate key press
      _keyboardEvents[_groupId]![keyId]!.pressed = true;
      notifyListeners();

      // remove previous keys
      if (_keyDown.length == 1) {
        _keyboardEvents[_groupId]!.removeWhere((key, _) => key != keyId);
      }
      debugPrint("⬇️ [${event.logicalKey.keyLabel}]");
      return;
    }

    // don't show history i.e. replace existing with new keys
    if (_ignoreHistory) {
      // remove key events in display but not pressed down
      // i.e. waiting for animation out
      if (_keyboardEvents[_groupId]!.isNotEmpty && _keyDown.isEmpty) {
        _keyboardEvents[_groupId]!.clear();
      }
      // track key pressed down
      _keyDown.add(event.logicalKey);

      _keyboardEvents[_groupId]![keyId] = KeyEventData(event);

      if (_noKeyCapAnimation) {
        // show the key event without animation
        _keyboardEvents[_groupId]![keyId]!.show = true;
      }

      notifyListeners();
    } else {}

    // animate with configured key cap animation
    if (!_noKeyCapAnimation) {
      _animateIn(_groupId!, keyId);
    }

    debugPrint("⬇️ [${event.logicalKey.keyLabel}]");
  }

  _onKeyUp(RawKeyUpEvent event) async {
    // track key pressed up
    final removed = _keyDown.remove(event.logicalKey);
    // sanity check
    if (!removed && _groupId == null) return;

    _animateOut(_groupId!, event.logicalKey.keyId);

    debugPrint("⬆️ [${event.logicalKey.keyLabel}]");

    // reset _groupId when there are no keys pressed
    if (!_ignoreHistory && _keyDown.isEmpty) _groupId = null;
  }

  _animateIn(String groupId, int keyId) async {
    // wait for background bar to expand
    await Future.delayed(animationDuration);
    // set show to true
    final event = _keyboardEvents[groupId]?[keyId];
    if (event != null) {
      event.show = true;
      notifyListeners();
    }
  }

  _animateOut(String groupId, int keyId) async {
    final event = _keyboardEvents[_groupId]?[keyId];
    if (event == null) return;

    // animate key released
    event.pressed = false;
    notifyListeners();

    final pressedCount = event.pressedCount;

    // wait for linger duration
    await Future.delayed(lingerDuration);

    // new pressed count
    final newPressedCount = _keyboardEvents[_groupId]?[keyId]?.pressedCount;

    if ( // make sure key event not removed
        // newPressedCount == null ||
        // key not pressed again
        pressedCount != newPressedCount) {
      debugPrint("key pressed again, returning...");
      return;
    }

    if (!_noKeyCapAnimation) {
      // animate out the key event
      event.show = false;
      notifyListeners();

      // wait for animation to finish
      await Future.delayed(animationDuration);
    }

    // remove key event
    _keyboardEvents[groupId]!.remove(keyId);
    notifyListeners();

    // check if the group is exhausted
    if (!_ignoreHistory && _keyboardEvents[groupId]!.isEmpty) {
      _keyboardEvents.remove(groupId);
    }
  }

  _removeKeyboardListener() {
    if (_keyboardListenerId != null) {
      unregisterKeyboardListener(_keyboardListenerId!);
    }
  }

  bool _eventIsHotkey(RawKeyEvent event) {
    if (_keyDown.isEmpty) {
      // event should be a modifier and not ignored
      return (!ignoreKeys[ModifierKey.control]! &&
              event.data.isControlPressed) ||
          (!ignoreKeys[ModifierKey.meta]! && event.data.isMetaPressed) ||
          (!ignoreKeys[ModifierKey.alt]! && event.data.isAltPressed) ||
          (!ignoreKeys[ModifierKey.shift]! && event.data.isShiftPressed);
    } else {
      // modifier should be pressed down
      return event.data.isControlPressed ||
          event.data.isMetaPressed ||
          event.data.isAltPressed ||
          event.data.isShiftPressed;
    }
  }

  String get _timestamp {
    final now = DateTime.now();
    return "${now.hour}${now.minute}${now.second}${now.millisecond}";
  }

  @override
  void dispose() {
    _removeKeyboardListener();
    super.dispose();
  }
}
