export type EventPayload =
  | RawKeyEvent
  | MouseButtonEvent
  | MouseMoveEvent
  | MouseWheelEvent;

export interface RawKeyEvent {
  type: "KeyEvent";
  pressed: boolean;
  name: string;
}

export interface MouseButtonEvent {
  type: "MouseButtonEvent";
  pressed: boolean;
  button: MouseButton;
}

export interface MouseMoveEvent {
  type: "MouseMoveEvent";
  x: number;
  y: number;
}

export interface MouseWheelEvent {
  type: "MouseWheelEvent";
  delta_x: number;
  delta_y: number;
}

export type MouseButton =
  | "Left"
  | "Right"
  | "Middle"
  | "Back"
  | "Forward"
  | "Other";

export const RawKey = {
  // ───────────── Modifiers ─────────────
  ShiftLeft: "ShiftLeft",
  ShiftRight: "ShiftRight",
  ControlLeft: "ControlLeft",
  ControlRight: "ControlRight",
  Alt: "Alt",
  MetaLeft: "MetaLeft",
  MetaRight: "MetaRight",
  CapsLock: "CapsLock",
  Function: "Function",

  // ───────────── Navigation ─────────────
  UpArrow: "UpArrow",
  DownArrow: "DownArrow",
  LeftArrow: "LeftArrow",
  RightArrow: "RightArrow",
  Home: "Home",
  End: "End",
  PageUp: "PageUp",
  PageDown: "PageDown",
  Insert: "Insert",
  Delete: "Delete",

  // ───────────── Editing / Control ─────────────
  Return: "Return",
  KpReturn: "KpReturn",
  Tab: "Tab",
  Backspace: "Backspace",
  Escape: "Escape",
  Space: "Space",
  PrintScreen: "PrintScreen",
  ScrollLock: "ScrollLock",
  Pause: "Pause",
  NumLock: "NumLock",

  // ───────────── Function keys ─────────────
  F1: "F1",
  F2: "F2",
  F3: "F3",
  F4: "F4",
  F5: "F5",
  F6: "F6",
  F7: "F7",
  F8: "F8",
  F9: "F9",
  F10: "F10",
  F11: "F11",
  F12: "F12",
  // F13: "F13", 
  // F14: "F14", 
  // F15: "F15",
  // F16: "F16", 
  // F17: "F17", 
  // F18: "F18",
  // F19: "F19", 
  // F20: "F20", 
  // F21: "F21",
  // F22: "F22", 
  // F23: "F23", 
  // F24: "F24",

  // ───────────── Number row ─────────────
  Num1: "Num1",
  Num2: "Num2",
  Num3: "Num3",
  Num4: "Num4",
  Num5: "Num5",
  Num6: "Num6",
  Num7: "Num7",
  Num8: "Num8",
  Num9: "Num9",
  Num0: "Num0",

  // ───────────── Letters ─────────────
  KeyA: "KeyA",
  KeyB: "KeyB",
  KeyC: "KeyC",
  KeyD: "KeyD",
  KeyE: "KeyE",
  KeyF: "KeyF",
  KeyG: "KeyG",
  KeyH: "KeyH",
  KeyI: "KeyI",
  KeyJ: "KeyJ",
  KeyK: "KeyK",
  KeyL: "KeyL",
  KeyM: "KeyM",
  KeyN: "KeyN",
  KeyO: "KeyO",
  KeyP: "KeyP",
  KeyQ: "KeyQ",
  KeyR: "KeyR",
  KeyS: "KeyS",
  KeyT: "KeyT",
  KeyU: "KeyU",
  KeyV: "KeyV",
  KeyW: "KeyW",
  KeyX: "KeyX",
  KeyY: "KeyY",
  KeyZ: "KeyZ",

  // ───────────── Punctuation ─────────────
  BackQuote: "BackQuote",
  Minus: "Minus",
  Equal: "Equal",
  LeftBracket: "LeftBracket",
  RightBracket: "RightBracket",
  BackSlash: "BackSlash",
  SemiColon: "SemiColon",
  Quote: "Quote",
  Comma: "Comma",
  Dot: "Dot",
  Slash: "Slash",

  // ───────────── Numpad ─────────────
  Kp0: "Kp0",
  Kp1: "Kp1",
  Kp2: "Kp2",
  Kp3: "Kp3",
  Kp4: "Kp4",
  Kp5: "Kp5",
  Kp6: "Kp6",
  Kp7: "Kp7",
  Kp8: "Kp8",
  Kp9: "Kp9",
  KpPlus: "KpPlus",
  KpMinus: "KpMinus",
  KpMultiply: "KpMultiply",
  KpDivide: "KpDivide",
  KpDecimal: "KpDecimal",
  KpEqual: "KpEqual",
  KpComma: "KpComma",

  // ───────────── Media ─────────────
  VolumeUp: "VolumeUp",
  VolumeDown: "VolumeDown",
  VolumeMute: "VolumeMute",

  // ───────────── Mouse (Virtual) ─────────────
  Left: "Left",
  Middle: "Middle",
  Right: "Right",
  Back: "Back",
  Forward: "Forward",
  Drag: "Drag",
  ScrollUp: "ScrollUp",
  ScrollDown: "ScrollDown",
} as const;

export type RawKeyValue = typeof RawKey[keyof typeof RawKey];
export const MappedKeys = new Set<string>(Object.values(RawKey));

export const MODIFIERS = new Set<string>([
  RawKey.ShiftLeft,
  RawKey.ShiftRight,
  RawKey.ControlLeft,
  RawKey.ControlRight,
  RawKey.Alt,
  RawKey.MetaLeft,
  RawKey.MetaRight,
  RawKey.Function,
]);

export class KeyEvent {
  name: string;
  pressedCount: number;
  lastPressedAt: number;

  constructor(name: string) {
    this.name = name;
    this.pressedCount = 1;
    this.lastPressedAt = Date.now();
  }

  press() {
    this.pressedCount += 1;
    this.lastPressedAt = Date.now();
  }

  isModifier(): boolean {
    return MODIFIERS.has(this.name);
  }

  isNumpad(): boolean {
    return this.name.startsWith("Kp");
  }

  isArrow(): boolean {
    return this.name.endsWith("Arrow");
  }

  in(set: string[]): boolean {
    return set.includes(this.name);
  }
}