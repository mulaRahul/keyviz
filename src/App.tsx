import "./App.css";

import { listen } from "@tauri-apps/api/event";
import { useEffect, } from "react";
import { useKeyEvent } from "./stores/key_event";
import { EventPayload } from "./types/event";
import { Overlay } from "./components/overlay";

function App() {
  const onEvent = useKeyEvent((state) => state.onEvent);
  const tick = useKeyEvent((state) => state.tick);

  useEffect(() => {
    const unsubscribe = listen<EventPayload>(
      "input-event",
      (event) => onEvent(event.payload)
    );
    const intervalId = setInterval(tick, 250);
    return () => {
      clearInterval(intervalId);
      unsubscribe.then(f => f());
    };
  }, []);

  return (
    <>
      <Overlay />
    </>
  );
}

export default App;
