import { easeInQuint, easeOutQuint } from "@/lib/utils";
import { keymaps } from "@/lib/keymaps";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { RawKey } from "@/types/event";
import { alignmentForColumn, alignmentForRow } from "@/types/style";
import { AnimatePresence, motion, Variants } from "motion/react";
import { useMemo } from "react";
import { Keycap } from "./keycaps";
import { KeyEvent } from "@/types/event";


const fadeVariants: Variants = {
    visible: { opacity: 1 },
    hidden: { opacity: 0 },
}

type DisplayGroup =
    | { type: "keys"; keys: KeyEvent[]; createdAt: number; lastGroupIndex: number; }
    | { type: "text"; text: string; createdAt: number; lastGroupIndex: number; };

const HARD_MODIFIERS = new Set<string>([
    RawKey.ControlLeft,
    RawKey.ControlRight,
    RawKey.Alt,
    RawKey.MetaLeft,
    RawKey.MetaRight,
]);

const SOFT_MODIFIERS = new Set<string>([
    RawKey.ShiftLeft,
    RawKey.ShiftRight,
    RawKey.CapsLock,
]);

const isPrintableKey = (event: KeyEvent) => {
    if (event.name === RawKey.Space) return true;
    const display = keymaps[event.name];
    if (!display) return false;
    if (display.category === "letter" || display.category === "digit" || display.category === "punctuation") {
        return true;
    }
    if (display.category === "numpad") {
        return typeof display.label === "string" && /^[0-9]$/.test(display.label);
    }
    return false;
};

const labelForText = (event: KeyEvent, textVariant: "text" | "text-short" | "icon") => {
    if (event.name === RawKey.Space) return "⎵"; // "␣";
    const display = keymaps[event.name];
    if (!display) return "";
    const baseLabel = textVariant === "text-short"
        ? (display.shortLabel ?? display.label)
        : display.label;

    if (display.category === "letter") {
        const upper = baseLabel.toUpperCase();
        const lower = baseLabel.toLowerCase();
        const useUpper = (event.capsLock || false) !== (event.shifted || false);
        return useUpper ? upper : lower;
    }

    if (display.category === "digit" || display.category === "punctuation") {
        if (event.shifted && display.symbol) return display.symbol;
        return display.label;
    }

    return baseLabel;
};

export const KeyOverlay = () => {
    const pressedKeys = useKeyEvent(state => state.pressedKeys);
    const groups = useKeyEvent(state => state.groups);
    const showHistory = useKeyEvent(state => state.showEventHistory);
    const textSequenceEnabled = useKeyEvent(state => state.textSequenceEnabled);

    const appearance = useKeyStyle(state => state.appearance);
    const text = useKeyStyle(state => state.text);
    const border = useKeyStyle(state => state.border);
    const background = useKeyStyle(state => state.background);

    const alignment = appearance.flexDirection === "row"
        ? alignmentForRow[appearance.alignment]
        : alignmentForColumn[appearance.alignment];

    const containerStyle = {
        flexDirection: appearance.flexDirection,
        paddingBlock: appearance.marginY,
        paddingInline: appearance.marginX,
        alignItems: alignment.alignItems,
        justifyContent: alignment.justifyContent,
        gap: text.size * 0.5,
    };

    const groupStyle = {
        display: "flex",
        columnGap: appearance.style === "minimal" ? text.size * 0.15 : text.size * 0.3,
        ...(background.enabled && {
            paddingInline: text.size * 0.4,
            paddingBlock: appearance.style === "minimal" ? text.size * 0.25 : text.size * 0.4,
            background: background.color,
            borderRadius: border.radius * (text.size * 1.75),
        }),
    }

    const displayGroups = useMemo<DisplayGroup[]>(() => {
        if (!textSequenceEnabled) {
            return groups.map((group, index) => ({
                type: "keys",
                keys: group.keys,
                createdAt: group.createdAt,
                lastGroupIndex: index,
            }));
        }

        const rendered: DisplayGroup[] = [];
        let buffer: KeyEvent[] = [];
        let bufferCreatedAt = 0;
        let bufferLastIndex = -1;

        const flushBuffer = () => {
            if (buffer.length === 0) return;
            const textValue = buffer
                .map((event) => {
                    const label = labelForText(event, text.variant);
                    if (!label) return "";
                    const repeatCount = Math.max(1, event.pressedCount);
                    return label.repeat(repeatCount);
                })
                .join("");
            rendered.push({
                type: "text",
                text: textValue,
                createdAt: bufferCreatedAt,
                lastGroupIndex: bufferLastIndex,
            });
            buffer = [];
        };

        groups.forEach((group, index) => {
            const hasHardModifier = group.keys.some((event) => HARD_MODIFIERS.has(event.name));
            if (hasHardModifier) {
                flushBuffer();
                rendered.push({
                    type: "keys",
                    keys: group.keys,
                    createdAt: group.createdAt,
                    lastGroupIndex: index,
                });
                return;
            }

            const groupHasPrintable = group.keys.some((event) => isPrintableKey(event));
            for (const event of group.keys) {
                if (groupHasPrintable && SOFT_MODIFIERS.has(event.name)) {
                    continue;
                }
                if (isPrintableKey(event)) {
                    if (buffer.length === 0) {
                        bufferCreatedAt = group.createdAt;
                    }
                    buffer.push(event);
                    bufferLastIndex = index;
                } else {
                    flushBuffer();
                    rendered.push({
                        type: "keys",
                        keys: [event],
                        createdAt: group.createdAt,
                        lastGroupIndex: index,
                    });
                }
            }
        });

        flushBuffer();
        return rendered;
    }, [groups, textSequenceEnabled, text.variant]);

    const variants = useMemo<Variants>(() => {
        switch (appearance.animation) {
            case "none":
                return {
                    visible: {},
                    hidden: {}
                };
            case "fade":
                return fadeVariants;
            case "zoom":
                return {
                    visible: { scale: 1, opacity: 1 },
                    hidden: { scale: 0, opacity: 0 }
                };
            case "float":
                return {
                    visible: { opacity: 1, y: 0 },
                    hidden: { opacity: 0, y: text.size }
                };
            case "slide":
                return {
                    visible: { opacity: 1, x: 0 },
                    hidden: { opacity: 0, x: text.size }
                };
        }
    }, [appearance.animation, text.size]);

    const textGroupStyle: React.CSSProperties = {
        color: text.color,
        lineHeight: 1.2,
        fontSize: text.size,
        textTransform: "none",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        whiteSpace: "pre",
    };

    if (appearance.animation === "none") {
        return (
            <div className="w-full h-full flex" style={containerStyle}>
                {displayGroups.map((group) => (
                    <div
                        key={`${group.createdAt}-${group.lastGroupIndex}-${group.type}`}
                        style={groupStyle}
                        className={background.enabled ? "overflow-hidden" : ""}
                    >
                        {group.type === "text"
                            ? <div style={textGroupStyle}>{group.text}</div>
                            : group.keys.map((event, keyIndex) => (
                                <Keycap
                                    key={event.name}
                                    event={event}
                                    lastest={group.keys.length - 1 === keyIndex}
                                    isPressed={groups.length - 1 === group.lastGroupIndex && event.in(pressedKeys)}
                                />
                            ))}
                    </div>
                ))}
            </div>
        );
    }

    return (
        <div className="w-full h-full flex" style={containerStyle}>
            <AnimatePresence>
                {displayGroups.map((group) => (
                    <motion.div
                        key={`${group.createdAt}-${group.lastGroupIndex}-${group.type}`}
                        layout={showHistory ? "position" : false}
                        variants={fadeVariants}
                        initial="hidden"
                        animate="visible"
                        exit="hidden"
                        style={groupStyle}
                        className={background.enabled ? "overflow-hidden" : ""}
                        transition={{
                            ease: [easeOutQuint, easeInQuint],
                            duration: showHistory ? appearance.animationDuration : 0
                        }}
                    >
                        <AnimatePresence>
                            {group.type === "text"
                                ? (
                                    <motion.div
                                        layout="position"
                                        variants={variants}
                                        initial="hidden"
                                        animate="visible"
                                        exit="hidden"
                                        transition={{
                                            ease: [easeOutQuint, easeInQuint],
                                            duration: appearance.animationDuration,
                                            layout: { duration: appearance.animationDuration / 3, ease: easeOutQuint },
                                        }}
                                    >
                                        <div style={textGroupStyle}>{group.text}</div>
                                    </motion.div>
                                )
                                : group.keys.map((event, keyIndex) => (
                                    <motion.div
                                        key={event.name}
                                        layout="position"
                                        variants={variants}
                                        initial="hidden"
                                        animate="visible"
                                        exit="hidden"
                                        transition={{
                                            ease: [easeOutQuint, easeInQuint],
                                            duration: appearance.animationDuration,
                                            layout: { duration: appearance.animationDuration / 3, ease: easeOutQuint },
                                        }}
                                    >
                                        <Keycap
                                            event={event}
                                            lastest={group.keys.length - 1 === keyIndex}
                                            isPressed={groups.length - 1 === group.lastGroupIndex && event.in(pressedKeys)}
                                        />
                                    </motion.div>
                                ))}
                        </AnimatePresence>
                    </motion.div>
                ))}
            </AnimatePresence>
        </div>
    );
};