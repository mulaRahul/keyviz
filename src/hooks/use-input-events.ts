import { useKeyEvent } from "@/stores/key_event";
import { EventPayload } from "@/types/event";
import { listen } from "@tauri-apps/api/event";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { useEffect, useRef } from "react";

/**
 * Feeds the global input stream into the key event store and drives the timer
 * that expires lingering keys and wheel indicators.
 *
 * Every window that draws input runs this: the main window for the keycaps,
 * each overlay window for the mouse visuals of its own monitor.
 *
 * `onSubscribed` runs once the listener is actually attached, which is the
 * earliest moment a window can ask the backend for events without losing them.
 */
export function useInputEventStream(onSubscribed?: () => void) {
    const onEvent = useKeyEvent((state) => state.onEvent);
    const tick = useKeyEvent((state) => state.tick);

    // Keep the latest callback without re-subscribing on every render.
    const subscribed = useRef(onSubscribed);
    subscribed.current = onSubscribed;

    useEffect(() => {
        // Listen against this window's own label. A listener registered without
        // a target is bound to `Any`, so it also receives the copy of every
        // event emitted for another window: the main window would then process
        // each click once for itself and once for the overlay window of the
        // monitor under the cursor, turning a single click into two keycaps.
        const unlisten = listen<EventPayload>("input-event", (event) => onEvent(event.payload), {
            target: getCurrentWindow().label,
        });
        const interval = setInterval(tick, 250);

        unlisten.then(() => subscribed.current?.());

        return () => {
            clearInterval(interval);
            unlisten.then((off) => off());
        };
    }, [onEvent, tick]);
}
