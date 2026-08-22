import type { KeyboardLayoutDef } from "./types";

const colemak: KeyboardLayoutDef = {
    id: "colemak",
    name: "Colemak",
    overrides: {
        KeyE: { label: "F" },
        KeyR: { label: "P" },
        KeyT: { label: "G" },
        KeyY: { label: "J" },
        KeyU: { label: "L" },
        KeyI: { label: "U" },
        KeyO: { label: "Y" },
        KeyP: { label: ";", symbol: ":", category: "punctuation" },
        KeyS: { label: "R" },
        KeyD: { label: "S" },
        KeyF: { label: "T" },
        KeyG: { label: "D" },
        KeyJ: { label: "N" },
        KeyK: { label: "E" },
        KeyL: { label: "I" },
        SemiColon: { label: "O", symbol: undefined, category: "letter" },
        KeyN: { label: "K" },
        IntlBackslash: { label: "-", symbol: "_" },
    },
};

export default colemak;
