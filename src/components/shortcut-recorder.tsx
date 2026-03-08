import { useI18n } from '@/hooks/use-i18n';
import { keymaps } from '@/lib/keymaps';
import { RawKey } from '@/types/event';
import { useEffect, useRef, useState } from 'react';


// --- Types ---
interface ShortcutInputProps {
  value: string[]; // Array of keys, e.g. ['Shift', 'F10']
  onChange: (keys: string[]) => void;
  placeholder?: string;
}

const punctuationMap: { [key: string]: string } = {
  "`": "BackQuote",
  "-": "Minus",
  "=": "Equal",
  "[": "LeftBracket",
  "]": "RightBracket",
  "\\": "BackSlash",
  ";": "SemiColon",
  "'": "Quote",
  ",": "Comma",
  ".": "Dot",
  "/": "Slash",
};

// --- Helper: Format keys into RawKey ---
const formatKey = (key: string) => {
  // Alphabetic keys
  if (key.length === 1 && key.match(/[a-zA-Z]/)) {
    return `Key${key.toUpperCase()}`;
  }
  // Numeric keys
  else if (key.length === 1 && key.match(/[0-9]/)) {
    return `Num${key}`;
  }
  // Arrow keys
  else if (key.startsWith("Arrow")) {
    return `${key.replace("Arrow", "")}Arrow`;
  }
  // Punctuation keys
  else if (punctuationMap[key]) {
    return punctuationMap[key];
  }
  return key;
};

const ShortcutRecorder: React.FC<ShortcutInputProps> = ({
  value,
  onChange,
  placeholder
}) => {
  const { t } = useI18n();
  const [isRecording, setIsRecording] = useState(false);
  const inputRef = useRef<HTMLDivElement>(null);
  const resolvedPlaceholder = placeholder ?? t("settings.general.toggleShortcut.placeholder");

  // --- Logic: Handle Key Down ---
  useEffect(() => {
    if (!isRecording) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      e.preventDefault();
      e.stopPropagation();

      const { key, ctrlKey, altKey, shiftKey, metaKey, repeat } = e;
      if (repeat) return;

      // 1. Handle Cancel (Escape)
      if (key === 'Escape') {
        setIsRecording(false);
        inputRef.current?.blur();
        return;
      }

      // 2. Handle Clear (Backspace/Delete)
      if (key === 'Backspace' || key === 'Delete') {
        onChange([]);
        setIsRecording(false);
        return;
      }

      // 3. Identify Modifiers
      const modifiers = [];
      if (ctrlKey) modifiers.push(RawKey.ControlLeft);
      if (shiftKey) modifiers.push(RawKey.ShiftLeft);
      if (altKey) modifiers.push(RawKey.Alt);
      if (metaKey) modifiers.push(RawKey.MetaLeft);

      // 4. Identify the main key
      if (['Control', 'Shift', 'Alt', 'Meta'].includes(key)) {
        // If user is just holding modifiers, we don't set the value yet,
        // but typically UI waits for a non-modifier key.
        // For this simple implementation, we assume we wait for a non-modifier.
        return;
      }

      // 5. Construct final combo
      const finalKey = formatKey(key);
      const newShortcut = [...new Set([...modifiers, finalKey])]; // Set removes duplicates

      onChange(newShortcut);
      setIsRecording(false);
      inputRef.current?.blur();
    };

    // Attach to window to ensure we catch everything while recording
    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('click', handleClickOutside);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('click', handleClickOutside);
    };
  }, [isRecording, onChange]);

  // Stop recording if user clicks elsewhere
  const handleClickOutside = (e: MouseEvent) => {
    if (inputRef.current && !inputRef.current.contains(e.target as Node)) {
      setIsRecording(false);
    }
  };

  return (
    <div className="flex flex-col items-start gap-2">
      <div
        ref={inputRef}
        onClick={() => setIsRecording(true)}
        className={`
          relative flex items-center w-full h-14 p-2 bg-background rounded-lg outline cursor-pointer transition-all
          ${isRecording
            ? 'outline-primary'
            : 'outline-transparent hover:outline-primary/50'
          }
        `}
        tabIndex={0} // Make div focusable
      >
        {isRecording ? (
          <span className="text-primary font-medium ml-2">
            {t("settings.general.toggleShortcut.recording")}
          </span>
        ) : (
          <div className="flex gap-2">
            {value.length > 0 ? (
              value.map(k => <KeyCap key={k} label={keymaps[k]?.label ?? k} />)
            ) : (
              <span className="text-gray-400 select-none">{resolvedPlaceholder}</span>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

const KeyCap = ({ label }: { label: string }) => {
  return (
    <div className="h-9 bg-linear-to-b from-primary/50 to-secondary rounded-lg">
      <div className="m-px mb-0.5 px-3 py-1.5 bg-secondary rounded-lg capitalize">
        {label}
      </div>
    </div>
  );
}

export { ShortcutRecorder };

