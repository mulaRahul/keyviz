import { useHidStore } from "../hooks/store";
import { AnimatePresence } from "framer-motion";
import { KeyCap } from "./keycap";

export function Overlay() {
  const events = useHidStore((s) => s.events);

  return (
    <div className="overlay">
      <AnimatePresence>
        {events.map((e) => (
          <KeyCap key={e.id} event={e} />
        ))}
      </AnimatePresence>
    </div>
  );
}
