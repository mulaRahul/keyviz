import { useState } from "react";

import { AlignmentSelector } from "@/components/ui/alignment-selector";
import { Item, ItemActions, ItemContent, ItemDescription, ItemTitle } from "@/components/ui/item";
import { NumberInput } from "@/components/ui/number-input";
import { NumberScrubber } from "@/components/ui/number-input-scrub";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Toggle } from "@/components/ui/toggle";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { BounceRightIcon, ComputerIcon, KeyframesDoubleIcon, KeyframesDoubleRemoveIcon, Link02Icon, ParagraphSpacingIcon, TextAlignLeftIcon, Time03Icon, Unlink02Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { Switch } from "@/components/ui/switch";

export const AppearanceSettings = () => {

    const [marginLinked, setMarginLinked] = useState(true);

    const { alignment, marginX, marginY, animation, animationDuration, motionBlur } = useKeyStyle(state => state.appearance);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    const lingerDurationMs = useKeyEvent(state => state.lingerDurationMs);
    const setLingerDurationMs = useKeyEvent(state => state.setLingerDurationMs);

    return <div className="flex flex-col gap-y-4 p-6 pb-10">
        <h1 className="text-xl font-semibold">Appearance</h1>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ComputerIcon} size="1em" />
                    Display
                </ItemTitle>
                <ItemDescription>
                    Change monitor/display for the visualisation.
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Select>
                    <SelectTrigger className="w-32">
                        <SelectValue placeholder="Select Display" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="display-1">Display 1</SelectItem>
                            <SelectItem value="display-2">Display 2</SelectItem>
                            <SelectItem value="display-3">Display 3</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent className="self-start">
                <ItemTitle>
                    <HugeiconsIcon icon={TextAlignLeftIcon} size="1em" /> Alignment
                </ItemTitle>
                <ItemDescription>
                    Position of the key visualization on the screen
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <AlignmentSelector className="w-32" value={alignment} onChange={(value) => setAppearance({ alignment: value })} />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ParagraphSpacingIcon} size="1em" /> Margin
                </ItemTitle>
                <ItemDescription>
                    Space from the edge of the screen
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberScrubber
                    value={marginX}
                    onChange={marginLinked ? (v => { setAppearance({ marginX: v }); setAppearance({ marginY: v }); }) : (v => setAppearance({ marginX: v }))}
                    min={0}
                    max={200}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">X</span>}
                    className="w-18"
                />
                <Toggle variant="default" pressed={marginLinked} onPressedChange={setMarginLinked} aria-label="Margin linked" >
                    <HugeiconsIcon icon={marginLinked ? Link02Icon : Unlink02Icon} size="1em" />
                </Toggle>
                <NumberScrubber
                    value={marginY}
                    onChange={(value) => setAppearance({ marginY: value })}
                    min={0}
                    max={200}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">Y</span>}
                    className="w-18"
                    disabled={marginLinked}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Time03Icon} size="1em" /> Duration
                </ItemTitle>
                <ItemDescription className="max-w-84">
                    Amount of time the keys linger before disappearing in seconds
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    value={lingerDurationMs / 1000}
                    onChange={(value) => setLingerDurationMs(value * 1000)}
                    step={0.2}
                    className="w-32 h-8"
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleIcon} size="1em" /> Animation
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <Select value={animation} onValueChange={(value) => setAppearance({ animation: value as any })}>
                    <SelectTrigger className="w-32">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="none">None</SelectItem>
                            <SelectItem value="fade">Fade</SelectItem>
                            <SelectItem value="zoom">Zoom</SelectItem>
                            <SelectItem value="slide">Slide</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleRemoveIcon} size="1em" /> Animation Speed
                </ItemTitle>
                <ItemDescription>
                    Higher the value, slower the animation
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    value={animationDuration / 1000}
                    onChange={(value) => setAppearance({ animationDuration: value * 1000 })}
                    step={0.1}
                    className="w-32 h-8"
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={BounceRightIcon} size="1em" /> Motion Blur
                </ItemTitle>
                <ItemDescription>
                    Enable motion blur effect on key animations
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch checked={motionBlur} onCheckedChange={(value) => setAppearance({ motionBlur: value })} />
            </ItemActions>
        </Item>
    </div>;
}