export class Key {
    name: string;
    pressedCount: number;
    lastPressedAt: number;

    constructor(name: string) {
        this.name = name;
        this.pressedCount = 1;
        this.lastPressedAt = Date.now();
    }
}

const MODIFIERS = [
    "Shift",
    "Ctrl",
    "Alt",
    "Meta",
    "Caps Lock",
    "Fn",
];
const NAVIGATION = [
    "↑",
    "↓",
    "←",
    "→",
    "Home",
    "End",
    "Page Up",
    "Page Down",
    "Insert",
    "Delete",
];
const EDITING = [
    "Enter",
    "Num Enter",
    "Tab",
    "Backspace",
    "Esc",
    "Space",
    "Print Screen",
    "Scroll Lock",
    "Pause",
    "Num Lock",
];
const FUNCTION = [
    "F1", "F2", "F3",
    "F4", "F5", "F6",
    "F7", "F8", "F9",
    "F10", "F11", "F12",
];
const NUMBERS = [
    "1", "2", "3",
    "4", "5", "6",
    "7", "8", "9",
    "0",
];
const LETTERS = [
    "A", "B", "C",
    "D", "E", "F",
    "G", "H", "I",
    "J", "K", "L",
    "M", "N", "O",
    "P", "Q", "R",
    "S", "T", "U",
    "V", "W", "X",
    "Y", "Z",
];
const PUNCTUATION = [
    "`",
    "-",
    "=",
    "[",
    "]",
    "\\",
    ";",
    "'",
    ",",
    ".",
    "/",
];
const NUMPAD = [
    "Num 0", "Num 1", "Num 2",
    "Num 3", "Num 4", "Num 5",
    "Num 6", "Num 7", "Num 8",
    "Num 9",
    "Num +",
    "Num -",
    "Num *",
    "Num /",
    "Num .",
    "Num =",
    "Num ,",
];
const MEDIA = [
    "Volume +",
    "Volume -",
    "Mute",
];
const SYSTEM_LEGACY = [
    "Menu",
    "Help",
    "Sleep",
    "Select",
    "Execute",
    "Print",
    "Clear",
    "Cancel",
    "Separator",
];
const REGSISTERED = [
    ...MODIFIERS,
    ...NAVIGATION,
    ...EDITING,
    ...FUNCTION,
    ...NUMBERS,
    ...LETTERS,
    ...PUNCTUATION,
    ...NUMPAD,
    ...MEDIA,
    ...SYSTEM_LEGACY,
]