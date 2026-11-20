import { KeyOverlay } from "@/components/key-overlay";
import { useInputEventStream } from "@/hooks/use-input-events";
import { KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from "@/stores/key_style";
import { listenForUpdates } from "@/stores/sync";
import { useEffect } from "react";

/**
 * One transparent window per extra display, created by the backend when the
 * user selects more than one display for the keycaps.
 *
 * The backend only sends this window the key events, so it renders the same
 * keycaps the main window would, on its own monitor.
 */
export function Keys() {
  useInputEventStream();

  useEffect(() => {
    const unlisten = listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState);

    return () => {
      unlisten.then((off) => off());
    };
  }, []);

  return (
    <div className="w-screen h-screen relative overflow-hidden">
      <KeyOverlay />
    </div>
  );
}