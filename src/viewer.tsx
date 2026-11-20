import "@/App.css";

import { useEffect } from "react";
import ReactDOM from "react-dom/client";
import { KeyOverlay } from "@/components/key-overlay";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { KeyEvent } from "@/types/event";

interface PayloadKey {
    name: string;
    pressedCount: number;
}

interface PayloadGroup {
    createdAt: number;
    keys: PayloadKey[];
}

interface Payload {
    groups: PayloadGroup[];
    pressedKeys: string[];
    showEventHistory: boolean;
    style: Record<string, unknown>;
}

/**
 * Applies one snapshot from the local `/events` stream to the same stores the
 * app itself renders from, so the page looks exactly like the overlay window.
 */
function apply(payload: Payload) {
    // The overlay iterates real `KeyEvent` instances and calls `event.in(...)`,
    // so plain JSON has to be rebuilt into instances with the press count kept.
    const groups = payload.groups.map((group) => ({
        createdAt: group.createdAt,
        keys: group.keys.map((key) =>
            Object.assign(new KeyEvent(key.name), { pressedCount: key.pressedCount }),
        ),
    }));

    const style = useKeyStyle.getState();
    useKeyStyle.setState(payload.style as unknown as Partial<typeof style>);
    useKeyEvent.setState({
        groups,
        pressedKeys: payload.pressedKeys,
        showEventHistory: payload.showEventHistory,
    });
}

function Viewer() {
    useEffect(() => {
        const source = new EventSource("/events");
        source.onmessage = (event) => apply(JSON.parse(event.data) as Payload);

        return () => source.close();
    }, []);

    return (
        <div className="h-screen w-screen">
            <KeyOverlay />
        </div>
    );
}

ReactDOM.createRoot(document.getElementById("root")!).render(<Viewer />);
