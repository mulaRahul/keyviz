import { platform } from "@tauri-apps/plugin-os";
import { MouseLeftClickIcon, MouseMiddleClickIcon, MouseRightClickIcon, MouseRightDragIcon, MouseScrollDownIcon, MouseScrollUpIcon, ReturnIcon } from "@/components/ui/icons";
import { ArrowBigUpDashIcon, ArrowBigUpIcon, ArrowDownIcon, ArrowDownToLineIcon, ArrowLeftIcon, ArrowLeftRightIcon, ArrowRightIcon, ArrowRightToLineIcon, ArrowUpIcon, ArrowUpToLineIcon, ChevronUpIcon, CircleArrowOutUpLeftIcon, CommandIcon, DeleteIcon, Grid2X2Icon, ImageIcon, LockIcon, LucideIcon, MouseIcon, MoveDownRightIcon, MoveUpLeftIcon, OptionIcon, PauseIcon, SpaceIcon, SparkleIcon, Volume2Icon, VolumeXIcon } from "lucide-react";

// ───────────── Platform Logic ─────────────
const currentPlatform = platform();

interface SwitchPlatformConfig<T> {
    windows: T;
    macos: T;
    linux?: T;
}

function switchPlatform<T>(config: SwitchPlatformConfig<T>): T {
    if (currentPlatform === 'macos') {
        return config.macos;
    } else if (currentPlatform === 'linux' && config.linux !== undefined) {
        return config.linux!;
    }
    return config.windows;
}

// ───────────── Key mapping ─────────────
export interface DisplayData {
    // textual representation
    label: string;
    // short label if any like ctrl for control
    shortLabel?: string;
    // glyph representation if any like ⌃ for control
    glyph?: string;
    // secondary symbol if any like @ for digit 2
    symbol?: string;
    // icon path if can be represented with iconography
    icon?: LucideIcon;
    // category
    category?: "modifier" | "letter" | "digit" | "punctuation" | "function" | "arrow" | "navigation" | "special" | "numpad" | "mouse";
}

// We use the string names from the provided Rust enum as keys
export const keymaps: Record<string, DisplayData> = {
    // ───────────── Function keys ─────────────
    F1: { label: "F1", category: "function" },
    F2: { label: "F2", category: "function" },
    F3: { label: "F3", category: "function" },
    F4: { label: "F4", category: "function" },
    F5: { label: "F5", category: "function" },
    F6: { label: "F6", category: "function" },
    F7: { label: "F7", category: "function" },
    F8: { label: "F8", category: "function" },
    F9: { label: "F9", category: "function" },
    F10: { label: "F10", category: "function" },
    F11: { label: "F11", category: "function" },
    F12: { label: "F12", category: "function" },
    // ───────────── Navigation ─────────────
    PrintScreen: {
        label: "print screen",
        shortLabel: "prt scrn",
        icon: ImageIcon,
    },
    Pause: {
        label: "pause break",
        shortLabel: "pause",
        icon: PauseIcon,
    },
    Backspace: {
        label: switchPlatform({
            windows: "backspace",
            macos: "delete",
        }),
        shortLabel: switchPlatform({
            windows: "back",
            macos: "del",
        }),
        glyph: "⌫",
        icon: DeleteIcon,
        category: "special",
    },
    Tab: {
        label: "tab",
        glyph: "⇆",
        icon: ArrowLeftRightIcon,
        category: "special",
    },
    Space: {
        label: "space",
        glyph: "⎵",
        icon: SpaceIcon,
    },
    Return: {
        label: switchPlatform({
            windows: "enter",
            macos: "return",
        }),
        glyph: "↩",
        icon: ReturnIcon,
        category: "special",
    },
    Apps: {
        label: "menu",
        glyph: "☰",
    },
    Insert: {
        label: "insert",
        shortLabel: "ins",
        glyph: "⇥",
        icon: ArrowRightToLineIcon,
        category: "special",
    },
    Delete: {
        label: "delete",
        shortLabel: "del",
        glyph: "⌦",
        icon: DeleteIcon,
        category: "special",
    },
    Home: {
        label: "home",
        glyph: "⇱",
        icon: MoveUpLeftIcon,
        category: "navigation",
    },
    End: {
        label: "end",
        glyph: "⇲",
        icon: MoveDownRightIcon,
        category: "navigation",
    },
    PageUp: {
        label: "page up",
        shortLabel: "pg up",
        glyph: "⤒",
        icon: ArrowUpToLineIcon,
        category: "navigation",
    },
    PageDown: {
        label: "page down",
        shortLabel: "pg dn",
        glyph: "⤓",
        icon: ArrowDownToLineIcon,
        category: "navigation",
    },
    UpArrow: {
        label: "up",
        glyph: "↑",
        icon: ArrowUpIcon,
        category: "arrow",
    },
    DownArrow: {
        label: "down",
        glyph: "↓",
        icon: ArrowDownIcon,
        category: "arrow",
    },
    LeftArrow: {
        label: "left",
        glyph: "←",
        icon: ArrowLeftIcon,
        category: "arrow",
    },
    RightArrow: {
        label: "right",
        glyph: "→",
        icon: ArrowRightIcon,
        category: "arrow",
    },
    CapsLock: {
        label: "caps lock",
        glyph: "⇪",
        icon: ArrowBigUpDashIcon,
    },
    ScrollLock: {
        label: "scroll lock",
        glyph: "🖱",
        icon: MouseIcon,
    },
    NumLock: {
        label: "num lock",
        icon: LockIcon,
    },
    Escape: {
        label: "escape",
        shortLabel: "esc",
        glyph: "⎋",
        icon: CircleArrowOutUpLeftIcon,
        category: "special",
    },

    // ───────────── Digits ──────────────
    Num1: {
        label: "1",
        symbol: "!",
        category: "digit",
    },
    Num2: {
        label: "2",
        symbol: "@",
        category: "digit",
    },
    Num3: {
        label: "3",
        symbol: "#",
        category: "digit",
    },
    Num4: {
        label: "4",
        symbol: "$",
        category: "digit",
    },
    Num5: {
        label: "5",
        symbol: "%",
        category: "digit",
    },
    Num6: {
        label: "6",
        symbol: "^",
        category: "digit",
    },
    Num7: {
        label: "7",
        symbol: "&",
        category: "digit",
    },
    Num8: {
        label: "8",
        symbol: "*",
        category: "digit",
    },
    Num9: {
        label: "9",
        symbol: "(",
        category: "digit",
    },
    Num0: {
        label: "0",
        symbol: ")",
        category: "digit",
    },
    // ───────────── Letters ─────────────
    KeyA: { label: "A", category: "letter" },
    KeyB: { label: "B", category: "letter" },
    KeyC: { label: "C", category: "letter" },
    KeyD: { label: "D", category: "letter" },
    KeyE: { label: "E", category: "letter" },
    KeyF: { label: "F", category: "letter" },
    KeyG: { label: "G", category: "letter" },
    KeyH: { label: "H", category: "letter" },
    KeyI: { label: "I", category: "letter" },
    KeyJ: { label: "J", category: "letter" },
    KeyK: { label: "K", category: "letter" },
    KeyL: { label: "L", category: "letter" },
    KeyM: { label: "M", category: "letter" },
    KeyN: { label: "N", category: "letter" },
    KeyO: { label: "O", category: "letter" },
    KeyP: { label: "P", category: "letter" },
    KeyQ: { label: "Q", category: "letter" },
    KeyR: { label: "R", category: "letter" },
    KeyS: { label: "S", category: "letter" },
    KeyT: { label: "T", category: "letter" },
    KeyU: { label: "U", category: "letter" },
    KeyV: { label: "V", category: "letter" },
    KeyW: { label: "W", category: "letter" },
    KeyX: { label: "X", category: "letter" },
    KeyY: { label: "Y", category: "letter" },
    KeyZ: { label: "Z", category: "letter" },
    // ───────────── Punctuation ─────────────
    BackQuote: {
        label: "`",
        symbol: "~",
        category: "punctuation",
    },
    Minus: {
        label: "-",
        symbol: "_",
        category: "punctuation",
    },
    Equal: {
        label: "=",
        symbol: "+",
        category: "punctuation",
    },
    LeftBracket: {
        label: "[",
        symbol: "{",
        category: "punctuation",
    },
    RightBracket: {
        label: "]",
        symbol: "}",
        category: "punctuation",
    },
    BackSlash: {
        label: "\\",
        symbol: "|",
        category: "punctuation",
    },
    SemiColon: {
        label: ";",
        symbol: ":",
        category: "punctuation",
    },
    Quote: {
        label: "'",
        symbol: "\"",
        category: "punctuation",
    },
    Comma: {
        label: ",",
        symbol: "<",
        category: "punctuation",
    },
    Dot: {
        label: ".",
        symbol: ">",
        category: "punctuation",
    },
    Slash: {
        label: "?",
        symbol: "/",
        category: "punctuation",
    },
    // ───────────── Numpad ─────────────
    KpDivide: { label: "/", category: "punctuation" },
    KpMultiply: { label: "*", category: "punctuation" },
    KpMinus: { label: "-", category: "punctuation" },
    KpPlus: { label: "+", category: "punctuation" },
    KpEqual: { label: "=", category: "punctuation" },
    KpComma: { label: ",", category: "punctuation" },
    KpReturn: {
        label: "Enter",
        glyph: "↩",
        category: "numpad",
    },
    KpDecimal: {
        label: ".",
        symbol: "del",
        category: "numpad",
    },
    Kp0: {
        label: "0",
        symbol: "ins",
        category: "numpad",
    },
    Kp1: {
        label: "1",
        symbol: "end",
        category: "numpad",
    },
    Kp2: {
        label: "2",
        symbol: "▼",
        category: "numpad",
    },
    Kp3: {
        label: "3",
        symbol: "pg dn",
        category: "numpad",
    },
    Kp4: {
        label: "4",
        symbol: "◀",
        category: "numpad",
    },
    Kp5: {
        label: "5",
        symbol: " ",
        category: "numpad",
    },
    Kp6: {
        label: "6",
        symbol: "▶",
        category: "numpad",
    },
    Kp7: {
        label: "7",
        symbol: "home",
        category: "numpad",
    },
    Kp8: {
        label: "8",
        symbol: "▲",
        category: "numpad",
    },
    Kp9: {
        label: "9",
        symbol: "pg up",
        category: "numpad",
    },
    // ───────────── Media ─────────────
    VolumeUp: {
        label: "volume up",
        shortLabel: "vol +",
        icon: Volume2Icon,
    },
    VolumeDown: {
        label: "volume down",
        shortLabel: "vol -",
        icon: Volume2Icon,
    },
    VolumeMute: {
        label: "mute",
        icon: VolumeXIcon,
    },

    // ───────────── Mouse Events ─────────────
    Left: {
        label: "left click",
        shortLabel: "left",
        icon: MouseLeftClickIcon,
        category: "mouse",
    },
    Middle: {
        label: "middle click",
        shortLabel: "middle",
        icon: MouseMiddleClickIcon,
        category: "mouse",
    },
    Right: {
        label: "right click",
        shortLabel: "right",
        icon: MouseRightClickIcon,
        category: "mouse",
    },
    Drag: {
        label: "drag",
        icon: MouseRightDragIcon,
        category: "mouse",
    },
    ScrollUp: {
        label: "scroll up",
        shortLabel: "scroll",
        icon: MouseScrollUpIcon,
        category: "mouse",
    },
    ScrollDown: {
        label: "scroll down",
        shortLabel: "scroll",
        icon: MouseScrollDownIcon,
        category: "mouse",
    },
};

// ───────────── Apply Mappings for Modifiers ─────────────

// Control
['ControlLeft', 'ControlRight'].forEach((key) => {
    keymaps[key] = {
        label: "control",
        shortLabel: "ctrl",
        glyph: "⌃",
        icon: ChevronUpIcon,
        category: "modifier",
    };
});

// Meta
['MetaLeft', 'MetaRight'].forEach((key) => {
    keymaps[key] = switchPlatform({
        windows: {
            label: "win",
            glyph: "\u229E",
            icon: Grid2X2Icon,
            category: "modifier",
        },
        macos: {
            label: "command",
            shortLabel: "cmd",
            glyph: "⌘",
            icon: CommandIcon,
            category: "modifier",
        },
        linux: {
            label: "Meta",
            glyph: "✦",
            icon: SparkleIcon,
            category: "modifier",
        },
    });
});

// Alt
['Alt'].forEach((key) => {
    keymaps[key] = {
        label: switchPlatform({
            windows: "alt",
            macos: "option",
        }),
        shortLabel: switchPlatform({
            windows: "alt",
            macos: "opt",
        }),
        glyph: "⌥",
        icon: OptionIcon,
        category: "modifier",
    };
});

// Shift
['ShiftLeft', 'ShiftRight'].forEach((key) => {
    keymaps[key] = {
        label: "shift",
        glyph: "⇧",
        icon: ArrowBigUpIcon,
        category: "modifier",
    };
});