import { easeInOutExpo } from "@/lib/utils";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { motion } from "motion/react";
import { useEffect, useRef, useState } from "react";
import { MouseIndicator } from "./mouse-indicator";

const MIN_CLICK_DISPLAY_MS = 200;

export const MouseOverlay = () => {
    const wheel = useKeyEvent(state => state.mouse.wheel);
    const pressedMouseButton = useKeyEvent(state => state.pressedMouseButton);
    const style = useKeyStyle(state => state.mouse);
    const animationDuration = useKeyStyle(state => state.appearance.animationDuration);

    const [show, setShow] = useState(false);

    const timeoutRef = useRef<NodeJS.Timeout | null>(null);
    const pressTimestampRef = useRef<number | null>(null);

    useEffect(() => {
        if (pressedMouseButton) {
            setShow(true);
            pressTimestampRef.current = Date.now();
            if (timeoutRef.current) {
                clearTimeout(timeoutRef.current);
                timeoutRef.current = null;
            }
        } else if (show && pressTimestampRef.current) {
            const elapsed = Date.now() - pressTimestampRef.current;
            if (elapsed >= MIN_CLICK_DISPLAY_MS) {
                setShow(false);
                pressTimestampRef.current = null;
            } else {
                timeoutRef.current = setTimeout(() => {
                    setShow(false);
                    pressTimestampRef.current = null;
                    timeoutRef.current = null;
                }, MIN_CLICK_DISPLAY_MS - elapsed);
            }
        }

        return () => {
            if (timeoutRef.current) clearTimeout(timeoutRef.current);
        };
    }, [pressedMouseButton, show]);

    const shouldRender = style.showClicks || style.keepHighlight || style.showIndicator || style.keepIndicator;
    if (!shouldRender) return null;

    // The Rust event loop moves this window to sit centered on the cursor on every
    // MouseMove event, so no CSS transform is needed here — content just fills the window.
    return (
        <div
            className="w-full h-full relative pointer-events-none"
            style={{ width: style.size, height: style.size }}
        >
            {style.showClicks && (
                <motion.div
                    className="absolute inset-0"
                    initial={false}
                    animate={{
                        opacity: show || style.keepHighlight ? 1 : 0,
                        scale: show ? 0.5 : 1.0,
                        borderWidth: style.size / 20,
                    }}
                    style={{
                        borderColor: style.color,
                        borderStyle: "solid",
                        borderRadius: "50%",
                    }}
                    transition={{
                        duration: animationDuration,
                        ease: easeInOutExpo,
                    }}
                />
            )}

            {style.showIndicator && (
                <motion.div
                    className="absolute left-1/2 top-1/2"
                    animate={{ opacity: show || style.keepIndicator || wheel !== 0 ? 1 : 0 }}
                    transition={{ duration: 0.2 }}
                >
                    <MouseIndicator />
                </motion.div>
            )}
        </div>
    );
};
