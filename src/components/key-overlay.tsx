import { easeInQuint, easeOutQuint } from "@/lib/utils";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { alignmentForColumn, alignmentForRow } from "@/types/style";
import { AnimatePresence, motion, Variants } from "motion/react";
import { useMemo, type RefObject } from "react";
import { Keycap } from "./keycaps";


const fadeVariants: Variants = {
    visible: { opacity: 1 },
    hidden: { opacity: 0 },
}

export const KeyOverlay = ({ contentRef }: { contentRef?: RefObject<HTMLDivElement | null> }) => {
    const pressedKeys = useKeyEvent(state => state.pressedKeys);
    const groups = useKeyEvent(state => state.groups);
    const showHistory = useKeyEvent(state => state.showEventHistory);

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
    };

    const contentWrapperStyle = {
        display: "flex" as const,
        flexDirection: appearance.flexDirection,
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

    if (appearance.animation === "none") {
        return (
            <div className="w-full h-full flex" style={containerStyle}>
                <div ref={contentRef} style={contentWrapperStyle}>
                    {groups.map((group, groupIndex) => (
                        <div
                            key={group.createdAt}
                            style={groupStyle}
                            className={background.enabled ? "overflow-hidden" : ""}
                        >
                            {group.keys.map((event, keyIndex) => (
                                <Keycap
                                    key={event.name}
                                    event={event}
                                    lastest={group.keys.length - 1 === keyIndex}
                                    isPressed={groups.length - 1 === groupIndex && event.in(pressedKeys)}
                                />
                            ))}
                        </div>
                    ))}
                </div>
            </div>
        );
    }

    return (
        <div className="w-full h-full flex" style={containerStyle}>
            <div ref={contentRef} style={contentWrapperStyle}>
                <AnimatePresence>
                    {groups.map((group, groupIndex) => (
                        <motion.div
                            key={group.createdAt}
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
                                {group.keys.map((event, keyIndex) => (
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
                                            isPressed={groups.length - 1 === groupIndex && event.in(pressedKeys)}
                                        />
                                    </motion.div>
                                ))}
                            </AnimatePresence>
                        </motion.div>
                    ))}
                </AnimatePresence>
            </div>
        </div>
    );
};