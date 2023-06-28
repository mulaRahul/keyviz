import 'package:flutter/services.dart';
import 'package:keyviz/domain/services/raw_keyboard_mouse.dart';

extension Ease on RawKeyEvent {
  int get keyId => logicalKey.keyId;
  bool get isMouse => data is RawKeyEventDataMouse;
  String get label {
    if (isMouse) {
      return data.keyLabel;
    } else {
      return logicalKey.keyLabel;
    }
  }
}

const _modifiers = [
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
];

class KeyEventData {
  KeyEventData(this.rawEvent);

  // pressed state of the key
  // initially comes pressed
  bool _pressed = true;

  // number of times pressed
  int _pressedCount = 1;

  // the animation in/out state of this key
  bool show = false;

  // logical representation of the KeyEvent
  final RawKeyEvent rawEvent;

  bool get pressed => _pressed;
  int get pressedCount => _pressedCount;

  set pressed(bool value) {
    _pressed = value;
    if (_pressed) _pressedCount++;
  }

  String get label => rawEvent.label;

  bool get isModifierKey {
    return _modifiers.contains(rawEvent.logicalKey);
  }

  @override
  bool operator ==(other) {
    return other is KeyEventData &&
        other.show == show &&
        other.pressed == _pressed &&
        other.pressedCount == _pressedCount;
  }

  @override
  int get hashCode => Object.hash(pressed, _pressedCount, show);
}
