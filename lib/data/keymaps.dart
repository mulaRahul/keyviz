const String alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const Map<String, String> numbers = {
  "1": "!",
  "2": "@",
  "3": "#",
  "4": "\$",
  "5": "%",
  "6": "^",
  "7": "&",
  "8": "*",
  "9": "(",
  "0": ")"
};
const Map<String, String> modifiers = {
  "LCONTROL": "Ctrl",
  "RCONTROL": "Ctrl",
  "LSHIFT": "Shift",
  "RSHIFT": "Shift",
  "LMENU": "Alt",
  "RMENU": "Alt",
  "LWIN": "Win",
  "TAB": "Tab",
};
const Map<String, String> oemKeySymbols = {
  "OEM_MINUS": "_",
  "OEM_PLUS": "+",
  "OEM_1": ":",
  "OEM_2": "?",
  "OEM_3": "~",
  "OEM_4": "{",
  "OEM_5": "|",
  "OEM_6": "}",
  "OEM_7": '"',
  "OEM_COMMA": "<",
  "OEM_PERIOD": ">",
};
const Map<String, String> oemKeys = {
  "OEM_MINUS": "-",
  "OEM_PLUS": "=",
  "OEM_1": ";",
  "OEM_2": "/",
  "OEM_3": "`",
  "OEM_4": "[",
  "OEM_5": r"\",
  "OEM_6": "]",
  "OEM_7": "'",
  "OEM_COMMA": ",",
  "OEM_PERIOD": ".",
};
const Map<String, String> navKeys = {
  "END": "End",
  "APPS": "Apps",
  "HOME": "Home",
  "INSERT": "Ins",
  "ESCAPE": "Esc",
  "DELETE": "Del",
  "NEXT": "Pg Dn",
  "PRIOR": "Pg Up",
  "PAUSE": "Pause",
  "SNAPSHOT": "Prnt Sc",
};
const Map<String, String> arrowKeys = {
  "UP": "↑",
  "LEFT": "←",
  "RIGHT": "→",
  "DOWN": "↓",
};
const Map<String, String> lockKeys = {
  "CAPITAL": "Caps Lock",
  "SCROLL": "Scroll Lock",
  "NUMLOCK": "Num Lock",
};
const Map<String, String> normalKeys = {
  "SPACE": "Space",
  "RETURN": "Enter",
  "BACK": "Backspace",
};
final Map<String, String> functionKeys = {
  'F1': 'F1',
  'F2': 'F2',
  'F3': 'F3',
  'F4': 'F4',
  'F5': 'F5',
  'F6': 'F6',
  'F7': 'F7',
  'F8': 'F8',
  'F9': 'F9',
  'F10': 'F10',
  'F11': 'F11',
  'F12': 'F12',
  'F13': 'F13',
  'F14': 'F14',
  'F15': 'F15',
  'F16': 'F16',
  'F17': 'F17',
  'F18': 'F18',
  'F19': 'F19',
  'F20': 'F20',
  'F21': 'F21',
  'F22': 'F22',
  'F23': 'F23',
  'F24': 'F24',
};
final Map<String, String> numpadKeys = {
  "ADD": "+",
  "CLEAR": " ",
  "DIVIDE": "/",
  "DECIMAL": ".",
  "SUBTRACT": "-",
  "MULTIPLY": "*",
  "NUMPAD0": "ins",
  "NUMPAD1": "end",
  "NUMPAD2": "▾",
  "NUMPAD3": "pg dn",
  "NUMPAD4": "◂",
  "NUMPAD5": " ",
  "NUMPAD6": "▸",
  "NUMPAD7": "home",
  "NUMPAD8": "▴",
  "NUMPAD9": "pg up",
};
final Map<String, String> allKeys = {};
void initKeymaps() {
  allKeys.addAll(normalKeys);
  allKeys.addAll(modifiers);
  allKeys.addAll(navKeys);
  allKeys.addAll(oemKeys);
  allKeys.addAll(lockKeys);
  allKeys.addAll(arrowKeys);
  allKeys.addAll(functionKeys);
  allKeys.addAll(numpadKeys);
}
