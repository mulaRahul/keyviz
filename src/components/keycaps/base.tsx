import { keymaps } from "@/lib/keymaps";
import { useKeyStyle } from "@/stores/key_style";
import { KeyEvent } from "@/types/event";
import { alignmentForRow } from "@/types/style";

export const KeycapBase = ({ event }: { event: KeyEvent }) => {
  const text = useKeyStyle((state) => state.text);
  const layout = useKeyStyle((state) => state.layout);
  const modifier = useKeyStyle((state) => state.modifier);
  const display = keymaps[event.name];

  const textColor = event.isModifier() && modifier.highlight ? modifier.textColor : text.color;
  const textStyle: React.CSSProperties = {
    color: textColor,
    lineHeight: 1.2,
    fontSize: text.size,
    textTransform: text.caps,
    fontVariantLigatures: "none",
    fontFeatureSettings: "\"liga\" 0, \"calt\" 0",
  };

  const label = text.variant === "text-short"
    ? display.shortLabel ?? display.label
    : display.label;

  const flexAlignment = alignmentForRow[text.alignment];

  // ───────────── With Icon ─────────────
  if (layout.showIcon && display.icon) {
    const Icon = display.icon;
    if (text.variant === "icon" || event.isArrow()) {
      return <div 
        className="w-full h-full flex"
        style={{ alignItems: flexAlignment.alignItems, justifyContent: flexAlignment.justifyContent }}
      >
        <Icon color={textColor} size={text.size * 0.8} />
      </div>;
    } else {
      const alignItems = event.isModifier()
        ? layout.iconAlignment
        // flip alignment for column
        : flexAlignment.justifyContent;
      return <div
        className="w-full h-full flex flex-col justify-between"
        style={{ alignItems }}
      >
        <Icon color={textColor} size={text.size * 0.5} />
        <div style={{ ...textStyle, fontSize: text.size * 0.5 }}>
          {label}
        </div>
      </div>;
    }
  }
  // ───────────── With Symbol ─────────────
  else if (layout.showSymbol && display.symbol) {
    return <div
      className="w-full h-full flex flex-col"
      style={{
        ...textStyle,
        lineHeight: 1.4,
        fontSize: text.size * 0.56,
        alignItems: flexAlignment.justifyContent,
        justifyContent: flexAlignment.alignItems
      }}
    >
      <span>{display.symbol}</span>
      <span className="font-semibold">{display.label}</span>
    </div>
  }
  // ───────────── Numpad ─────────────
  else if (event.isNumpad()) {
    return <div
      className="w-full h-full flex flex-col justify-between"
      style={{
        ...textStyle,
        fontSize: text.size * 0.5,
        alignItems: flexAlignment.alignItems,
        justifyContent: flexAlignment.justifyContent
      }}
    >
      <div>{label}</div>
      {
        display.symbol && <div>{display.symbol}</div>
      }
    </div>;
  }
  // ───────────── Text Only ─────────────
  return (
    <div
      className="w-full h-full flex"
      style={{ ...textStyle, alignItems: flexAlignment.alignItems, justifyContent: flexAlignment.justifyContent }}
    >
      {label}
    </div>
  );
}
