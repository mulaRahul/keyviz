import type { KeyboardLayoutDef } from "./types";

const fr: KeyboardLayoutDef = {
    id: "fr",
    name: "French (AZERTY)",
    overrides: {
        BackQuote: { label: "\u00B2", symbol: "\u00B2" },
        Num1: { label: "&", symbol: "1" },
        Num2: { label: "\u00E9", symbol: "2" },
        Num3: { label: "\"", symbol: "3" },
        Num4: { label: "'", symbol: "4" },
        Num5: { label: "(", symbol: "5" },
        Num6: { label: "-", symbol: "6" },
        Num7: { label: "\u00E8", symbol: "7" },
        Num8: { label: "_", symbol: "8" },
        Num9: { label: "\u00E7", symbol: "9" },
        Num0: { label: "\u00E0", symbol: "0" },
        Minus: { label: ")", symbol: "\u00B0" },
        KeyQ: { label: "A" },
        KeyW: { label: "Z" },
        KeyA: { label: "Q" },
        KeyZ: { label: "W" },
        LeftBracket: { label: "^", symbol: "\u00A8" },
        RightBracket: { label: "$", symbol: "\u00A3" },
        SemiColon: { label: "M", symbol: undefined, category: "letter" },
        Quote: { label: "\u00F9", symbol: "%" },
        BackSlash: { label: "*", symbol: "\u00B5" },
        KeyM: { label: ",", symbol: "?", category: "punctuation" },
        Comma: { label: ";", symbol: "." },
        Dot: { label: ":", symbol: "/" },
        Slash: { label: "!", symbol: "\u00A7" },
        IntlBackslash: { label: "<", symbol: ">" },
    },
};

export default fr;
