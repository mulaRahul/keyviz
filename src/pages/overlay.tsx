import { MouseOverlay } from "@/components/mouse-overlay";
import { useInputEventStream } from "@/hooks/use-input-events";
import { KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from "@/stores/key_style";
import { listenForUpdates } from "@/stores/sync";
import { invoke } from "@tauri-apps/api/core";
import { useCallback, useEffect } from "react";

/**
 * One transparent window per monitor, created by the backend when mouse
 * visuals are enabled.
 *
 * The backend sends this window the mouse events of its own monitor, already
 * translated into local physical pixels, so the visuals can follow
 * `mouse.x`/`mouse.y` exactly like they used to follow the single main window.
 */
export function Overlay() {
  // A fresh window starts with the cursor at (0, 0); ask for the real one as
  // soon as the event listener exists, so a kept indicator does not sit in the
  // top-left corner until the next mouse move.
  const syncPointer = useCallback(() => {
    invoke("resync_mouse_pointer").catch((error) =>
      console.error("Failed to sync the mouse pointer:", error)
    );
  }, []);

  useInputEventStream(syncPointer);

  useEffect(() => {
    const unlisten = listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState);

    return () => {
      unlisten.then((off) => off());
    };
  }, []);

  return (
    <div className="w-screen h-screen relative overflow-hidden">
      <MouseOverlay />
    </div>
  );
}
