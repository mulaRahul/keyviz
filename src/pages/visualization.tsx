import { KeyOverlay } from "@/components/key-overlay";
import { MouseOverlay } from "@/components/mouse-overlay";
import { useBrowserSource } from "@/hooks/use-browser-source";
import { useInputEventStream } from "@/hooks/use-input-events";
import { KEY_EVENT_STORE, KeyEventStore, useKeyEvent } from "@/stores/key_event";
import { BROWSER_DISPLAY, KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from '@/stores/key_style';
import { listenForUpdates } from '@/stores/sync';
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { useEffect, useState } from "react";

export function Visualization() {
  // The browser output is not a physical display: the main window can only sit
  // on a real monitor, so it has to ignore the pseudo entry when picking one.
  const monitor = useKeyStyle(
    (state) => state.appearance.monitors?.find((name) => name !== BROWSER_DISPLAY) ?? null
  );
  const mouseDisplays = useKeyStyle((state) => state.appearance.mouseMonitors);
  const keycapsEnabled = useKeyStyle((state) => state.appearance.keycapsEnabled ?? true);
  const mouseEnabled = useKeyStyle((state) => state.appearance.mouseEnabled ?? true);
  const mouse = useKeyStyle((state) => state.mouse);

  // listening for input events
  const [isListening, setIsListening] = useState(true);
  // When the backend manages one click-through window per monitor, the mouse
  // visuals are drawn there and the main window only renders keycaps.
  const [mouseOverlaysActive, setMouseOverlaysActive] = useState(false);

  useInputEventStream();
  // Serves the keycaps on a local page for OBS when the user turned it on.
  useBrowserSource();

  useEffect(() => {
    const unlistenPromises = [
      // ───────────── store sync ─────────────
      listenForUpdates<KeyEventStore>(KEY_EVENT_STORE, useKeyEvent.setState),
      listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState),
      // ───────────── settings window open/close ─────────────
      listen<boolean>("settings-window", (event) => {
        useKeyEvent.setState({ settingsOpen: event.payload });
      }),
      // ───────────── listener toggle ─────────────
      listen<boolean>("listening-toggle", (event) => setIsListening(event.payload)),
      // ───────────── mouse overlays availability ─────────────
      listen<boolean>("mouse-overlays", (event) => setMouseOverlaysActive(event.payload)),
    ];

    return () => {
      unlistenPromises.forEach((p) => p.then((f) => f()));
    };
  }, []);

  const keyDisplays = useKeyStyle((state) => state.appearance.monitors);

  // Extra displays for the keycaps get their own window; the main window keeps
  // rendering the keycaps of the first selected display.
  useEffect(() => {
    invoke<boolean>("set_key_displays", { displays: keyDisplays, enabled: keycapsEnabled }).catch((error) =>
      console.error("Failed to set the keycap displays:", error)
    );
  }, [keyDisplays?.join(",") ?? "*", keycapsEnabled]);

  useEffect(() => {
    const set_monitor = async () => {
      if (!monitor) return;
      try {
        await invoke("set_main_window_monitor", { monitorName: monitor });
      } catch (error) {
        console.error("Failed to set monitor:", error);
      }
    }
    set_monitor();
  }, [monitor]);

  // The "Display" setting only decides where the keycaps live. Mouse visuals
  // follow the cursor, so they need a window on every monitor: ask the backend
  // to keep one alive while any mouse visual is switched on.
  const mouseVisualsEnabled =
    mouseEnabled &&
    isListening &&
    (mouse.showClicks || mouse.keepHighlight || mouse.showIndicator || mouse.keepIndicator);

  // Push the selection even before the overlay layer is up: the backend stores
  // it and the first sync then already knows what to create or close.
  useEffect(() => {
    invoke("set_mouse_displays", { displays: mouseDisplays, enabled: mouseEnabled }).catch((error) =>
      console.error("Failed to apply mouse displays:", error)
    );
  }, [mouseDisplays?.join(",") ?? "*", mouseEnabled]);

  useEffect(() => {
    invoke<boolean>("set_mouse_overlay_enabled", { enabled: mouseVisualsEnabled })
      .then(setMouseOverlaysActive)
      .catch((error) => console.error("Failed to toggle mouse overlays:", error));
  }, [mouseVisualsEnabled]);

  if (!isListening) return null;

  // `null` means "not configured yet" and keeps the default keycaps on screen;
  // an empty array means the user cleared every display, so nothing is drawn.
  // The browser output does not need a window of its own here, so it only
  // counts as a display when a physical one is selected next to it.
  const physicalKeyDisplays = keyDisplays?.filter((name) => name !== BROWSER_DISPLAY) ?? null;
  const keycapsVisible =
    keycapsEnabled && (physicalKeyDisplays === null || physicalKeyDisplays.length > 0);

  return <div className="w-screen h-screen relative overflow-hidden">
    {!mouseOverlaysActive && <MouseOverlay />}
    {keycapsVisible && <KeyOverlay />}
  </div>;
}
