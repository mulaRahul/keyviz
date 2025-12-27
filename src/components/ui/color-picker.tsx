'use client';

import { colord, extend } from 'colord';
import namesPlugin from 'colord/plugins/names';
import { PipetteIcon } from 'lucide-react';
import { Slider } from 'radix-ui';
import {
  type ComponentProps,
  createContext,
  type HTMLAttributes,
  memo,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { cn } from '@/lib/utils';

// Enable CSS color names (e.g., "red")
extend([namesPlugin]);

// --- Context ---

interface ColorPickerContextValue {
  hue: number;
  saturation: number;
  lightness: number;
  alpha: number;
  mode: string;
  setHue: (hue: number) => void;
  setSaturation: (saturation: number) => void;
  setLightness: (lightness: number) => void;
  setAlpha: (alpha: number) => void;
  setMode: (mode: string) => void;
}

const ColorPickerContext = createContext<ColorPickerContextValue | undefined>(
  undefined
);

export const useColorPicker = () => {
  const context = useContext(ColorPickerContext);
  if (!context) {
    throw new Error('useColorPicker must be used within a ColorPickerProvider');
  }
  return context;
};

// --- Main Component ---

export type ColorPickerProps = HTMLAttributes<HTMLDivElement> & {
  value?: string; // Hex, rgba, etc.
  defaultValue?: string;
  onChange?: (value: string) => void; // #RRGGBBAA
};

export const ColorPicker = ({
  value,
  defaultValue = '#000000',
  onChange,
  className,
  ...props
}: ColorPickerProps) => {
  // Initialize state from value or defaultValue
  const initialColor = useMemo(() => {
    return colord(value || defaultValue).toHsl();
  }, [value, defaultValue]);

  const [hue, setHue] = useState(initialColor.h);
  const [saturation, setSaturation] = useState(initialColor.s);
  const [lightness, setLightness] = useState(initialColor.l);
  const [alpha, setAlpha] = useState(initialColor.a * 100);
  const [mode, setMode] = useState('hex');

  // Sync state if external value prop changes
  useEffect(() => {
    if (value) {
      // Don't update internal state if the incoming value is effectively the same
      // as what we already have.
      const currentColor = colord({ h: hue, s: saturation, l: lightness, a: alpha / 100 });
      if (currentColor.isEqual(value)) return;

      const newColor = colord(value).toHsl();
      setHue(newColor.h);
      setSaturation(newColor.s);
      setLightness(newColor.l);
      setAlpha(newColor.a * 100);
    }
  }, [value]);

  // Notify parent of changes
  useEffect(() => {
    if (onChange) {
      const color = colord({ h: hue, s: saturation, l: lightness, a: alpha / 100 });
      const newHex = color.toHex();
      // Only fire onChange if the new color is different from the prop passed in.
      if (value && colord(value).isEqual(newHex)) {
        return;
      }
      // toHex() automatically handles alpha:
      // - Returns #RRGGBB if alpha is 100%
      // - Returns #RRGGBBAA if alpha is < 100%
      onChange(newHex);
    }
  }, [hue, saturation, lightness, alpha, onChange]);

  return (
    <ColorPickerContext.Provider
      value={{
        hue,
        saturation,
        lightness,
        alpha,
        mode,
        setHue,
        setSaturation,
        setLightness,
        setAlpha,
        setMode,
      }}
    >
      <div
        className={cn('flex w-full flex-col gap-4', className)}
        {...props}
      />
    </ColorPickerContext.Provider>
  );
};

// --- Sub Components ---

export const ColorPickerSelection = memo(
  ({ className, ...props }: HTMLAttributes<HTMLDivElement>) => {
    const containerRef = useRef<HTMLDivElement>(null);
    const [isDragging, setIsDragging] = useState(false);
    const { hue, saturation, lightness, setSaturation, setLightness } = useColorPicker();

    // 1. Determine Thumb Position
    // We must convert the current HSL state to HSV to correctly position the thumb
    // on this specific visual gradient (which is an HSV gradient).
    const { s: hsvS, v: hsvV } = useMemo(() => {
      return colord({ h: hue, s: saturation, l: lightness }).toHsv();
    }, [hue, saturation, lightness]);

    // 2. Background Gradient (Standard HSV Picker)
    // Bottom: Black, Right: White -> Transparent, Base: Hue
    const backgroundGradient = useMemo(() => {
      return `
        linear-gradient(to top, #000 0%, transparent 100%), 
        linear-gradient(to right, #fff 0%, transparent 100%), 
        hsl(${hue}, 100%, 50%)
      `;
    }, [hue]);

    const updateColorFromInteraction = useCallback(
      (clientX: number, clientY: number) => {
        if (!containerRef.current) return;
        const rect = containerRef.current.getBoundingClientRect();

        // 3. Get Mouse Position (0 to 1)
        const x = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width));
        const y = Math.max(0, Math.min(1, (clientY - rect.top) / rect.height));

        // 4. Convert Mouse(HSV) -> State(HSL)
        // X is HSV Saturation (0-100)
        // Y is HSV Value (100-0) (Inverted because top is bright)
        const newHsvS = x * 100;
        const newHsvV = (1 - y) * 100;

        // We use colord to convert HSV -> HSL safely
        const newColor = colord({ h: hue, s: newHsvS, v: newHsvV });
        const { s, l } = newColor.toHsl();

        setSaturation(s);
        setLightness(l);
      },
      [hue, setSaturation, setLightness]
    );

    const handlePointerMove = useCallback(
      (event: PointerEvent) => {
        updateColorFromInteraction(event.clientX, event.clientY);
      },
      [updateColorFromInteraction]
    );

    const handlePointerDown = (e: React.PointerEvent) => {
      e.preventDefault(); // Prevent text selection
      setIsDragging(true);
      updateColorFromInteraction(e.clientX, e.clientY);
    };

    useEffect(() => {
      const handleUp = () => setIsDragging(false);
      const handleMove = (e: PointerEvent) => {
        if (isDragging) handlePointerMove(e);
      };

      if (isDragging) {
        window.addEventListener('pointermove', handleMove);
        window.addEventListener('pointerup', handleUp);
      }
      return () => {
        window.removeEventListener('pointermove', handleMove);
        window.removeEventListener('pointerup', handleUp);
      };
    }, [isDragging, handlePointerMove]);

    return (
      <div
        ref={containerRef}
        className={cn('relative h-40 w-full cursor-crosshair rounded-md shadow-sm', className)}
        style={{ background: backgroundGradient }}
        onPointerDown={handlePointerDown}
        {...props}
      >
        <div
          className="pointer-events-none absolute h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow-sm ring-1 ring-black/10"
          style={{
            // Position based on HSV values, not HSL state
            left: `${hsvS}%`,
            top: `${100 - hsvV}%`,
          }}
        />
      </div>
    );
  }
);
ColorPickerSelection.displayName = 'ColorPickerSelection';

export const ColorPickerHue = ({ className, ...props }: ComponentProps<typeof Slider.Root>) => {
  const { hue, setHue } = useColorPicker();

  return (
    <Slider.Root
      className={cn('relative flex h-4 w-full touch-none select-none items-center', className)}
      value={[hue]}
      max={360}
      step={1}
      onValueChange={([val]) => setHue(val)}
      {...props}
    >
      <Slider.Track className="relative h-3 w-full grow rounded-full bg-[linear-gradient(to_right,red,yellow,lime,cyan,blue,magenta,red)]">
        <Slider.Range className="absolute h-full rounded-full" />
      </Slider.Track>
      <Slider.Thumb className="block h-4 w-4 rounded-full border border-primary/50 bg-background shadow transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50" />
    </Slider.Root>
  );
};

export const ColorPickerAlpha = ({ className, ...props }: ComponentProps<typeof Slider.Root>) => {
  const { alpha, setAlpha, hue, saturation, lightness } = useColorPicker();

  // Create a gradient that fades from transparent to the current color
  const colorHex = colord({ h: hue, s: saturation, l: lightness }).toHex();

  return (
    <Slider.Root
      className={cn('relative flex h-4 w-full touch-none select-none items-center', className)}
      value={[alpha]}
      max={100}
      step={1}
      onValueChange={([val]) => setAlpha(val)}
      {...props}
    >
      {/* Checkerboard background for alpha indication */}
      <Slider.Track className="relative h-3 w-full grow overflow-hidden rounded-full border border-black/5 bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4IiBoZWlnaHQ9IjgiPgo8cmVjdCB3aWR0aD0iOCIgaGVpZ2h0PSI4IiBmaWxsPSIjZmZmIi8+CjxyZWN0IHdpZHRoPSI0IiBoZWlnaHQ9IjQiIGZpbGw9IiNjY2MiLz4KPHJlY3QgeD0iNCIgeT0iNCIgd2lkdGg9IjQiIGhlaWdodD0iNCIgZmlsbD0iI2NjYyIvPgo8L3N2Zz4=')]">
        {/* Gradient overlay */}
        <div
          className="absolute inset-0 h-full w-full"
          style={{ background: `linear-gradient(to right, transparent, ${colorHex})` }}
        />
        <Slider.Range className="absolute h-full" />
      </Slider.Track>
      <Slider.Thumb className="block h-4 w-4 rounded-full border border-primary/50 bg-background shadow transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50" />
    </Slider.Root>
  );
};

export const ColorPickerEyeDropper = ({ className, ...props }: ComponentProps<typeof Button>) => {
  const { setHue, setSaturation, setLightness, setAlpha } = useColorPicker();

  // Safe check for browser support
  const isSupported = typeof window !== 'undefined' && 'EyeDropper' in window;

  const handleEyeDropper = async () => {
    if (!isSupported) return;

    try {
      // @ts-expect-error - EyeDropper API is experimental
      const eyeDropper = new EyeDropper();
      const result = await eyeDropper.open();
      const color = colord(result.sRGBHex);
      const { h, s, l, a } = color.toHsl();

      setHue(h);
      setSaturation(s);
      setLightness(l);
      setAlpha(a * 100);
    } catch (error) {
      console.error('EyeDropper cancelled or failed:', error);
    }
  };

  if (!isSupported) return null;

  return (
    <Button
      variant="outline"
      size="icon"
      className={cn('shrink-0', className)}
      onClick={handleEyeDropper}
      {...props}
    >
      <PipetteIcon className="h-4 w-4" />
    </Button>
  );
};

// --- Inputs Area ---

export const ColorPickerOutput = ({ className, ...props }: ComponentProps<typeof SelectTrigger>) => {
  const { mode, setMode } = useColorPicker();
  const formats = ['hex', 'rgb', 'hsl', 'css'];

  return (
    <Select value={mode} onValueChange={setMode}>
      <SelectTrigger className={cn('h-8 w-18 px-2 text-xs', className)} {...props}>
        <SelectValue placeholder="Mode" />
      </SelectTrigger>
      <SelectContent>
        {formats.map((f) => (
          <SelectItem key={f} value={f} className="text-xs uppercase">
            {f}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
};

// Helper for Number Inputs
const ChannelInput = ({
  value,
  onChange,
  max = 255,
  label,
  className
}: {
  value: number;
  onChange: (val: number) => void;
  max?: number;
  label?: string;
  className?: string;
}) => {
  return (
    <div className={cn("relative flex items-center", className)}>
      <Input
        value={value}
        onChange={(e) => {
          const val = parseInt(e.target.value);
          if (!isNaN(val)) {
            onChange(Math.max(0, Math.min(max, val)));
          }
        }}
        className="h-8 px-2 pr-2 text-xs"
      />
      {label && <span className="absolute right-2 text-[10px] text-muted-foreground pointer-events-none">{label}</span>}
    </div>
  );
};

export const ColorPickerFormat = ({ className, ...props }: HTMLAttributes<HTMLDivElement>) => {
  const { hue, saturation, lightness, alpha, mode, setHue, setSaturation, setLightness, setAlpha } = useColorPicker();

  const color = colord({ h: hue, s: saturation, l: lightness, a: alpha / 100 });

  // -- Handlers for direct input changes --

  const handleHexChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    const newColor = colord(val);
    if (newColor.isValid()) {
      const { h, s, l, a } = newColor.toHsl();
      setHue(h);
      setSaturation(s);
      setLightness(l);
      // Only update alpha if the hex actually included it (length check or comparison)
      // Standard hex is 6 or 7 chars. 8 or 9 includes alpha.
      if (val.length > 7) setAlpha(a * 100);
    }
  };

  // Render logic based on mode
  if (mode === 'hex') {
    return (
      <div className={cn('flex gap-2', className)} {...props}>
        <div className="relative flex-1">
          <Input
            defaultValue={color.toHex()} // Use defaultValue to allow typing freely
            onBlur={handleHexChange}    // Validate on blur
            key={color.toHex()}         // Force re-render if external state changes
            className="h-8 px-2 text-xs"
          />
          <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[10px] text-muted-foreground pointer-events-none">HEX</span>
        </div>
        <ChannelInput
          value={Math.round(alpha)}
          onChange={setAlpha}
          max={100}
          label="%"
          className="w-14"
        />
      </div>
    );
  }

  if (mode === 'rgb') {
    const { r, g, b } = color.toRgb();
    return (
      <div className={cn('flex gap-1', className)} {...props}>
        <ChannelInput value={r} onChange={(val) => {
          const { h, s, l } = colord({ r: val, g, b }).toHsl();
          setHue(h); setSaturation(s); setLightness(l);
        }} label="R" className="flex-1" />
        <ChannelInput value={g} onChange={(val) => {
          const { h, s, l } = colord({ r, g: val, b }).toHsl();
          setHue(h); setSaturation(s); setLightness(l);
        }} label="G" className="flex-1" />
        <ChannelInput value={b} onChange={(val) => {
          const { h, s, l } = colord({ r, g, b: val }).toHsl();
          setHue(h); setSaturation(s); setLightness(l);
        }} label="B" className="flex-1" />
        <ChannelInput value={Math.round(alpha)} onChange={setAlpha} max={100} label="%" className="w-12" />
      </div>
    );
  }

  if (mode === 'hsl') {
    return (
      <div className={cn('flex gap-1', className)} {...props}>
        <ChannelInput value={Math.round(hue)} onChange={setHue} max={360} label="H" className="flex-1" />
        <ChannelInput value={Math.round(saturation)} onChange={setSaturation} max={100} label="S" className="flex-1" />
        <ChannelInput value={Math.round(lightness)} onChange={setLightness} max={100} label="L" className="flex-1" />
        <ChannelInput value={Math.round(alpha)} onChange={setAlpha} max={100} label="%" className="w-12" />
      </div>
    );
  }

  if (mode === 'css') {
    return (
      <div className={cn('flex w-full', className)} {...props}>
        <Input
          readOnly
          value={`rgba(${color.toRgb().r}, ${color.toRgb().g}, ${color.toRgb().b}, ${alpha / 100})`}
          className="h-8 flex-1 px-2 text-xs"
        />
      </div>
    );
  }

  return null;
};