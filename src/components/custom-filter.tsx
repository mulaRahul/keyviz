import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group";
import { useI18n } from "@/hooks/use-i18n";
import { keymaps } from "@/lib/keymaps";
import { cn } from "@/lib/utils";
import { useKeyEvent } from "@/stores/key_event";
import { RawKey } from "@/types/event";
import { createContext, useContext, useEffect, useRef, useState } from "react";

// Context for shared state
interface KeyboardContextType {
  isCtrlHeld: boolean;
  hoveredKey: string | undefined;
  hoveredCategory: string | undefined;
  setHoveredKey: (key: string | undefined) => void;
  setHoveredCategory: (category: string | undefined) => void;
}

const KeyboardContext = createContext<KeyboardContextType | null>(null);

// Reusable Key Component to avoid repeating Tailwind classes
const ButtonKey: React.FC<{
  rawKey: string;
  className?: string;
  flexGrow?: boolean;
}> = ({ rawKey, className = "", flexGrow = false }) => {
  const allowedKeys = useKeyEvent(state => state.allowedKeys);
  const setAllowedKeys = useKeyEvent(state => state.setAllowedKeys);
  const context = useContext(KeyboardContext);

  if (!context) {
    throw new Error('ButtonKey must be used within KeyboardContext');
  }

  const { isCtrlHeld, hoveredCategory, setHoveredKey } = context;

  const keyData = keymaps[rawKey];
  const displayLabel = keyData?.shortLabel || keyData?.label || rawKey;
  const symbol = keyData?.symbol;
  const category = keyData?.category;
  const enabled = allowedKeys.includes(rawKey);
  const isHighlighted = isCtrlHeld && hoveredCategory && category === hoveredCategory;

  let content = <>{displayLabel}</>;
  if (symbol) {
    content = <>{symbol}<br />{displayLabel}</>;
  } else if (keyData?.category === 'arrow') {
    content = <>{keyData.glyph}</>;
  }

  const handleClick = () => {
    if (isCtrlHeld && category) {
      // Toggle all keys in the category
      const keysInCategory = Object.keys(keymaps).filter(
        k => keymaps[k]?.category === category
      );

      // Check if all keys in the category are enabled
      const allEnabled = keysInCategory.every(k => allowedKeys.includes(k));

      if (allEnabled) {
        // Remove all keys in the category
        setAllowedKeys(allowedKeys.filter(k => !keysInCategory.includes(k)));
      } else {
        // Add all keys in the category
        const newKeys = [...allowedKeys];
        keysInCategory.forEach(k => {
          if (!newKeys.includes(k)) {
            newKeys.push(k);
          }
        });
        setAllowedKeys(newKeys);
      }
    } else {
      // Toggle single key
      if (allowedKeys.includes(rawKey)) {
        setAllowedKeys(allowedKeys.filter(k => k !== rawKey));
      } else {
        setAllowedKeys([...allowedKeys, rawKey]);
      }
    }
  };

  return (
    <div
      onClick={handleClick}
      onMouseEnter={() => setHoveredKey(rawKey)}
      onMouseLeave={() => setHoveredKey(undefined)}
      className={cn(
        !flexGrow && 'w-10 h-10',
        'flex items-center justify-center text-xs text-primary text-center bg-secondary rounded-lg cursor-pointer',
        className,
        !enabled && 'opacity-50',
        isHighlighted ? 'outline-2 outline-blue-500' : 'hover:outline-2 hover:outline-blue-500'
      )}
      style={{
        boxShadow: enabled
          ? '0 1px 2px 0 var(--shadow-color), inset 0 1px 1px 0 var(--highlight-color)'
          : '0 1px 2px 0 var(--shadow-color) inset',
      }}
    >
      {content}
    </div>
  );
};

export const CustomFilter = () => {
  const { t } = useI18n();

  const [activeTab, setActiveTab] = useState<'Keyboard' | 'Mouse' | 'Numpad'>('Keyboard');
  const [isCtrlHeld, setIsCtrlHeld] = useState(false);
  const [hoveredKey, setHoveredKey] = useState<string | undefined>(undefined);
  const [hoveredCategory, setHoveredCategory] = useState<string | undefined>(undefined);

  const hoveredKeyRef = useRef<string | undefined>(undefined);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!e.repeat && e.key === 'Control') {
        setIsCtrlHeld(true);
        const currentHoveredKey = hoveredKeyRef.current;
        setHoveredCategory(currentHoveredKey ? keymaps[currentHoveredKey]?.category : undefined);
      }
    };

    const handleKeyUp = (e: KeyboardEvent) => {
      if (e.key === 'Control') {
        setIsCtrlHeld(false);
        setHoveredCategory(undefined);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, []);

  useEffect(() => {
    hoveredKeyRef.current = hoveredKey;
  }, [hoveredKey]);

  return (
    <KeyboardContext.Provider value={{ isCtrlHeld, hoveredKey, hoveredCategory, setHoveredKey, setHoveredCategory }}>
      <div className="w-full h-100 flex flex-col gap-4 items-center justify-center">
        {activeTab === 'Keyboard' &&
          <div
            className="w-full p-3 max-w-196 flex flex-col gap-2 bg-secondary rounded-2xl"
          >
            {/* Row 1: Function Keys */}
            <div className="flex gap-2 justify-between w-full">
              <ButtonKey rawKey={RawKey.Escape} />
              <ButtonKey rawKey={RawKey.F1} />
              <ButtonKey rawKey={RawKey.F2} />
              <ButtonKey rawKey={RawKey.F3} />
              <ButtonKey rawKey={RawKey.F4} />
              <ButtonKey rawKey={RawKey.F5} />
              <ButtonKey rawKey={RawKey.F6} />
              <ButtonKey rawKey={RawKey.F7} />
              <ButtonKey rawKey={RawKey.F8} />
              <ButtonKey rawKey={RawKey.F9} />
              <ButtonKey rawKey={RawKey.F10} />
              <ButtonKey rawKey={RawKey.F11} />
              <ButtonKey rawKey={RawKey.F12} />
              <ButtonKey rawKey={RawKey.Insert} />
              <ButtonKey rawKey={RawKey.Delete} />
            </div>

            {/* Row 2: Numbers */}
            <div className="flex gap-2 justify-between w-full">
              <ButtonKey rawKey={RawKey.BackQuote} />
              <ButtonKey rawKey={RawKey.Num1} />
              <ButtonKey rawKey={RawKey.Num2} />
              <ButtonKey rawKey={RawKey.Num3} />
              <ButtonKey rawKey={RawKey.Num4} />
              <ButtonKey rawKey={RawKey.Num5} />
              <ButtonKey rawKey={RawKey.Num6} />
              <ButtonKey rawKey={RawKey.Num7} />
              <ButtonKey rawKey={RawKey.Num8} />
              <ButtonKey rawKey={RawKey.Num9} />
              <ButtonKey rawKey={RawKey.Num0} />
              <ButtonKey rawKey={RawKey.Minus} />
              <ButtonKey rawKey={RawKey.Equal} />
              <ButtonKey rawKey={RawKey.Backspace} className="flex-2" flexGrow />
              <ButtonKey rawKey={RawKey.Home} />
            </div>

            {/* Row 3: QWERTY */}
            <div className="flex gap-2 justify-between w-full">
              <ButtonKey rawKey={RawKey.Tab} className="flex-3" flexGrow />
              <ButtonKey rawKey={RawKey.KeyQ} />
              <ButtonKey rawKey={RawKey.KeyW} />
              <ButtonKey rawKey={RawKey.KeyE} />
              <ButtonKey rawKey={RawKey.KeyR} />
              <ButtonKey rawKey={RawKey.KeyT} />
              <ButtonKey rawKey={RawKey.KeyY} />
              <ButtonKey rawKey={RawKey.KeyU} />
              <ButtonKey rawKey={RawKey.KeyI} />
              <ButtonKey rawKey={RawKey.KeyO} />
              <ButtonKey rawKey={RawKey.KeyP} />
              <ButtonKey rawKey={RawKey.LeftBracket} />
              <ButtonKey rawKey={RawKey.RightBracket} />
              <ButtonKey rawKey={RawKey.BackSlash} className="flex-2" />
              <ButtonKey rawKey={RawKey.End} />
            </div>

            {/* Row 4: ASDF */}
            <div className="flex gap-2 justify-between w-full">
              <ButtonKey rawKey={RawKey.CapsLock} className="flex-4" flexGrow />
              <ButtonKey rawKey={RawKey.KeyA} />
              <ButtonKey rawKey={RawKey.KeyS} />
              <ButtonKey rawKey={RawKey.KeyD} />
              <ButtonKey rawKey={RawKey.KeyF} />
              <ButtonKey rawKey={RawKey.KeyG} />
              <ButtonKey rawKey={RawKey.KeyH} />
              <ButtonKey rawKey={RawKey.KeyJ} />
              <ButtonKey rawKey={RawKey.KeyK} />
              <ButtonKey rawKey={RawKey.KeyL} />
              <ButtonKey rawKey={RawKey.SemiColon} />
              <ButtonKey rawKey={RawKey.Quote} />
              <ButtonKey rawKey={RawKey.Return} className="flex-4" flexGrow />
              <ButtonKey rawKey={RawKey.PageUp} />
            </div>

            {/* Row 5: ZXCV */}
            <div className="flex gap-2 justify-between w-full">
              <ButtonKey rawKey={RawKey.ShiftLeft} className="flex-5" flexGrow />
              <ButtonKey rawKey={RawKey.KeyZ} />
              <ButtonKey rawKey={RawKey.KeyX} />
              <ButtonKey rawKey={RawKey.KeyC} />
              <ButtonKey rawKey={RawKey.KeyV} />
              <ButtonKey rawKey={RawKey.KeyB} />
              <ButtonKey rawKey={RawKey.KeyN} />
              <ButtonKey rawKey={RawKey.KeyM} />
              <ButtonKey rawKey={RawKey.Comma} />
              <ButtonKey rawKey={RawKey.Dot} />
              <ButtonKey rawKey={RawKey.Slash} />
              <ButtonKey rawKey={RawKey.ShiftRight} className="flex-4" flexGrow />
              <ButtonKey rawKey={RawKey.UpArrow} />
              <ButtonKey rawKey={RawKey.PageDown} />
            </div>

            {/* Row 6: Bottom & Arrows */}
            <div className="flex gap-2 justify-between h-12 w-full">
              <ButtonKey rawKey={RawKey.ControlLeft} className="flex-1" />
              <ButtonKey rawKey={RawKey.Alt} className="flex-1" />
              <ButtonKey rawKey={RawKey.MetaLeft} className="flex-1" />
              <ButtonKey rawKey={RawKey.Space} className="flex-4" flexGrow />
              <ButtonKey rawKey={RawKey.ControlRight} className="flex-1" />
              <ButtonKey rawKey={RawKey.LeftArrow} />
              <ButtonKey rawKey={RawKey.DownArrow} />
              <ButtonKey rawKey={RawKey.RightArrow} />
            </div>
          </div>
        }
        {
          activeTab === 'Mouse' &&
          <div
            className="h-fit w-fit p-5 grid grid-cols-3 gap-4 justify-center bg-secondary rounded-t-[44%] rounded-b-[40%]"
          >
            <ButtonKey rawKey={RawKey.Left} className="mt-7" />
            <div className="flex flex-col gap-4 items-center">
              <ButtonKey rawKey={RawKey.Middle} />
              <ButtonKey rawKey={RawKey.ScrollUp} />
              <ButtonKey rawKey={RawKey.ScrollDown} />
              <ButtonKey rawKey={RawKey.Drag} />
            </div>
            <ButtonKey rawKey={RawKey.Right} className="mt-7" />
          </div>
        }
        {
          activeTab === 'Numpad' &&
          <div
            className="w-56 p-3 grid grid-cols-4 gap-2 bg-secondary rounded-2xl"
          >
            {/* Row 1 */}
            <ButtonKey rawKey={RawKey.NumLock} />
            <ButtonKey rawKey={RawKey.KpDivide} />
            <ButtonKey rawKey={RawKey.KpMultiply} />
            <ButtonKey rawKey={RawKey.KpMinus} />

            {/* Row 2 */}
            <ButtonKey rawKey={RawKey.Kp7} />
            <ButtonKey rawKey={RawKey.Kp8} />
            <ButtonKey rawKey={RawKey.Kp9} />
            <ButtonKey rawKey={RawKey.KpPlus} className="row-span-2" flexGrow />

            {/* Row 3 */}
            <ButtonKey rawKey={RawKey.Kp4} />
            <ButtonKey rawKey={RawKey.Kp5} />
            <ButtonKey rawKey={RawKey.Kp6} />
            {/* <div /> */}

            {/* Row 4 */}
            <ButtonKey rawKey={RawKey.Kp3} />
            <ButtonKey rawKey={RawKey.Kp2} />
            <ButtonKey rawKey={RawKey.Kp1} />
            <ButtonKey rawKey={RawKey.KpReturn} className="row-span-2" flexGrow />

            {/* Row 5 */}
            <ButtonKey className="col-span-2" rawKey={RawKey.Kp0} flexGrow />
            <ButtonKey rawKey={RawKey.KpDecimal} />
            <div />
          </div>
        }

        <ToggleGroup
          type="single"
          spacing={4}
          className="p-1 border rounded-xl"
          value={activeTab}
          onValueChange={(value) => setActiveTab(value as 'Keyboard' | 'Mouse' | 'Numpad')}
        >
          <ToggleGroupItem value="Keyboard">{t("settings.customFilter.tab.keyboard")}</ToggleGroupItem>
          <ToggleGroupItem value="Mouse">{t("settings.customFilter.tab.mouse")}</ToggleGroupItem>
          <ToggleGroupItem value="Numpad">{t("settings.customFilter.tab.numpad")}</ToggleGroupItem>
        </ToggleGroup>
      </div>
    </KeyboardContext.Provider>
  );
};
