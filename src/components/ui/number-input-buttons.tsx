import { HugeiconsIcon } from "@hugeicons/react";
import { Button } from "./button";
import { ButtonGroup } from "./button-group";
import { Input } from "./input";
import { MinusSignIcon, PlusSignIcon } from "@hugeicons/core-free-icons";

export const NumberInput = ({ value, onChange, min, max, step }: { value: number; onChange: (value: number) => void; min?: number; max?: number; step?: number }) => {
    return (
        <ButtonGroup>
            <Input
                id="number-input"
                value={value}
                onChange={(e) => {
                    const val = parseInt(e.target.value, 10);
                    if (!isNaN(val)) {
                        onChange(val);
                    }
                }}
                type="number"
                min={min}
                max={max}
                step={step}
                className="w-20 text-right"
            />
            <Button
                variant="outline"
                size="icon"
                type="button"
                aria-label="Decrement"
                onClick={() => onChange(value - (step ?? 1))}
                disabled={value <= (min ?? -Infinity)}
            >
                <HugeiconsIcon icon={MinusSignIcon} strokeWidth={2} />
            </Button>
            <Button
                variant="outline"
                size="icon"
                type="button"
                aria-label="Increment"
                onClick={() => onChange(value + (step ?? 1))}
                disabled={value >= (max ?? Infinity)}
            >
                <HugeiconsIcon icon={PlusSignIcon} strokeWidth={2} />
            </Button>
        </ButtonGroup>
    );
};