import { getKeyDisplay } from "@/lib/keymaps";
import { easeInOutExpo } from "@/lib/utils";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { motion } from "motion/react";
import type { KeycapProps } from ".";

export const MinimalKeycap = ({ event, isPressed }: KeycapProps) => {
    const text = useKeyStyle((state) => state.text);
    const modifier = useKeyStyle((state) => state.modifier);
    const layout = useKeyStyle((state) => state.layout);
    const keyboardLayout = useKeyEvent((state) => state.keyboardLayout);

    const display = getKeyDisplay(event.name, keyboardLayout);
    const color = event.isModifier() && modifier.highlight ? modifier.textColor : text.color;
    const textStyle: React.CSSProperties = {
        color,
        lineHeight: 1.2,
        fontSize: text.size,
        textTransform: text.caps,
        gap: ".1em",
    };

    const label = display?.shortLabel ?? display.label;
    let child = <>{label}</>;

    if (event.isModifier() && layout.showIcon && display.icon) {
        const Icon = display.icon;
        if (text.variant === "icon" || event.isArrow()) {
            child = <Icon color={color} size={text.size} />;
        } else {
            child = <>
                <Icon color={color} size={text.size} />
                <div style={{ ...textStyle }}>
                    {text.variant === "text" ? display.label : label}
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