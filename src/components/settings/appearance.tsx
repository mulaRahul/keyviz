import { useEffect, useState } from "react";

import { useI18n } from "@/hooks/use-i18n";
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
        <h1 className="text-xl font-semibold">{t("settings.appearance.title")}</h1>

        <h2 className="text-sm text-muted-foreground font-medium">{t("settings.appearance.section.position")}</h2>
        {
            monitors.length > 1 &&
            <Item variant="muted">
                <ItemContent>
                    <ItemTitle>
                        <HugeiconsIcon icon={ComputerIcon} size="1em" />
                        {t("settings.appearance.position.display.title")}
                    </ItemTitle>
                    <ItemDescription>
                        {t("settings.appearance.position.display.description")}
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
                            <SelectValue placeholder={t("settings.appearance.position.display.placeholder")} />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectGroup>
                                {
                                    monitors.map((monitor, index) => (
                                        <SelectItem key={monitor.name} value={monitor.name ?? index.toString()}>
                                            {monitor.name ?? t("settings.appearance.position.display.index", { index: index + 1 })} ({monitor.size.width}x{monitor.size.height})
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
                    <HugeiconsIcon icon={TextAlignLeftIcon} size="1em" /> {t("settings.appearance.position.alignment.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.appearance.position.alignment.description")}
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
                    <HugeiconsIcon icon={ParagraphSpacingIcon} size="1em" /> {t("settings.appearance.position.margin.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.appearance.position.margin.description")}
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
                    aria-label={t("settings.appearance.position.margin.ariaLinked")}
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

        <h2 className="text-sm text-muted-foreground font-medium">{t("settings.appearance.section.animation")}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Time03Icon} size="1em" /> {t("settings.appearance.animation.duration.title")}
                </ItemTitle>
                <ItemDescription className="max-w-84">
                    {t("settings.appearance.animation.duration.description")}
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
                    <HugeiconsIcon icon={KeyframesDoubleIcon} size="1em" /> {t("settings.appearance.animation.type.title")}
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <Select value={appearance.animation} onValueChange={(value) => setAppearance({ animation: value as any })}>
                    <SelectTrigger className="w-32">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="none">{t("settings.appearance.animation.type.none")}</SelectItem>
                            <SelectItem value="fade">{t("settings.appearance.animation.type.fade")}</SelectItem>
                            <SelectItem value="zoom">{t("settings.appearance.animation.type.zoom")}</SelectItem>
                            <SelectItem value="float">{t("settings.appearance.animation.type.float")}</SelectItem>
                            <SelectItem value="slide">{t("settings.appearance.animation.type.slide")}</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleRemoveIcon} size="1em" /> {t("settings.appearance.animation.speed.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.appearance.animation.speed.description")}
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
