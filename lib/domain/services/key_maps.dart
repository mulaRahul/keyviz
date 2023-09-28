import 'dart:io';

import 'package:flutter/services.dart';

import 'package:keyviz/config/assets.dart';
import 'package:keyviz/domain/services/raw_keyboard_mouse.dart';

// utility class to encapsulate key data
class KeyMapData {
  const KeyMapData({
    required this.label,
    this.shortLabel,
    this.glyph,
    this.symbol,
    this.icon,
  });

  // textual representation
  final String label;

  // short label if any like ctrl for control
  final String? shortLabel;

  // glyph representation if any like liek ⌃ for control
  final String? glyph;

  // secondary symbol if any like @ for digit 2
  final String? symbol;

  // icon path if can be represented with iconography
  final String? icon;
}

final keymaps = <int, KeyMapData>{
  for (final control in [
    LogicalKeyboardKey.controlLeft.keyId,
    LogicalKeyboardKey.controlRight.keyId
  ])
    control: const KeyMapData(
      label: "control",
      shortLabel: "ctrl",
      glyph: "⌃",
      icon: KeyIcons.control,
    ),
  for (final meta in [
    LogicalKeyboardKey.metaLeft.keyId,
    LogicalKeyboardKey.metaRight.keyId
  ])
    meta: switchPlatform<KeyMapData>(
      windows: const KeyMapData(
        label: "win",
        symbol: "\u{229E}",
        icon: KeyIcons.meta,
      ),
      macos: const KeyMapData(
        label: "command",
        shortLabel: "cmd",
        symbol: "⌘",
        icon: KeyIcons.macMeta,
      ),
      linux: const KeyMapData(
        label: "Meta",
        symbol: "✦",
        icon: KeyIcons.meta,
      ),
    ),
  for (final alt in [
    LogicalKeyboardKey.altLeft.keyId,
    LogicalKeyboardKey.altRight.keyId
  ])
    alt: KeyMapData(
      label: switchPlatform<String>(
        windows: "alt",
        macos: "option",
      ),
      shortLabel: switchPlatform<String>(
        windows: "alt",
        macos: "opt",
      ),
      glyph: "⌥",
      icon: KeyIcons.alt,
    ),
  for (final shift in [
    LogicalKeyboardKey.shiftLeft.keyId,
    LogicalKeyboardKey.shiftRight.keyId
  ])
    shift: const KeyMapData(
      label: "shift",
      glyph: "⇧",
      icon: KeyIcons.shift,
    ),
  LogicalKeyboardKey.printScreen.keyId: const KeyMapData(
    label: "print screen",
    shortLabel: "prt scrn",
    icon: KeyIcons.printScreen,
  ),
  LogicalKeyboardKey.pause.keyId: const KeyMapData(
    label: "pause break",
    shortLabel: "pause",
    icon: KeyIcons.pause,
  ),
  LogicalKeyboardKey.backspace.keyId: KeyMapData(
    label: switchPlatform<String>(
      windows: "backspace",
      macos: "delete",
    ),
    shortLabel: switchPlatform<String>(
      windows: "back",
      macos: "del",
    ),
    glyph: "⌫",
    icon: KeyIcons.backspace,
  ),
  LogicalKeyboardKey.tab.keyId: const KeyMapData(
    label: "tab",
    glyph: "⇆",
    icon: KeyIcons.tab,
  ),
  LogicalKeyboardKey.space.keyId: const KeyMapData(
    label: "space",
    glyph: "⎵",
    icon: KeyIcons.space,
  ),
  LogicalKeyboardKey.enter.keyId: KeyMapData(
    label: switchPlatform<String>(
      windows: "enter",
      macos: "return",
    ),
    glyph: "↩",
    icon: KeyIcons.enter,
  ),
  LogicalKeyboardKey.contextMenu.keyId: const KeyMapData(
    label: "menu",
    glyph: "☰",
    icon: KeyIcons.contextMenu,
  ),
  LogicalKeyboardKey.insert.keyId: const KeyMapData(
    label: "insert",
    shortLabel: "ins",
    glyph: "⇥",
    icon: KeyIcons.insert,
  ),
  LogicalKeyboardKey.delete.keyId: KeyMapData(
    label: switchPlatform<String>(
      windows: "delete",
      macos: "forward delete",
    ),
    shortLabel: switchPlatform<String>(
      windows: "del",
      macos: "frw del",
    ),
    glyph: "⌦",
    icon: KeyIcons.insert,
  ),
  LogicalKeyboardKey.home.keyId: const KeyMapData(
    label: "home",
    glyph: "⇱",
    icon: KeyIcons.home,
  ),
  LogicalKeyboardKey.end.keyId: const KeyMapData(
    label: "end",
    glyph: "⇲",
    icon: KeyIcons.end,
  ),
  LogicalKeyboardKey.pageUp.keyId: const KeyMapData(
    label: "page up",
    shortLabel: "pg up",
    glyph: "⤒",
    icon: KeyIcons.pageUp,
  ),
  LogicalKeyboardKey.pageDown.keyId: const KeyMapData(
    label: "page down",
    shortLabel: "pg dn",
    glyph: "⤓",
    icon: KeyIcons.pageDown,
  ),
  LogicalKeyboardKey.arrowUp.keyId: const KeyMapData(
    label: "up",
    glyph: "↑",
    icon: KeyIcons.arrowUp,
  ),
  LogicalKeyboardKey.arrowDown.keyId: const KeyMapData(
    label: "down",
    glyph: "↓",
    icon: KeyIcons.arrowDown,
  ),
  LogicalKeyboardKey.arrowLeft.keyId: const KeyMapData(
    label: "left",
    glyph: "←",
    icon: KeyIcons.arrowLeft,
  ),
  LogicalKeyboardKey.arrowRight.keyId: const KeyMapData(
    label: "right",
    glyph: "→",
    icon: KeyIcons.arrowRight,
  ),
  LogicalKeyboardKey.capsLock.keyId: const KeyMapData(
    label: "caps lock",
    glyph: "⇪",
    icon: KeyIcons.capsLock,
  ),
  LogicalKeyboardKey.scrollLock.keyId: const KeyMapData(
    label: "scroll lock",
    symbol: "🖱",
    icon: KeyIcons.scrollLock,
  ),
  LogicalKeyboardKey.numLock.keyId: const KeyMapData(
    label: "num lock",
    icon: KeyIcons.numLock,
  ),
  LogicalKeyboardKey.escape.keyId: const KeyMapData(
    label: "escape",
    shortLabel: "esc",
    glyph: "⎋",
    icon: KeyIcons.escape,
  ),
  LogicalKeyboardKey.backquote.keyId: const KeyMapData(
    label: "`",
    symbol: "~",
  ),
  LogicalKeyboardKey.digit1.keyId: const KeyMapData(
    label: "1",
    symbol: "!",
  ),
  LogicalKeyboardKey.digit2.keyId: const KeyMapData(
    label: "2",
    symbol: "@",
  ),
  LogicalKeyboardKey.digit3.keyId: const KeyMapData(
    label: "3",
    symbol: "#",
  ),
  LogicalKeyboardKey.digit4.keyId: const KeyMapData(
    label: "4",
    symbol: "\$",
  ),
  LogicalKeyboardKey.digit5.keyId: const KeyMapData(
    label: "5",
    symbol: "%",
  ),
  LogicalKeyboardKey.digit6.keyId: const KeyMapData(
    label: "6",
    symbol: "^",
  ),
  LogicalKeyboardKey.digit7.keyId: const KeyMapData(
    label: "7",
    symbol: "&",
  ),
  LogicalKeyboardKey.digit8.keyId: const KeyMapData(
    label: "8",
    symbol: "*",
  ),
  LogicalKeyboardKey.digit9.keyId: const KeyMapData(
    label: "9",
    symbol: "(",
  ),
  LogicalKeyboardKey.digit0.keyId: const KeyMapData(
    label: "0",
    symbol: ")",
  ),
  LogicalKeyboardKey.minus.keyId: const KeyMapData(
    label: "-",
    symbol: "_",
  ),
  LogicalKeyboardKey.equal.keyId: const KeyMapData(
    label: "=",
    symbol: "+",
  ),
  LogicalKeyboardKey.bracketLeft.keyId: const KeyMapData(
    label: "[",
    symbol: "{",
  ),
  LogicalKeyboardKey.bracketRight.keyId: const KeyMapData(
    label: "]",
    symbol: "}",
  ),
  LogicalKeyboardKey.backslash.keyId: const KeyMapData(
    label: "\\",
    symbol: "|",
  ),
  LogicalKeyboardKey.semicolon.keyId: const KeyMapData(
    label: ";",
    symbol: ":",
  ),
  LogicalKeyboardKey.quoteSingle.keyId: const KeyMapData(
    label: "'",
    symbol: "\"",
  ),
  LogicalKeyboardKey.comma.keyId: const KeyMapData(
    label: ",",
    symbol: "<",
  ),
  LogicalKeyboardKey.period.keyId: const KeyMapData(
    label: ".",
    symbol: ">",
  ),
  LogicalKeyboardKey.question.keyId: const KeyMapData(
    label: "?",
    symbol: "/",
  ),
  LogicalKeyboardKey.numpadDivide.keyId: const KeyMapData(label: "/"),
  LogicalKeyboardKey.numpadMultiply.keyId: const KeyMapData(label: "*"),
  LogicalKeyboardKey.numpadSubtract.keyId: const KeyMapData(label: "-"),
  LogicalKeyboardKey.numpadAdd.keyId: const KeyMapData(label: "+"),
  LogicalKeyboardKey.numpadEnter.keyId: const KeyMapData(
    label: "Enter",
    glyph: "⏎",
  ),
  LogicalKeyboardKey.numpadDecimal.keyId: const KeyMapData(
    label: ".",
    symbol: "del",
  ),
  LogicalKeyboardKey.numpad0.keyId: const KeyMapData(
    label: "0",
    symbol: "ins",
  ),
  LogicalKeyboardKey.numpad1.keyId: const KeyMapData(
    label: "1",
    symbol: "end",
  ),
  LogicalKeyboardKey.numpad2.keyId: const KeyMapData(
    label: "2",
    symbol: "▼",
  ),
  LogicalKeyboardKey.numpad3.keyId: const KeyMapData(
    label: "3",
    symbol: "pg dn",
  ),
  LogicalKeyboardKey.numpad4.keyId: const KeyMapData(
    label: "4",
    symbol: "◀",
  ),
  LogicalKeyboardKey.numpad5.keyId: const KeyMapData(
    label: "5",
    symbol: " ",
  ),
  LogicalKeyboardKey.numpad6.keyId: const KeyMapData(
    label: "6",
    symbol: "▶",
  ),
  LogicalKeyboardKey.numpad7.keyId: const KeyMapData(
    label: "7",
    symbol: "home",
  ),
  LogicalKeyboardKey.numpad8.keyId: const KeyMapData(
    label: "8",
    symbol: "▲",
  ),
  LogicalKeyboardKey.numpad9.keyId: const KeyMapData(
    label: "9",
    symbol: "pg up",
  ),
  leftClickId: const KeyMapData(
    label: "left click",
    icon: KeyIcons.leftClick,
  ),
  rightClickId: const KeyMapData(
    label: "right click",
    // shortLabel: "click",
    icon: KeyIcons.rightClick,
  ),
  dragId: const KeyMapData(
    label: "drag",
    icon: KeyIcons.drag,
  ),
  scrollId: const KeyMapData(
    label: "scroll",
    glyph: "↕",
    icon: KeyIcons.scroll,
  ),
};

T switchPlatform<T>({
  required T windows,
  required T macos,
  T? linux,
}) {
  if (Platform.isMacOS) {
    return macos;
  } else if (Platform.isLinux && linux != null) {
    return linux;
  }
  return windows;
}
