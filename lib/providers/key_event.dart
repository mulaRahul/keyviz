import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:hid_listener/hid_listener.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/domain/services/raw_keyboard_mouse.dart';

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

extension on MouseEvent {
  Offset get offset => Offset(x, y);
}

/// keyboard event provider and related configurations
class KeyEventProvider extends ChangeNotifier {
  KeyEventProvider() {
    _init();
  }

  // keyboard event listener id
  int? _mouseListenerId;

  // cursor position
  Offset _cursorOffset = Offset.zero;

  // cursor button down state
  bool _mouseButtonDown = false;

  // mouse left button down and mouse moving
  bool _dragging = false;

  // keyboard event listener id
  int? _keyboardListenerId;

  // list of key id's currently hold down
  final Map<int, RawKeyDownEvent> _keyDown = {};

  // tracking variable for every key down
  // follwed by key up  synchronously
  bool _lastKeyDown = false;
  bool _keyUpFollowed = true;

  // id for each key events group
  String? _groupId;

  // main list of key events to be consumed by the visualizer
  // may not include history is historyMode is set to none
  final Map<String, Map<int, KeyEventData>> _keyboardEvents = {};

  // filter letters, numbers, symbols, etc. and
  // show hotkeys/keyboard shortuts
  bool _filterHotkeys = false;

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

  // max history number
  final int _maxHistory = 6;

  // keyviz toggle global shortcut
  List<String> _keyvizToggleShortcut = [];

  // amount of time the visualization stays on the screen in seconds
  int _lingerDurationInSeconds = 4;

  // key cap animation speed in milliseconds
  int _animationSpeed = 200;

  // keycap animation type
  KeyCapAnimation _keyCapAnimation = KeyCapAnimation.slide;

  // mouse visualize clicks
  bool _showMouseClicks = false;

  // mouse visualize clicks
  bool _highlightCursor = false;

  // show mouse events with keypress like Shift + Drag
  bool _showMouseEvents = false;

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
  Offset get cursorOffset => _cursorOffset;
  bool get mouseButtonDown => _mouseButtonDown;

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

  _init() {
    // TODO: load data
    // register mouse event listener
    _registerMouseListener();
    // register keyboard event listener
    _registerKeyboardListener();
  }

  _registerMouseListener() {
    _mouseListenerId = registerMouseListener(_onMouseEvent);

    if (_mouseListenerId == null) {
      debugPrint("couldn't register mouse listener");
    } else {
      debugPrint("registered mouse listener");
    }
  }

  _onMouseEvent(MouseEvent event) {
    // mouse moved
    if (event is MouseMoveEvent) {
      _onMouseMove(event);
    }
    // mouse button clicked/released
    else if (event is MouseButtonEvent) {
      _onMouseButton(event);
    }
    // mouse wheel scrolled
    else if (event is MouseWheelEvent) {
      _onMouseWheel(event);
    }
  }

  _onMouseMove(MouseMoveEvent event) {
    bool notify = false;
    _cursorOffset = event.offset;
    // animate cursor position when cursor highlighted
    if (_highlightCursor || _dragging) {
      notify = true;
    }
    // drag started
    if (_mouseButtonDown && !_dragging) {
      _dragging = true;

      // show mouse events in key visualizer
      if (_showMouseEvents) {
        // remove left/right click event
        _keyDown.removeWhere(
          (_, event) =>
              event.logicalKey.keyId == leftClickId ||
              event.logicalKey.keyId == rightClickId,
        );
        _keyboardEvents[_groupId]?.removeWhere(
          (_, value) =>
              value.rawEvent.logicalKey.keyId == leftClickId ||
              value.rawEvent.logicalKey.keyId == rightClickId,
        );

        // drag event pressed down
        _onKeyDown(
          const RawKeyDownEvent(data: RawKeyEventDataMouse.drag()),
        );

        notify = true;
      }
    }

    if (notify) notifyListeners();
  }

  _onMouseButton(MouseButtonEvent event) {
    final wasDragging = _dragging;
    final leftOrRightDown = event.type == MouseButtonEventType.leftButtonDown ||
        event.type == MouseButtonEventType.rightButtonDown;

    if (_dragging && leftOrRightDown) {
      _dragging = false;
    }

    // update offset
    _cursorOffset = event.offset;

    if (leftOrRightDown) {
      _mouseButtonDown = true;
    } else {
      _mouseButtonDown = false;
    }

    if (_showMouseClicks) {
      notifyListeners();
    }

    if (_showMouseEvents) {
      switch (event.type) {
        case MouseButtonEventType.leftButtonDown:
          _onKeyDown(
            const RawKeyDownEvent(data: RawKeyEventDataMouse.leftClick()),
          );
          break;

        case MouseButtonEventType.leftButtonUp:
          _onKeyUp(
            RawKeyUpEvent(
              data: wasDragging
                  ? const RawKeyEventDataMouse.drag()
                  : const RawKeyEventDataMouse.leftClick(),
            ),
          );
          break;

        case MouseButtonEventType.rightButtonDown:
          _onKeyDown(
            const RawKeyDownEvent(data: RawKeyEventDataMouse.rightClick()),
          );
          break;

        case MouseButtonEventType.rightButtonUp:
          _onKeyUp(
            RawKeyUpEvent(
              data: wasDragging
                  ? const RawKeyEventDataMouse.drag()
                  : const RawKeyEventDataMouse.rightClick(),
            ),
          );
          break;
      }
    }
  }

  // mouse wheel delta
  int _wheelDelta = 0;

  _onMouseWheel(MouseWheelEvent event) {
    // scroll started
    if (_wheelDelta == 0) {
      // dispatch scroll event
      _onKeyDown(
        const RawKeyDownEvent(data: RawKeyEventDataMouse.scroll()),
      );
    }
    _wheelDelta += event.wheelDelta;

    _isScrollStopped(_wheelDelta);
  }

  _isScrollStopped(int delta) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // scroll stopped
    if (delta == _wheelDelta) {
      // dispatch key up event
      _onKeyUp(
        const RawKeyUpEvent(data: RawKeyEventDataMouse.scroll()),
      );
      // reset wheel delta
      _wheelDelta = 0;
    }
  }

  _removeMouseListener() {
    if (_mouseListenerId != null) {
      unregisterMouseListener(_mouseListenerId!);
    }
  }

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
    if (event is RawKeyDownEvent && !_keyDown.containsKey(event.keyId)) {
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
    //   debugPrint("⬇️ [${event.data.keyLabel}] not hotkey, returning...");
    //   return;
    // }

    // filter unknown key
    if (event.logicalKey.keyLabel == "") {
      // fake mouse event
      if (event.data is! RawKeyEventDataMouse) {
        // TODO: handle unknown key
        debugPrint("⬇️ ignoring [${event.label}]");
        return;
      }
    }

    // check if key pressed again while in view
    // ignoring history and current display events has key id
    if (_ignoreHistory &&
        (_keyboardEvents[_groupId]?.containsKey(event.keyId) ?? false)) {
      // track key pressed down
      _keyDown[event.keyId] = event;

      // animate key press
      _keyboardEvents[_groupId]![event.keyId]!.pressed = true;
      notifyListeners();

      // remove previous keys if the above was just tracked
      if (_keyDown.length == 1) {
        _keyboardEvents[_groupId]!.removeWhere((key, _) => key != event.keyId);
      }
      debugPrint("⬇️ [${event.label}]");
      return;
    }
    // showing history and the last display event
    // has only one key with this key id
    else if ((_keyboardEvents.values.lastOrNull?.length ?? 0) == 1 &&
        _keyboardEvents.values.last.keys.first == event.keyId) {
      // track key pressed down
      _keyDown[event.keyId] = event;
      // reuse last group id
      _groupId = _keyboardEvents.keys.last;
      // animate key press
      _keyboardEvents[_groupId]![event.keyId]!.pressed = true;
      notifyListeners();

      debugPrint("⬇️ [${event.label}]");
      return;
    }

    // init group id
    _groupId ??= _timestamp;
    // create group if not created
    if (!_keyboardEvents.containsKey(_groupId)) {
      _keyboardEvents[_groupId!] = {};
    }

    // don't show history i.e. replace existing with new keys
    if (_ignoreHistory) {
      // remove key events in display but not pressed down
      // i.e. waiting for animation out
      if (_keyboardEvents[_groupId]!.isNotEmpty && _keyDown.isEmpty) {
        _keyboardEvents[_groupId]!.clear();
      }
    }
    // show history
    else {
      // enforce display events length
      if (_keyboardEvents.length > _maxHistory) {
        for (final group in _keyboardEvents.keys
            .take(_keyboardEvents.length - _maxHistory)) {
          _keyboardEvents.remove(group);
        }
      }

      if (!_keyUpFollowed) {
        // TODO handle events like Alt + (Left Click * n)
        // dispatch key up for not removed
        for (final keyId in _keyDown.keys) {
          _animateOut(_groupId!, keyId);
        }
        // change group id
        _groupId = _timestamp;
        // duplicate key downs
        _keyboardEvents[_groupId!] = {
          for (final entry in _keyDown.entries)
            entry.key: KeyEventData(entry.value),
        };
      }
    }

    // track key pressed down
    _keyDown[event.keyId] = event;

    _keyboardEvents[_groupId]![event.keyId] = KeyEventData(event);

    if (_noKeyCapAnimation) {
      // show the key event without animation
      _keyboardEvents[_groupId]![event.keyId]!.show = true;
    }

    notifyListeners();

    // animate with configured key cap animation
    if (!_noKeyCapAnimation) {
      _animateIn(_groupId!, event.keyId);
    }

    debugPrint("⬇️ [${event.label}]");

    // key event tracking
    _lastKeyDown = true;
  }

  _onKeyUp(RawKeyUpEvent event) async {
    // track key pressed up
    final removedEvent = _keyDown.remove(event.keyId);

    // sanity check
    if (removedEvent == null || _groupId == null) return;

    _animateOut(_groupId!, event.keyId);

    debugPrint("⬆️ [${event.label}]");

    // no keys pressed or only left with mouse events
    if (_keyDown.isEmpty) {
      // track all keys removed
      _keyUpFollowed = true;
      // reset _groupId when there are no keys pressed
      if (!_ignoreHistory) _groupId = null;
    } else {
      // track key combinations
      if (_lastKeyDown) {
        _lastKeyDown = false;
        _keyUpFollowed = false;
      }
    }
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
    final event = _keyboardEvents[groupId]?[keyId];
    if (event == null) return;

    // animate key released
    event.pressed = false;
    notifyListeners();

    final pressedCount = event.pressedCount;

    // wait for linger duration
    await Future.delayed(lingerDuration);

    // new pressed count
    final newPressedCount = _keyboardEvents[groupId]?[keyId]?.pressedCount;

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
      return !event.isMouse &&
              (!ignoreKeys[ModifierKey.control]! &&
                  event.data.isControlPressed) ||
          (!ignoreKeys[ModifierKey.meta]! && event.data.isMetaPressed) ||
          (!ignoreKeys[ModifierKey.alt]! && event.data.isAltPressed) ||
          (!ignoreKeys[ModifierKey.shift]! && event.data.isShiftPressed);
    } else {
      // if mouse event, should start with modifier
      if (event.isMouse) {
        return _keyDown.values.first.data.isControlPressed ||
            _keyDown.values.first.data.isMetaPressed ||
            _keyDown.values.first.data.isAltPressed ||
            _keyDown.values.first.data.isShiftPressed;
      }
      // modifier should be pressed down
      else {
        return event.data.isControlPressed ||
            event.data.isMetaPressed ||
            event.data.isAltPressed ||
            event.data.isShiftPressed;
      }
    }
  }

  String get _timestamp {
    final now = DateTime.now();
    return "${now.hour}${now.minute}${now.second}${now.millisecond}";
  }

  @override
  void dispose() {
    _removeMouseListener();
    _removeKeyboardListener();
    super.dispose();
  }
}
