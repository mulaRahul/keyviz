import { useEffect, useState } from "react";

import { useI18n } from "@/i18n";
import { AlignmentSelector } from "@/components/ui/alignment-selector";
import { Item, ItemActions, ItemContent, ItemDescription, ItemTitle } from "@/components/ui/item";
import { NumberInput } from "@/components/ui/number-input";
import { NumberScrubber } from "@/components/ui/number-input-scrub";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Toggle } from "@/components/ui/toggle";
import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { ComputerIcon, KeyframesDoubleIcon, KeyframesDoubleRemoveIcon, Link02Icon, ParagraphSpacingIcon, TextAlignLeftIcon, Time03Icon, Unlink02Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { availableMonitors, Monitor } from "@tauri-apps/api/window";


export const AppearanceSettings = () => {
    const { t } = useI18n();
    const appearance = useKeyStyle(state => state.appearance);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    const lingerDurationMs = useKeyEvent(state => state.lingerDurationMs);
    const setLingerDurationMs = useKeyEvent(state => state.setLingerDurationMs);

    const [marginLinked, setMarginLinked] = useState(appearance.marginX === appearance.marginY);
    const [monitors, setMonitors] = useState<Monitor[]>([]);

    useEffect(() => {
        availableMonitors().then(monitors => {
            if (!appearance.monitor && monitors.length > 1) {
                setAppearance({ monitor: monitors[0].name });
            }
            setMonitors(monitors);
        });
    }, []);

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t("Appearance", "外观")}</h1>

        <h2 className="text-sm text-muted-foreground font-medium">{t("Position", "位置")}</h2>
        {
            monitors.length > 1 &&
            <Item variant="muted">
                <ItemContent>
                    <ItemTitle>
                        <HugeiconsIcon icon={ComputerIcon} size="1em" />
                        {t("Display", "显示器")}
                    </ItemTitle>
                    <ItemDescription>
                        {t("Change monitor/display for the visualisation.", "切换按键显示所使用的显示器。")}
                    </ItemDescription>
                </ItemContent>
                <ItemActions>
                    <Select
                        value={appearance.monitor ?? ""}
                        onValueChange={(value) => {
                            setAppearance({ monitor: value });
                        }}
                    >
                        <SelectTrigger className="w-32">
                            <SelectValue placeholder={t("Select Display", "选择显示器")} />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectGroup>
                                {
                                    monitors.map((monitor, index) => (
                                        <SelectItem key={monitor.name} value={monitor.name ?? index.toString()}>
                                            {monitor.name ?? `Display ${index + 1}`} ({monitor.size.width}x{monitor.size.height})
                                        </SelectItem>
                                    ))
                                }
                            </SelectGroup>
                        </SelectContent>
                    </Select>
                </ItemActions>
            </Item>
        }

        <Item variant="muted">
            <ItemContent className="self-start">
                <ItemTitle>
                    <HugeiconsIcon icon={TextAlignLeftIcon} size="1em" /> {t("Alignment", "对齐")}
                </ItemTitle>
                <ItemDescription>
                    {t("Position of the key visualization on the screen", "按键显示在屏幕上的位置")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <AlignmentSelector
                    className="w-32 h-28 text-base"
                    value={appearance.alignment}
                    onChange={(value) => setAppearance({ alignment: value })}
                    disabledOptions={["center"]}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ParagraphSpacingIcon} size="1em" /> {t("Margin", "边距")}
                </ItemTitle>
                <ItemDescription>
                    {t("Space from the edge of the screen", "距离屏幕边缘的间距")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberScrubber
                    value={appearance.marginX}
                    onChange={marginLinked ? (marginX => { setAppearance({ marginX }); setAppearance({ marginY: marginX }); }) : (marginX => setAppearance({ marginX }))}
                    min={0}
                    max={200}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">X</span>}
                    className="w-18"
                />
                <Toggle
                    variant="default"
                    pressed={marginLinked}
                    onPressedChange={(pressed) => {
                        setMarginLinked(pressed);
                        if (pressed) {
                            setAppearance({ marginY: appearance.marginX });
                        }
                    }}
                    aria-label="Margin linked"
                >
                    <HugeiconsIcon icon={marginLinked ? Link02Icon : Unlink02Icon} size="1em" />
                </Toggle>
                <NumberScrubber
                    value={appearance.marginY}
                    onChange={(marginY) => setAppearance({ marginY })}
                    min={0}
                    max={200}
                    step={1}
                    icon={<span className="ml-0.5 text-xs font-medium">Y</span>}
                    className="w-18"
                    disabled={marginLinked}
                />
            </ItemActions>
        </Item>

        <h2 className="text-sm text-muted-foreground font-medium">{t("Animation", "动画")}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Time03Icon} size="1em" /> {t("Duration", "停留时长")}
                </ItemTitle>
                <ItemDescription className="max-w-84">
                    {t("How long released keys stay on screen (in seconds)", "按键释放后在屏幕上保留的时间（秒）")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    value={lingerDurationMs / 1000}
                    onChange={(value) => setLingerDurationMs(value * 1000)}
                    step={0.2}
                    minValue={0}
                    className="w-32 h-8"
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleIcon} size="1em" /> {t("Animation", "动画类型")}
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <Select value={appearance.animation} onValueChange={(value) => setAppearance({ animation: value as any })}>
                    <SelectTrigger className="w-32">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="none">{t("None", "无")}</SelectItem>
                            <SelectItem value="fade">{t("Fade", "淡入淡出")}</SelectItem>
                            <SelectItem value="zoom">{t("Zoom", "缩放")}</SelectItem>
                            <SelectItem value="float">{t("Float", "上浮")}</SelectItem>
                            <SelectItem value="slide">{t("Slide", "滑动")}</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleRemoveIcon} size="1em" /> {t("Animation Speed", "动画速度")}
                </ItemTitle>
                <ItemDescription>
                    {t("Higher values make the animation slower", "数值越大，动画越慢")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <NumberInput
                    value={appearance.animationDuration}
                    onChange={(animationDuration) => setAppearance({ animationDuration })}
                    step={0.05}
                    minValue={0.05}
                    maxValue={1}
                    className="w-32 h-8"
                />
            </ItemActions>
        </Item>
    </div>;
}
