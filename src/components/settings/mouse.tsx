import { ColorInput } from "@/components/ui/color-picker";
import { useI18n } from "@/i18n";
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
    const { t } = useI18n();
    const mouse = useKeyStyle(state => state.mouse);
    const setMouseStyle = useKeyStyle(state => state.setMouse);

    const dragThreshold = useKeyEvent(state => state.dragThreshold);
    const setDragThreshold = useKeyEvent(state => state.setDragThreshold);

    const [offsetLinked, setOffsetLinked] = useState(true);

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t("Mouse", "鼠标")}</h1>

        <h2 className="text-sm text-muted-foreground font-medium">{t("Cursor Highlight", "光标高亮")}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={CursorMagicSelection03FreeIcons} size="1em" /> {t("Show Clicks", "显示点击")}
                </ItemTitle>
                <ItemDescription>
                    {t("Animate a ring upon mouse press", "鼠标按下时显示动画圆环")}
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
                        <HugeiconsIcon icon={CursorCircleSelection01Icon} size="1em" /> {t("Size", "尺寸")}
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
                        <HugeiconsIcon icon={PaintBoardIcon} size="1em" /> {t("Color", "颜色")}
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
                    <HugeiconsIcon icon={Cursor01Icon} size="1em" /> {t("Always Highlight", "始终高亮")}
                </ItemTitle>
                <ItemDescription>
                    {t("Permanently show the ring around the cursor", "始终显示光标周围的高亮圆环")}
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

        <h2 className="text-sm text-muted-foreground font-medium mt-2">{t("Button Indicator", "按键指示器")}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={MouseLeftClick05Icon} size="1em" /> {t("Show Indicator", "显示指示器")}
                </ItemTitle>
                <ItemDescription>
                    {t("Display button and scroll icons next to the cursor", "在光标旁显示按键和滚轮图标")}
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
                    <HugeiconsIcon icon={Cursor01Icon} size="1em" /> {t("Keep Indicator", "常驻指示器")}
                </ItemTitle>
                <ItemDescription>
                    {t("Permanently show the icon beside the cursor", "始终在光标旁显示图标")}
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
                    <HugeiconsIcon icon={CursorEdit01Icon} size="1em" /> {t("Size", "尺寸")}
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
                    <HugeiconsIcon icon={ArrowExpand02Icon} size="1em" /> {t("Offset", "偏移")}
                </ItemTitle>
                <ItemDescription>
                    {t("Space from the cursor to the indicator", "指示器与光标之间的距离")}
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

        <h2 className="text-sm text-muted-foreground font-medium mt-2">{t("Event", "事件")}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Drag03Icon} size="1em" /> {t("Drag Threshold", "拖拽阈值")}
                </ItemTitle>
                <ItemDescription>
                    {t("Minimum distance in pixels to show Drag event", "显示 Drag 事件所需的最小像素距离")}
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
