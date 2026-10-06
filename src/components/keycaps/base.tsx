import { useKeyDisplay } from "@/lib/keyboard";
import { useKeyStyle } from "@/stores/key_style";
import { KeyEvent } from "@/types/event";
import { alignmentForRow } from "@/types/style";
import { useTranslation } from "react-i18next";
import { applyCase, displayLabel, isCaseSensitive } from "@/i18n/key-label";

export const KeycapBase = ({ event }: { event: KeyEvent }) => {
  const { t } = useTranslation();
  const text = useKeyStyle((state) => state.text);
  const layout = useKeyStyle((state) => state.layout);
  const modifier = useKeyStyle((state) => state.modifier);
  const display = useKeyDisplay(event.name);
  const caseSensitive = isCaseSensitive(display, text.matchCase);
  const withCase = (value: string) => caseSensitive ? applyCase(value, event.shifted) : value;

  const textColor = event.isModifier() && modifier.highlight ? modifier.textColor : text.color;
  const textStyle: React.CSSProperties = {
    color: textColor,
    lineHeight: 1.2,
    fontSize: text.size,
    textTransform: caseSensitive ? "none" : text.caps,
  };

  const label = withCase(displayLabel(display, event.name, t, text.variant === "text-short"));
  const fullLabel = withCase(displayLabel(display, event.name, t));

  const flexAlignment = alignmentForRow[text.alignment];

  // ───────────── With Icon ─────────────
  if (layout.showIcon && display.icon) {
    const Icon = display.icon;
    if (text.variant === "icon" || event.isArrow() || display.iconOnly) {
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
      <span className="font-semibold">{fullLabel}</span>
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