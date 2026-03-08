import { KeyOverlay } from "@/components/key-overlay";
import { MouseOverlay } from "@/components/mouse-overlay";
import { KEY_EVENT_STORE, KeyEventStore, useKeyEvent } from "@/stores/key_event";
import { KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from '@/stores/key_style';
import {
  PREFERENCES_STORE,
  PreferencesStore,
  usePreferences,
} from "@/stores/preferences";
import { listenForUpdates } from '@/stores/sync';
import { EventPayload } from "@/types/event";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { primaryMonitor } from "@tauri-apps/api/window";
import { useEffect, useState, } from "react";

export function Visualization() {
  const monitor = useKeyStyle((state) => state.appearance.monitor);
  const onEvent = useKeyEvent((state) => state.onEvent);
  const tick = useKeyEvent((state) => state.tick);

  // listening for input events
  const [isListening, setIsListening] = useState(true);

  useEffect(() => {
    const unlistenPromises = [
      // ───────────── input event listener ─────────────
      listen<EventPayload>("input-event", (event) => onEvent(event.payload)),
      // ───────────── store sync ─────────────
      listenForUpdates<KeyEventStore>(KEY_EVENT_STORE, useKeyEvent.setState),
      listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState),
      listenForUpdates<PreferencesStore>(PREFERENCES_STORE, usePreferences.setState),
      // ───────────── settings window open/close ─────────────
      listen<boolean>("settings-window", (event) => {
        useKeyEvent.setState({ settingsOpen: event.payload });
      }),
      // ───────────── listener toggle ─────────────
      listen<boolean>("listening-toggle", (event) => setIsListening(event.payload)),
    ];
    const id = setInterval(tick, 250);

    return () => {
      clearInterval(id);
      unlistenPromises.forEach((p) => p.then((f) => f()));
    };
  }, []);

  useEffect(() => {
    const set_monitor = async () => {
      let monitorName = monitor;
      if (!monitorName) {
        const primary = await primaryMonitor();
        monitorName = primary?.name ?? "";
      }
      if (!monitorName) return;
      await invoke("set_main_window_monitor", { monitorName });
    }
    set_monitor();
  }, [monitor]);

  if (!isListening) return null;

  return <div className="w-screen h-screen relative overflow-hidden">
    <MouseOverlay />
    <KeyOverlay />
  </div>;
}
