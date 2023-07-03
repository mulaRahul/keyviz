import 'package:flutter/services.dart';

import 'package:keyviz/domain/services/services.dart';

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
const _letters = [
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyB,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
  LogicalKeyboardKey.keyI,
  LogicalKeyboardKey.keyJ,
  LogicalKeyboardKey.keyK,
  LogicalKeyboardKey.keyL,
  LogicalKeyboardKey.keyM,
  LogicalKeyboardKey.keyN,
  LogicalKeyboardKey.keyO,
  LogicalKeyboardKey.keyP,
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyT,
  LogicalKeyboardKey.keyU,
  LogicalKeyboardKey.keyV,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyY,
  LogicalKeyboardKey.keyZ,
];
const _digits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
  LogicalKeyboardKey.digit0,
];
const _oems = [
  LogicalKeyboardKey.tilde,
  LogicalKeyboardKey.minus,
  LogicalKeyboardKey.equal,
  LogicalKeyboardKey.bracketLeft,
  LogicalKeyboardKey.bracketRight,
  LogicalKeyboardKey.backslash,
  LogicalKeyboardKey.comma,
  LogicalKeyboardKey.quoteSingle,
  LogicalKeyboardKey.question,
];
const _functions = [
  LogicalKeyboardKey.f1,
  LogicalKeyboardKey.f2,
  LogicalKeyboardKey.f3,
  LogicalKeyboardKey.f4,
  LogicalKeyboardKey.f5,
  LogicalKeyboardKey.f6,
  LogicalKeyboardKey.f7,
  LogicalKeyboardKey.f8,
  LogicalKeyboardKey.f9,
  LogicalKeyboardKey.f10,
  LogicalKeyboardKey.f11,
  LogicalKeyboardKey.f12,
  LogicalKeyboardKey.f13,
  LogicalKeyboardKey.f14,
  LogicalKeyboardKey.f15,
  LogicalKeyboardKey.f16,
  LogicalKeyboardKey.f17,
  LogicalKeyboardKey.f18,
  LogicalKeyboardKey.f19,
  LogicalKeyboardKey.f20,
  LogicalKeyboardKey.f21,
  LogicalKeyboardKey.f22,
  LogicalKeyboardKey.f23,
  LogicalKeyboardKey.f24,
];
const _normals = [
  LogicalKeyboardKey.printScreen,
  LogicalKeyboardKey.pause,
  LogicalKeyboardKey.backspace,
  LogicalKeyboardKey.tab,
  LogicalKeyboardKey.space,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.contextMenu,
];
const _locks = [
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.scrollLock,
  LogicalKeyboardKey.numLock,
];
const _navigations = [
  LogicalKeyboardKey.escape,
  LogicalKeyboardKey.insert,
  LogicalKeyboardKey.delete,
  LogicalKeyboardKey.home,
  LogicalKeyboardKey.end,
  LogicalKeyboardKey.pageUp,
  LogicalKeyboardKey.pageDown,
];
const _arrows = [
  LogicalKeyboardKey.arrowUp,
  LogicalKeyboardKey.arrowRight,
  LogicalKeyboardKey.arrowDown,
  LogicalKeyboardKey.arrowLeft,
];
const _numpad = [
  LogicalKeyboardKey.numpad0,
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2,
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
  LogicalKeyboardKey.numpad5,
  LogicalKeyboardKey.numpad6,
  LogicalKeyboardKey.numpad7,
  LogicalKeyboardKey.numpad8,
  LogicalKeyboardKey.numpad9,
  LogicalKeyboardKey.numpadDivide,
  LogicalKeyboardKey.numpadMultiply,
  LogicalKeyboardKey.numpadSubtract,
  LogicalKeyboardKey.numpadAdd,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.numpadDecimal,
  LogicalKeyboardKey.numpadEqual,
  LogicalKeyboardKey.numpadComma,
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
  int get _id => rawEvent.logicalKey.keyId;

  set pressed(bool value) {
    _pressed = value;
    if (_pressed) _pressedCount++;
  }

  // The event is a modifier like control, command, etc.
  bool get isModifier => _modifiers.contains(rawEvent.logicalKey);

  // The event is an alphabet like Q, A, etc.
  bool get isLetter => _letters.contains(rawEvent.logicalKey);

  // The event is a digit/number like 1, 2, etc.
  bool get isDigit => _digits.contains(rawEvent.logicalKey);

  // The event is a punctuation/symbol key like ~, =, etc.
  bool get isOEM => _oems.contains(rawEvent.logicalKey);

  // The event is a function key like F1, F2, etc.
  bool get isFunction => _functions.contains(rawEvent.logicalKey);

  // The event is an arrow key like ↑, →, etc.
  bool get isArrow => _arrows.contains(rawEvent.logicalKey);

  // The event is a special purpose key like Insert, Home, etc.
  bool get isNavigation => _navigations.contains(rawEvent.logicalKey);

  // The event is a normal key i.e. doesn't fall in the above
  // groups like Escape, Spacebar, Enter, etc.
  bool get isNormal => _normals.contains(rawEvent.logicalKey);

  // The event is a numpad key like Numpad /, *, etc.
  bool get isNumpad => _numpad.contains(rawEvent.logicalKey);

  // The event is a lock key i.e. caps lock, scroll lock, etc.
  bool get isLock => _locks.contains(rawEvent.logicalKey);

  // The event is a character i.e. either a letter, digit or punctuation
  bool get isCharacter => isLetter || isDigit || isOEM;

  // textual representation of this event
  String get label => keymaps[_id]?.label ?? rawEvent.label;

  // textual representation of this event in short
  String? get shortLabel => keymaps[_id]?.shortLabel;

  // graphical (unicode) representation of this event
  String? get glyph => keymaps[_id]?.glyph;

  // The event secondary symbol like digit 2 has @,
  // equals = has add +, etc. returns null if doesn't has symbol
  String? get symbol => keymaps[_id]?.symbol;

  // The events representation with iconography
  // returns null if doesn't has associated icon
  String? get icon => keymaps[_id]?.icon;

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
