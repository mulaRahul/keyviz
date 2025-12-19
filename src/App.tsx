import { listen } from "@tauri-apps/api/event";
import "./App.css";
import { Overlay } from "./components/overlay";
import { useEffect } from "react";
import { HidEvent, useHidStore } from "./hooks/store";
import { getCurrentWindow } from "@tauri-apps/api/window";

function App() {
  const onEvent = useHidStore((state) => state.onEvent);

  
  useEffect(() => {
    getCurrentWindow().setDecorations(false);
    // getCurrentWindow().setFullscreen(true);
    // getCurrentWindow().setIgnoreCursorEvents(true);

    const unlisten = listen("hid-event", (event) => {
      onEvent(event.payload as HidEvent);
    });
    return () => {
      unlisten.then((f) => f());
    };
  }, [onEvent]);

  return <Overlay />;
}

export default App;
