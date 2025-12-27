import { platform } from '@tauri-apps/plugin-os';
import React, { useState, useEffect, useRef } from 'react';


const currentPlatform = platform();

// --- Types ---
interface ShortcutInputProps {
  value: string[]; // Array of keys, e.g. ['Shift', 'F10']
  onChange: (keys: string[]) => void;
  placeholder?: string;
}

// --- Helper: Format keys for display ---
const formatKey = (key: string) => {
  if (key === ' ') return 'Space';
  if (key === 'Control') return 'Ctrl';
  // Capitalize first letter
  return key.charAt(0).toUpperCase() + key.slice(1);
};

const ShortcutRecorder: React.FC<ShortcutInputProps> = ({
  value,
  onChange,
  placeholder = "Click to set shortcut"
}) => {
  const [isRecording, setIsRecording] = useState(false);
  const inputRef = useRef<HTMLDivElement>(null);

  // --- Logic: Handle Key Down ---
  useEffect(() => {
    if (!isRecording) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      e.preventDefault();
      e.stopPropagation();

      const { key, code, ctrlKey, altKey, shiftKey, metaKey } = e;

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
      if (ctrlKey) modifiers.push('Ctrl');
      if (shiftKey) modifiers.push('Shift');
      if (altKey) modifiers.push('Alt');
      if (metaKey) modifiers.push(currentPlatform === 'macos' ? 'Cmd' : 'Meta');

      // 4. Identify the main key
      // We ignore the key event if it is just a modifier key being pressed alone
      const isModifierKey = ['Control', 'Shift', 'Alt', 'Meta'].includes(key);

      if (isModifierKey) {
        // If user is just holding modifiers, we don't set the value yet,
        // but typically UI waits for a non-modifier key.
        // For this simple implementation, we assume we wait for a non-modifier.
        return;
      }

      // 5. Construct final combo
      // We use code for keys like 'KeyA' to act as 'A', but 'key' usually suffices for display
      const finalKey = key.length === 1 ? key.toUpperCase() : formatKey(key);

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
            Press your combination. Esc to cancel.
          </span>
        ) : (
          <div className="flex gap-2">
            {value.length > 0 ? (
              value.map(k => <KeyCap key={k} label={k} />)
            ) : (
              <span className="text-gray-400 select-none">{placeholder}</span>
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
      <div className="m-px mb-0.5 px-3 py-1.5 bg-secondary rounded-lg">
        {label}                  
      </div>
    </div>
  );
}

export { ShortcutRecorder };