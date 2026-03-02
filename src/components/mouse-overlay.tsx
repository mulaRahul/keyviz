import { easeInOutExpo } from "@/lib/utils";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { motion } from "motion/react";
import { useEffect, useRef, useState } from "react";
import { MouseIndicator } from "./mouse-indicator";
import { platform } from "@tauri-apps/plugin-os";

const MIN_CLICK_DISPLAY_MS = 200;
const isMacos = platform() === "macos";

export const MouseOverlay = () => {
    const wheel = useKeyEvent(state => state.mouse.wheel);
    const pressedMouseButton = useKeyEvent(state => state.pressedMouseButton);
    const style = useKeyStyle(state => state.mouse);
    const animationDuration = useKeyStyle(state => state.appearance.animationDuration);

    const [show, setShow] = useState(false);

    const positionRef = useRef<HTMLDivElement>(null);
    const timeoutRef = useRef<NodeJS.Timeout | null>(null);
    const pressTimestampRef = useRef<number | null>(null);

    // Handle minimum display duration for mouse clicks
    useEffect(() => {
        if (pressedMouseButton) {
            // Mouse button pressed - show immediately and record timestamp
            setShow(true);
            pressTimestampRef.current = Date.now();
            // Clear any pending timeout
            if (timeoutRef.current) {
                clearTimeout(timeoutRef.current);
                timeoutRef.current = null;
            }
        } else if (show && pressTimestampRef.current) {
            // Mouse button released - check if minimum duration has passed
            const elapsed = Date.now() - pressTimestampRef.current;

            if (elapsed >= MIN_CLICK_DISPLAY_MS) {
                // Already displayed long enough - hide immediately
                setShow(false);
                pressTimestampRef.current = null;
            } else {
                // Need to maintain visibility for remaining time
                timeoutRef.current = setTimeout(() => {
                    setShow(false);
                    pressTimestampRef.current = null;
                    timeoutRef.current = null;
                }, MIN_CLICK_DISPLAY_MS - elapsed);
            }
        }

        return () => {
            if (timeoutRef.current) {
                clearTimeout(timeoutRef.current);
            }
        };
    }, [pressedMouseButton, show]);

    // Subscribe to mouse movement without re-rendering React
    useEffect(() => {
        if (!positionRef.current) return;

        // Zustand subscribe allows us to listen to changes without triggering a component re-render
        const unsubscribe = useKeyEvent.subscribe((state) => {
            const el = positionRef.current;
            if (!el) return;

            const shouldUpdatePosition =
                style.keepHighlight ||
                state.pressedMouseButton ||
                style.showIndicator ||
                style.keepIndicator;

            if (!shouldUpdatePosition) return;

            const dpr = isMacos ? 1 : window.devicePixelRatio || 1;
            el.style.transform =
                `translate3d(${state.mouse.x / dpr}px, ${state.mouse.y / dpr}px, 0) translate(-50%, -50%)`;
        });

        return () => unsubscribe();
    }, [style.showClicks, style.keepHighlight, style.showIndicator, style.keepIndicator]);

    // Logic to determine if we should render anything at all to keep DOM light
    const shouldRender = style.showClicks || style.keepHighlight || style.showIndicator || style.keepIndicator;
    if (!shouldRender) return null;


    return (
        <div className="absolute top-0 left-0 w-full h-full pointer-events-none overflow-hidden">
            <div
                ref={positionRef}
                className="absolute top-0 left-0 will-change-transform"
                style={{
                    width: style.size,
                    height: style.size,
                }}
            >
                {style.showClicks && (
                    <motion.div
                        className="w-full h-full"
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

                {style.showIndicator &&
                    <motion.div
                        className="absolute left-1/2 top-1/2"
                        animate={{ opacity: show || style.keepIndicator || wheel !== 0 ? 1 : 0 }}
                        transition={{ duration: 0.2 }}
                    >
                        <MouseIndicator />
                    </motion.div>
                }
            </div>
        </div>
    );
};