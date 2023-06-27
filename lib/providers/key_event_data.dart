import 'package:flutter/services.dart';

class KeyEventData {
  KeyEventData(RawKeyEvent rawKeyEvent) : logicalKey = rawKeyEvent.logicalKey;

  // pressed state of the key
  // initially comes pressed
  bool _pressed = true;

  // number of times pressed
  int _pressedCount = 1;

  // the animation in/out state of this key
  bool show = false;

  // logical representation of the KeyEvent
  final LogicalKeyboardKey logicalKey;

  bool get pressed => _pressed;
  int get pressedCount => _pressedCount;

  set pressed(bool value) {
    _pressed = value;
    if (_pressed) _pressedCount++;
  }

  @override
  bool operator ==(other) {
    return other is KeyEventData &&
        other.show == show &&
        other.pressed == _pressed &&
        other.pressedCount == _pressedCount &&
        other.logicalKey == logicalKey;
  }

  @override
  int get hashCode => Object.hash(logicalKey, pressed, _pressedCount, show);
}
