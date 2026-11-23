import { BROWSER_DISPLAY, useKeyStyle } from "@/stores/key_style";
import { useKeyEvent } from "@/stores/key_event";
import { invoke } from "@tauri-apps/api/core";
import { useEffect, useState } from "react";

interface BrowserKey {
    name: string;
    pressedCount: number;
}

interface BrowserGroup {
    createdAt: number;
    keys: BrowserKey[];
}

/**
 * Builds the state the browser source page renders. The page is the app's own
 * viewer bundle, so it only needs the raw groups, the pressed set and the
 * style: it rebuilds `KeyEvent` instances itself, exactly like the overlay.
 */
function buildPayload() {
    const events = useKeyEvent.getState();
    const style = useKeyStyle.getState();

    // The master switch also governs this output: when the keycaps are turned
    // off the page keeps its style but receives no keys, so it goes blank
    // without tearing down the OBS scene. `undefined` is an old stored state
    // that predates the switch, which defaulted to on.
    const groups: BrowserGroup[] = (style.appearance.keycapsEnabled ?? true)
        ? events.groups.map((group) => ({
            createdAt: group.createdAt,
            keys: group.keys.map((key) => ({
                name: key.name,
                pressedCount: key.pressedCount,
            })),
        }))
        : [];

    return {
        groups,
        pressedKeys: events.pressedKeys,
        showEventHistory: events.showEventHistory,
        style: {
            appearance: style.appearance,
            layout: style.layout,
            color: style.color,
            modifier: style.modifier,
            text: style.text,
            border: style.border,
            background: style.background,
        },
    };
}

/**
 * Keeps the local browser-source page in sync with the app while that output
 * is selected: starts the server on the configured port, pushes every visual
 * change and shuts it down again when the display is removed.
 */
export function useBrowserSource() {
    const enabled = useKeyStyle((state) => state.appearance.monitors?.includes(BROWSER_DISPLAY) ?? false);
    const requestedPort = useKeyStyle((state) => state.browserSourcePort);
    const [port, setPort] = useState<number | null>(null);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (!enabled) {
            setPort(null);
            setError(null);
            invoke("browser_source_stop").catch(() => { });
            return;
        }

        let cancelled = false;
        invoke<number>("browser_source_start", { port: requestedPort })
            .then((value) => {
                if (!cancelled) {
                    setPort(value);
                    setError(null);
                }
            })
            .catch((reason) => {
                if (cancelled) return;
                setPort(null);
                setError(String(reason));
                console.error("Failed to start the browser source:", reason);
            });

        return () => {
            cancelled = true;
        };
    }, [enabled, requestedPort]);

    useEffect(() => {
        if (port === null) return;

        let timer: number | undefined;
        const push = () => {
            window.clearTimeout(timer);
            timer = window.setTimeout(() => {
                invoke("browser_source_update", { payload: JSON.stringify(buildPayload()) })
                    .catch((reason) => console.error("Failed to update the browser source:", reason));
            }, 40);
        };

        push();
        const unlistenEvents = useKeyEvent.subscribe(push);
        const unlistenStyle = useKeyStyle.subscribe(push);

        return () => {
            window.clearTimeout(timer);
            unlistenEvents();
            unlistenStyle();
        };
    }, [port]);

    return { port, error };
}
