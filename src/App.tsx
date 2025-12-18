import { useState, useEffect } from "react";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import "./App.css";

interface KeyboardEvent {
  type: "Keyboard";
  event_type: "keydown" | "keyup";
  key_name: string;
  vk_code: number;
  modifiers: string[];
}

interface MouseEvent {
  type: "Mouse";
  event_type: string;
  x: number;
  y: number;
  modifiers: string[];
}

type HidEvent = KeyboardEvent | MouseEvent;

interface DisplayedEvent {
  id: number;
  display: string;
  eventType: string;
  isMouseEvent: boolean;
  timestamp: number;
}

function App() {
  const [events, setEvents] = useState<DisplayedEvent[]>([]);
  const [isListening, setIsListening] = useState(false);

  useEffect(() => {
    if (!isListening) return;

    const unlisten = listen<HidEvent>("hid-event", (event) => {
      const payload = event.payload;
      let display: string;

      console.log("Received event:", payload);

      if (payload.type === "Keyboard") {
        display = `Key ${payload.key_name} was ${payload.event_type} (vk: ${payload.vk_code})`;
      } else {
        display = `Mouse event: ${payload.event_type} at (${payload.x}, ${payload.y})`;
      }
      const newEvent: DisplayedEvent = {
        id: Date.now() + Math.random(),
        display,
        eventType: payload.event_type,
        isMouseEvent: payload.type === "Mouse",
        timestamp: Date.now(),
      };
      setEvents((prev) => [...prev.slice(-8), newEvent]);

      // Remove after animation
      setTimeout(() => {
        setEvents((prev) => prev.filter((e) => e.id !== newEvent.id));
      }, 2000);
    });

    return () => {
      unlisten.then((fn) => fn());
    };
  }, [isListening]);

  const startListening = async () => {
    try {
      await invoke("start_listener");
      setIsListening(true);
    } catch (error) {
      console.error("Failed to start listener:", error);
    }
  };

  return (
    <div className="app">
      {
        !isListening && <button onClick={startListening}>Start</button>
      }
      {events.map((event) => (
        <div key={event.id} className="label">
          {event.display}
        </div>
      ))}
    </div>
  );
}

export default App;
