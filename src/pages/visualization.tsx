import { KeyOverlay } from "@/components/key-overlay";
import { KEY_EVENT_STORE, KeyEventStore, useKeyEvent } from "@/stores/key_event";
import { KEY_STYLE_STORE, KeyStyleStore, useKeyStyle } from '@/stores/key_style';
import { listenForUpdates } from '@/stores/sync';
import { EventPayload } from "@/types/event";
import { Alignment } from "@/types/style";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { useCallback, useEffect, useRef, useState } from "react";

const WINDOW_POSITIONS: Record<Alignment, (ww: number, wh: number, sw: number, sh: number) => { x: number; y: number }> = {
  'top-left':     (_ww, _wh, _sw, _sh) => ({ x: 0,             y: 0 }),
  'top-center':   ( ww, _wh,  sw, _sh) => ({ x: (sw - ww) / 2, y: 0 }),
  'top-right':    ( ww, _wh,  sw, _sh) => ({ x: sw - ww,       y: 0 }),
  'center-left':  (_ww,  wh, _sw,  sh) => ({ x: 0,             y: (sh - wh) / 2 }),
  'center':       ( ww,  wh,  sw,  sh) => ({ x: (sw - ww) / 2, y: (sh - wh) / 2 }),
  'center-right': ( ww,  wh,  sw,  sh) => ({ x: sw - ww,       y: (sh - wh) / 2 }),
  'bottom-left':  (_ww,  wh, _sw,  sh) => ({ x: 0,             y: sh - wh }),
  'bottom-center':( ww,  wh,  sw,  sh) => ({ x: (sw - ww) / 2, y: sh - wh }),
  'bottom-right': ( ww,  wh,  sw,  sh) => ({ x: sw - ww,       y: sh - wh }),
};

export function Visualization() {
  const monitor = useKeyStyle((state) => state.appearance.monitor);
  const appearance = useKeyStyle((state) => state.appearance);
  const onEvent = useKeyEvent((state) => state.onEvent);
  const tick = useKeyEvent((state) => state.tick);

  const [isListening, setIsListening] = useState(true);
  const contentRef = useRef<HTMLDivElement>(null);
  const rafRef = useRef<number | null>(null);

  const updateWindowBounds = useCallback((contentW: number, contentH: number) => {
    const sw = window.screen.width;
    const sh = window.screen.height;

    if (contentW === 0 || contentH === 0) {
      invoke("resize_overlay_window", { x: 0, y: 0, width: 1, height: 1 });
      return;
    }

    const ww = contentW + 2 * appearance.marginX;
    const wh = contentH + 2 * appearance.marginY;
    const positionFn = WINDOW_POSITIONS[appearance.alignment as Alignment] ?? WINDOW_POSITIONS['bottom-center'];
    const { x, y } = positionFn(ww, wh, sw, sh);

    invoke("resize_overlay_window", {
      x: Math.max(0, x),
      y: Math.max(0, y),
      width: ww,
      height: wh,
    });
  }, [appearance.marginX, appearance.marginY, appearance.alignment]);

  // Re-run immediately when mouse settings or appearance changes
  useEffect(() => {
    const el = contentRef.current;
    if (!el) return;
    updateWindowBounds(el.offsetWidth, el.offsetHeight);
  }, [updateWindowBounds]);

  // Track content size changes
  useEffect(() => {
    const el = contentRef.current;
    if (!el) return;

    const observer = new ResizeObserver((entries) => {
      const entry = entries[0];
      if (!entry) return;
      const { width, height } = entry.contentRect;

      if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
      rafRef.current = requestAnimationFrame(() => {
        updateWindowBounds(width, height);
        rafRef.current = null;
      });
    });

    observer.observe(el);
    return () => {
      observer.disconnect();
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }
    };
  }, [updateWindowBounds]);

  useEffect(() => {
    const unlistenPromises = [
      listen<EventPayload>("input-event", (event) => onEvent(event.payload)),
      listenForUpdates<KeyEventStore>(KEY_EVENT_STORE, useKeyEvent.setState),
      listenForUpdates<KeyStyleStore>(KEY_STYLE_STORE, useKeyStyle.setState),
      listen<boolean>("settings-window", (event) => {
        useKeyEvent.setState({ settingsOpen: event.payload });
      }),
      listen<boolean>("listening-toggle", (event) => setIsListening(event.payload)),
    ];
    const id = setInterval(tick, 250);

    return () => {
      clearInterval(id);
      unlistenPromises.forEach((p) => p.then((f) => f()));
    };
  }, []);

  useEffect(() => {
    if (!monitor) return;
    invoke("set_main_window_monitor", { monitorName: monitor }).catch(console.error);
  }, [monitor]);

  if (!isListening) return null;

  return (
    <div className="w-screen h-screen relative overflow-hidden">
      <KeyOverlay contentRef={contentRef} />
    </div>
  );
}