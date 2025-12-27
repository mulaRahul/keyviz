import { ChevronDownIcon, ChevronUpIcon } from "lucide-react";
import { Button, Group, Input, NumberField, type NumberFieldProps } from "react-aria-components";

function NumberInput({ ...props }: NumberFieldProps) {
  return (
    <NumberField {...props}>
      <Group className="relative inline-flex h-full w-full items-center overflow-hidden rounded-md border border-input text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none data-disabled:opacity-50 data-focus-within:border-ring data-focus-within:ring-[3px] data-focus-within:ring-ring/50 data-focus-within:has-aria-invalid:border-destructive data-focus-within:has-aria-invalid:ring-destructive/20 dark:data-focus-within:has-aria-invalid:ring-destructive/40">
        <Input className="w-full bg-background/50 px-3 py-2 text-foreground tabular-nums" />
        <div className="flex h-[calc(100%+2px)] flex-col">
          <Button
            slot="increment"
            className="-me-px flex h-1/2 w-6 flex-1 items-center justify-center border border-input bg-background/50 text-sm text-muted-foreground/80 transition-[color,box-shadow] hover:bg-accent hover:text-foreground disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
          >
            <ChevronUpIcon size={12} aria-hidden="true" />
          </Button>
          <Button
            slot="decrement"
            className="-me-px -mt-px flex h-1/2 w-6 flex-1 items-center justify-center border border-input bg-background/50 text-sm text-muted-foreground/80 transition-[color,box-shadow] hover:bg-accent hover:text-foreground disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
          >
            <ChevronDownIcon size={12} aria-hidden="true" />
          </Button>
        </div>
      </Group>
    </NumberField>
  );
};

export { NumberInput };