import type { KeyboardLayoutDef } from "./types";

const es: KeyboardLayoutDef = {
    id: "es",
    name: "Spanish (Spain)",
    overrides: {
        BackQuote: { label: "\u00BA", symbol: "\u00AA" },
        Num2: { label: "2", symbol: '"' },
        Num3: { label: "3", symbol: "\u00B7" },
        Num6: { label: "6", symbol: "&" },
        Num7: { label: "7", symbol: "/" },
        Num8: { label: "8", symbol: "(" },
        Num9: { label: "9", symbol: ")" },
        Num0: { label: "0", symbol: "=" },
        Minus: { label: "'", symbol: "?" },
        Equal: { label: "\u00A1", symbol: "\u00BF" },
        LeftBracket: { label: "`", symbol: "^" },
        RightBracket: { label: "+", symbol: "*" },
        BackSlash: { label: "\u00E7", symbol: "}" },
        SemiColon: { label: "\u00F1", symbol: "\u00D1" },
        Quote: { label: "\u00B4", symbol: "\u00A8" },
        Comma: { label: ",", symbol: ";" },
        Dot: { label: ".", symbol: ":" },
        Slash: { label: "-", symbol: "_" },
    },
};

export default es;
