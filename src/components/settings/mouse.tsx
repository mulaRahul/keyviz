import { ColorInput } from "@/components/ui/color-picker";
import { Item, ItemActions, ItemContent, ItemDescription, ItemGrid, ItemTitle } from "@/components/ui/item";
import { NumberInput } from "@/components/ui/number-input";
import { Switch } from "@/components/ui/switch";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from '@/stores/key_style';
import { ArrowExpand02Icon, Cursor01Icon, CursorCircleSelection01Icon, CursorEdit01Icon, CursorMagicSelection03FreeIcons, Drag03Icon, Link02Icon, MouseLeftClick05Icon, PaintBoardIcon, Unlink02Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { NumberScrubber } from "../ui/number-input-scrub";
import { useState } from "react";
import { Toggle } from "../ui/toggle";


export const MouseSettings = () => {
    const mouse = useKeyStyle(state => state.mouse);
    const setMouseStyle = useKeyStyle(state => state.setMouse);

    const dragThreshold = useKeyEvent(state => state.dragThreshold);
    const setDragThreshold = useKeyEvent(state => state.setDragThreshold);

    const [offsetLinked, setOffsetLinked] = useState(true);

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">Mouse</h1>

        <h2 className="text-sm text-muted-foreground font-medium">Cursor Highlight</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={CursorMagicSelection03FreeIcons} size="1em" /> Show Clicks
                </ItemTitle>
                <ItemDescription>
                    Animate a ring upon mouse press
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch
                    checked={mouse.showClicks}
                    onCheckedChange={(showClicks) => setMouseStyle({ showClicks })}
                />
            </ItemActions>
        </Item>

        <ItemGrid>
            <Item variant="muted">
                <ItemContent>
                    <ItemTitle>
                        <HugeiconsIcon icon={CursorCircleSelection01Icon} size="1em" /> Size
                    </ItemTitle>
                </ItemContent>
                <ItemActions>
                    <NumberInput
                        step={10}
                        className="w-32 h-8"
                        value={mouse.size}
                        onChange={(size) => setMouseStyle({ size })}
                    />
                </ItemActions>
            </Item>

            <Item variant="muted">
                <ItemContent>
                    <ItemTitle>
                        <HugeiconsIcon icon={PaintBoardIcon} size="1em" /> Color
                    </ItemTitle>
                </ItemContent>
                <ItemActions>
                    <ColorInput
                        className="w-32"
                        value={mouse.color}
                        onChange={(color) => setMouseStyle({ color })}
                        disabled={!mouse.showClicks}
                    />
                </ItemActions>
            </Item>
        </ItemGrid>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Cursor01Icon} size="1em" /> Always Highlight
                </ItemTitle>
                <ItemDescription>
                    Permanently show the ring around the cursor
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch
                    checked={mouse.keepHighlight}
                    onCheckedChange={(keepHighlight) => setMouseStyle({ keepHighlight })}
                    disabled={!mouse.showClicks}
                />
            </ItemActions>
        </Item>

        <h2 className="text-sm text-muted-foreground font-medium mt-2">Button Indicator</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={MouseLeftClick05Icon} size="1em" /> Show Indicator
                </ItemTitle>
                <ItemDescription>
                    Display button and scroll icons next to the cursor
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch
                    checked={mouse.showIndicator}
                    onCheckedChange={(showIndicator) => setMouseStyle({ showIndicator })}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Cursor01Icon} size="1em" /> Keep Indicator
                </ItemTitle>
                <ItemDescription>
                    Permanently show the icon beside the cursor
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch
                    checked={mouse.keepIndicator}
                    onCheckedChange={(keepIndicator) => setMouseStyle({ keepIndicator })}
                    disabled={!mouse.showIndicator}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={CursorEdit01Icon} size="1em" /> Size
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    className="w-32 h-8"
                    value={mouse.indicatorSize}
                    onChange={(indicatorSize) => setMouseStyle({ indicatorSize })}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ArrowExpand02Icon} size="1em" /> Offset
                </ItemTitle>
                <ItemDescription>
                    Space from the cursor to the indicator
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberScrubber
                    value={mouse.indicatorOffsetX}
                    onChange={offsetLinked ? (indicatorOffsetX => { setMouseStyle({ indicatorOffsetX }); setMouseStyle({ indicatorOffsetY: indicatorOffsetX }); }) : (indicatorOffsetX => setMouseStyle({ indicatorOffsetX }))}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">X</span>}
                    className="w-18"
                />
                <Toggle
                    variant="default"
                    pressed={offsetLinked}
                    onPressedChange={(pressed) => {
                        setOffsetLinked(pressed);
                        if (pressed) {
                            setMouseStyle({ indicatorOffsetY: mouse.indicatorOffsetX });
                        }
                    }}
                    aria-label="Offset linked"
                >
                    <HugeiconsIcon icon={offsetLinked ? Link02Icon : Unlink02Icon} size="1em" />
                </Toggle>
                <NumberScrubber
                    value={mouse.indicatorOffsetY}
                    onChange={(indicatorOffsetY) => setMouseStyle({ indicatorOffsetY })}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">Y</span>}
                    className="w-18"
                    disabled={offsetLinked}
                />
            </ItemActions>
        </Item>

        <h2 className="text-sm text-muted-foreground font-medium mt-2">Event</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Drag03Icon} size="1em" /> Drag Threshold
                </ItemTitle>
                <ItemDescription>
                    Minimum distance in pixels to show Drag event
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    className="w-32 h-8"
                    value={dragThreshold}
                    onChange={setDragThreshold}
                />
            </ItemActions>
        </Item>
    </div>;
}
