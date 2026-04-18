import { MouseOverlay } from "@/components/mouse-overlay";
import { KEY_EVENT_STORE, KeyEventStore, useKeyEvent } from "@/stores/key_event";
import { KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from "@/stores/key_style";
import { listenForUpdates } from "@/stores/sync";
import { EventPayload } from "@/types/event";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { useEffect, useState } from "react";

export function MouseOverlayPage() {
  const onEvent = useKeyEvent((state) => state.onEvent);
  const mouseSize = useKeyStyle((state) => state.mouse.size);
  const [isListening, setIsListening] = useState(true);

  // Keep the Rust window size in sync with the mouse indicator size setting
  useEffect(() => {
    invoke("set_mouse_overlay_size", { size: mouseSize });
  }, [mouseSize]);

  useEffect(() => {
    const unlistenPromises = [
      listen<EventPayload>("input-event", (event) => onEvent(event.payload)),
      listenForUpdates<KeyEventStore>(KEY_EVENT_STORE, useKeyEvent.setState),
      listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState),
      listen<boolean>("listening-toggle", (event) => setIsListening(event.payload)),
    ];

    return () => {
      unlistenPromises.forEach((p) => p.then((f) => f()));
    };
  }, []);

  if (!isListening) return null;

  return (
    <div className="w-screen h-screen">
      <MouseOverlay />
    </div>
  );
}
