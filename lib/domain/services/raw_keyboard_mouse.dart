import 'package:flutter/services.dart';

// key id's for fake mouse events
const leftClickId = 0x00900000011;
const rightClickId = 0x00900000012;
const dragId = 0x00900000013;
const scrollId = 0x00900000014;

// an implementation of [RawKeyEventData] which is used
// to fake mouse events as keyboard events
class RawKeyEventDataMouse extends RawKeyEventData {
  const RawKeyEventDataMouse(this.id);

  final int id;

  @override
  KeyboardSide? getModifierSide(ModifierKey key) {
    return null;
  }

  @override
  bool isModifierPressed(ModifierKey key,
      {KeyboardSide side = KeyboardSide.any}) {
    return false;
  }

  @override
  String get keyLabel {
    switch (id) {
      case leftClickId:
        return "Left Click";

      case rightClickId:
        return "Right Click";

      case dragId:
        return "Drag";

      case scrollId:
        return "Scroll";
    }
    return '';
  }

  @override
  LogicalKeyboardKey get logicalKey => LogicalKeyboardKey(id);

  @override
  PhysicalKeyboardKey get physicalKey => PhysicalKeyboardKey(id);

  // mouse left button down/up
  const RawKeyEventDataMouse.leftClick() : id = leftClickId;

  // mouse right button down/up
  const RawKeyEventDataMouse.rightClick() : id = rightClickId;

  // mouse left/right button down and mouse moving
  const RawKeyEventDataMouse.drag() : id = dragId;

  // mouse wheel event
  const RawKeyEventDataMouse.scroll() : id = scrollId;
}
