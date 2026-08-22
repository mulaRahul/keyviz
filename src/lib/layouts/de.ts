import type { KeyboardLayoutDef } from "./types";

const de: KeyboardLayoutDef = {
    id: "de",
    name: "German (QWERTZ)",
    overrides: {
        BackQuote: { label: "^", symbol: "\u00B0" },
        Num1: { symbol: "!" },
        Num2: { symbol: "\"" },
        Num3: { symbol: "\u00A7" },
        Num4: { symbol: "$" },
        Num5: { symbol: "%" },
        Num6: { symbol: "&" },
        Num7: { symbol: "/" },
        Num8: { symbol: "(" },
        Num9: { symbol: ")" },
        Num0: { symbol: "=" },
        Minus: { label: "\u00DF", symbol: "?" },
        Equal: { label: "\u00B4", symbol: "\u0060" },
        KeyY: { label: "Z" },
        KeyZ: { label: "Y" },
        LeftBracket: { label: "\u00FC", symbol: "\u00DC", category: "letter" },
        RightBracket: { label: "+", symbol: "*" },
        SemiColon: { label: "\u00F6", symbol: "\u00D6", category: "letter" },
        Quote: { label: "\u00E4", symbol: "\u00C4", category: "letter" },
        BackSlash: { label: "#", symbol: "'" },
        Comma: { label: ",", symbol: ";" },
        Dot: { label: ".", symbol: ":" },
        Slash: { label: "-", symbol: "_" },
        IntlBackslash: { label: "<", symbol: ">" },
    },
};

export default de;
