import { motion } from "framer-motion";
import { KeyEvent } from "../hooks/store";

export function KeyCap({ event }: { event: KeyEvent }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.2 }}
      className="keycap"
    >
      {event.label}
    </motion.div>
  );
}
