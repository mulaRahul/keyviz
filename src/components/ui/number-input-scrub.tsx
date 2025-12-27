import React, { useState, useRef, useEffect, useCallback } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { MoveHorizontal } from "lucide-react"; // Default icon

interface NumberScrubberProps
  extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "onChange"> {
  label?: string;
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  step?: number;
  sensitivity?: number; // How many pixels dragged = 1 step
  icon?: React.ReactNode;
}

export function NumberScrubber({
  label,
  value,
  onChange,
  min = -Infinity,
  max = Infinity,
  step = 1,
  sensitivity = 2, // Higher number = slower scrubbing
  icon,
  className,
  ...props
}: NumberScrubberProps) {
  const [isDragging, setIsDragging] = useState(false);
  const startX = useRef<number>(0);
  const startValue = useRef<number>(0);

  // Helper to clamp value between min and max
  const clamp = (val: number) => Math.min(Math.max(val, min), max);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault(); // Prevent text selection
    setIsDragging(true);
    startX.current = e.clientX;
    startValue.current = value;
    
    document.body.style.cursor = "ew-resize";
  };

  // We use useCallback so we can reference these in useEffect
  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (!isDragging) return;

      const deltaX = e.clientX - startX.current;
      
      // Calculate how many "steps" we've moved based on sensitivity
      const stepsMoved = Math.round(deltaX / sensitivity);
      
      // Calculate new value
      const newValue = startValue.current + stepsMoved * step;
      
      // Handle floating point precision issues (optional, but good for UX)
      // and clamp the result
      const precision = step.toString().split(".")[1]?.length || 0;
      const roundedValue = parseFloat(newValue.toFixed(precision));
      
      onChange(clamp(roundedValue));
    },
    [isDragging, sensitivity, step, min, max, onChange]
  );

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    document.body.style.cursor = "";
  }, []);

  // Attach global event listeners when dragging starts
  useEffect(() => {
    if (isDragging) {
      window.addEventListener("mousemove", handleMouseMove);
      window.addEventListener("mouseup", handleMouseUp);
    } else {
      window.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("mouseup", handleMouseUp);
    }

    return () => {
      window.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("mouseup", handleMouseUp);
    };
  }, [isDragging, handleMouseMove, handleMouseUp]);

  return (
    <div className={cn("grid w-full max-w-sm items-center gap-1.5", className)}>
      {label && <Label htmlFor={props.id}>{label}</Label>}
      
      <div className="relative group">
        {/* Scrubber Icon Area */}
        <div
          className={cn(
            "absolute left-0 top-0 bottom-0 px-2 flex items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground cursor-ew-resize select-none z-10",
            isDragging && "ring-2 ring-ring ring-offset-2",
            props.disabled && "pointer-events-none"
          )}
          onMouseDown={handleMouseDown}
          title="Click and drag to scrub"
        >
          {icon}
        </div>

        {/* The Input */}
        <Input
          type="number"
          value={value}
          onChange={(e) => {
            const val = parseFloat(e.target.value);
            if (!isNaN(val)) onChange(clamp(val));
          }}
          className="pl-8 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
          {...props}
        />
      </div>
    </div>
  );
}