import { useKeyDisplay } from "@/lib/keyboard";
import { easeInOutExpo } from "@/lib/utils";
import { useKeyStyle } from "@/stores/key_style";
import { motion } from "motion/react";
import type { KeycapProps } from ".";
import { useTranslation } from "react-i18next";
import { applyCase, displayLabel, isCaseSensitive } from "@/i18n/key-label";

export const MinimalKeycap = ({ event, isPressed }: KeycapProps) => {
    const { t } = useTranslation();
    const text = useKeyStyle((state) => state.text);
    const modifier = useKeyStyle((state) => state.modifier);
    const layout = useKeyStyle((state) => state.layout);

    const display = useKeyDisplay(event.name);
    const caseSensitive = isCaseSensitive(display, text.matchCase);
    const withCase = (value: string) => caseSensitive ? applyCase(value, event.shifted) : value;

    const color = event.isModifier() && modifier.highlight ? modifier.textColor : text.color;
    const textStyle: React.CSSProperties = {
        color,
        lineHeight: 1.2,
        fontSize: text.size,
        textTransform: caseSensitive ? "none" : text.caps,
        gap: ".1em",
    };

    const label = withCase(displayLabel(display, event.name, t, true));
    const fullLabel = withCase(displayLabel(display, event.name, t));
    let child = <>{label}</>;

    // keyboard-file drawings show on every key, built-in icons on modifiers only
    if ((event.isModifier() || display.custom) && layout.showIcon && display.icon) {
        const Icon = display.icon;
        if (text.variant === "icon" || event.isArrow() || display.iconOnly) {
            child = <Icon color={color} size={text.size} />;
        } else {
            child = <>
                <Icon color={color} size={text.size} />
                <div style={{ ...textStyle }}>
                    {text.variant === "text" ? fullLabel : label}
                </div>
            </>;
        }
    }

    return (
        <motion.div
            animate={{ scale: isPressed ? 0.95 : 1 }}
            transition={{ ease: easeInOutExpo, duration: 0.1 }}
            className="flex items-center h-full"
            style={textStyle}
        >
            {child}
        </motion.div>
    );
};
