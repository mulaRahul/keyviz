import { Button } from './button';
import { ColorPicker, ColorPickerAlpha, ColorPickerEyeDropper, ColorPickerFormat, ColorPickerHue, ColorPickerOutput, ColorPickerSelection } from "./color-picker";
import { Popover, PopoverContent, PopoverTrigger } from "./popover";


export const ColorInput = ({ value: colorHex, onChange }: { value: string; onChange: (color: string) => void }) => {
    return <Popover>
        <PopoverTrigger asChild>
            <Button variant="outline" size="lg" className="w-32 justify-start gap-2 px-1">
                <div className="h-6 aspect-square rounded-sm border" style={{ backgroundColor: colorHex }}></div>
                {colorHex}
            </Button>
        </PopoverTrigger>
        <PopoverContent align="start" className="w-72 h-72">
            <ColorPicker value={colorHex} onChange={c => onChange(c.toString())} className="w-64 h-64">
                <ColorPickerSelection />
                <div className="flex items-center gap-4">
                    <ColorPickerEyeDropper />
                    <div className="grid w-full gap-1">
                        <ColorPickerHue />
                        <ColorPickerAlpha />
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    <ColorPickerOutput />
                    <ColorPickerFormat />
                </div>
            </ColorPicker>
        </PopoverContent>
    </Popover>;
}