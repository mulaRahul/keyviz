import { useEffect, useState } from "react";

import { AlignmentSelector } from "@/components/ui/alignment-selector";
import { Button } from "@/components/ui/button";
import { Item, ItemActions, ItemContent, ItemDescription, ItemTitle } from "@/components/ui/item";
import MultiSelect from "@/components/ui/multi-select";
import { NumberInput } from "@/components/ui/number-input";
import { NumberScrubber } from "@/components/ui/number-input-scrub";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Toggle } from "@/components/ui/toggle";
import { useKeyEvent } from "@/stores/key_event";
import { BROWSER_DISPLAY, useKeyStyle } from "@/stores/key_style";
import { ComputerIcon, KeyframesDoubleIcon, KeyframesDoubleRemoveIcon, Link02Icon, ParagraphSpacingIcon, TextAlignLeftIcon, Time03Icon, Unlink02Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { availableMonitors, Monitor } from "@tauri-apps/api/window";
import { useTranslation } from 'react-i18next'
import { invoke } from "@tauri-apps/api/core";


export const AppearanceSettings = () => {
    const { t } = useTranslation()
    const appearance = useKeyStyle(state => state.appearance);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    const lingerDurationMs = useKeyEvent(state => state.lingerDurationMs);
    const setLingerDurationMs = useKeyEvent(state => state.setLingerDurationMs);

    const [marginLinked, setMarginLinked] = useState(appearance.marginX === appearance.marginY);
    const [monitors, setMonitors] = useState<Monitor[]>([]);
    const browserSourcePort = useKeyStyle(state => state.browserSourcePort);
    const setBrowserSourcePort = useKeyStyle(state => state.setBrowserSourcePort);
    const [browserPort, setBrowserPort] = useState<number | null>(null);
    const browserSelected = appearance.monitors?.includes(BROWSER_DISPLAY) ?? false;

    // The server is started by the main window when this output is selected,
    // so the actual port (which may fall back) is only known a moment later.
    useEffect(() => {
        if (!browserSelected) {
            setBrowserPort(null);
            return;
        }

        let cancelled = false;
        const poll = (attempt: number) => {
            invoke<number | null>("browser_source_port")
                .catch(() => null)
                .then((value) => {
                    if (cancelled) return;
                    if (value) setBrowserPort(value);
                    else if (attempt < 10) window.setTimeout(() => poll(attempt + 1), 200);
                });
        };
        poll(0);

        return () => {
            cancelled = true;
        };
    }, [browserSelected, browserSourcePort]);

    useEffect(() => {
        availableMonitors().then(setMonitors);
    }, []);

    // `null` means the user never picked anything, so the UI shows the default
    // selection (keycaps on the first display, mouse effects everywhere). An
    // empty array is a real choice and is shown as empty.
    const displayNames = monitors.map((monitor, index) => monitor.name ?? index.toString());
    const keySelection = appearance.monitors ?? (displayNames.length > 0 ? [displayNames[0]] : []);
    const mouseSelection = appearance.mouseMonitors ?? displayNames;

    const monitorOptions = monitors.map((monitor, index) => {
        // Windows reports names like `\\.\DISPLAY1`; the tail is what the user
        // recognises, and it keeps the trigger chips short.
        const shortName = monitor.name?.split("\\").pop() ?? `Display ${index + 1}`;
        return {
            value: monitor.name ?? index.toString(),
            label: shortName,
        };
    });

    const keycapOptions = [
        ...monitorOptions,
        { value: BROWSER_DISPLAY, label: "Browser (OBS)" },
    ];

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t('appearance', 'Appearance')}</h1>

        <h2 className="text-sm text-muted-foreground font-medium">{t('position', 'Position')}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ComputerIcon} size="1em" />
                    {t('keycapDisplays', 'Keycap displays')}
                </ItemTitle>
                <ItemDescription>
                    {t('keycapDisplaysDescription', 'Displays that show the keycaps.')}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <MultiSelect
                    key={`keys-${keySelection.join(",")}-${monitors.length}`}
                    options={keycapOptions}
                    defaultValue={keySelection}
                    onValueChange={(value: string[]) => setAppearance({ monitors: value })}
                    placeholder={t('selectDisplays', 'Select displays')}
                    className="w-56"
                    popoverClass="w-64"
                />
                <Switch
                    checked={appearance.keycapsEnabled ?? true}
                    onCheckedChange={(checked) => setAppearance({ keycapsEnabled: checked })}
                    aria-label={t('showKeycaps', 'Show keycaps')}
                />
            </ItemActions>
        </Item>

        {
            browserSelected &&
            <Item variant="muted">
                <ItemContent>
                    <ItemTitle>
                        <HugeiconsIcon icon={Link02Icon} size="1em" />
                        {t('browserSource', 'Browser source')}
                    </ItemTitle>
                    <ItemDescription>
                    {t('browserSourceDescription', 'Serves the keycaps as a page at')}{" "}
                    <span className="font-mono text-foreground">
                        http://127.0.0.1:{browserPort ?? browserSourcePort}/
                    </span>
                </ItemDescription>
                </ItemContent>
                <ItemActions>
                    <NumberInput
                        value={browserSourcePort}
                        onChange={(value) => setBrowserSourcePort(Math.round(value))}
                        minValue={1024}
                        maxValue={65535}
                        className="w-28 h-8"
                    />
                    <Button
                        variant="outline"
                        size="icon-sm"
                        aria-label="Copy browser source URL"
                        onClick={() => navigator.clipboard.writeText(`http://127.0.0.1:${browserPort ?? browserSourcePort}/`)}
                    >
                        <HugeiconsIcon icon={Link02Icon} size="1em" />
                    </Button>
                </ItemActions>
            </Item>
        }

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={ComputerIcon} size="1em" />
                    {t('mouseDisplays', 'Mouse displays')}
                </ItemTitle>
                <ItemDescription>
                    {t('mouseDisplaysDescription', 'Displays that show clicks and the mouse indicator.')}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <MultiSelect
                    key={`mouse-${mouseSelection.join(",")}-${monitors.length}`}
                    options={monitorOptions}
                    defaultValue={mouseSelection}
                    onValueChange={(value: string[]) => setAppearance({ mouseMonitors: value })}
                    placeholder={t('selectDisplays', 'Select displays')}
                    className="w-56"
                    popoverClass="w-64"
                />
                <Switch
                    checked={appearance.mouseEnabled ?? true}
                    onCheckedChange={(checked) => setAppearance({ mouseEnabled: checked })}
                    aria-label={t('showMouseVisuals', 'Show mouse visuals')}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent className="self-start">
                <ItemTitle>
                    <HugeiconsIcon icon={TextAlignLeftIcon} size="1em" /> {t('alignment', 'Alignment')}
                </ItemTitle>
                <ItemDescription>
                    {t('positionOfTheKeyVisualizationOnTheScreen', 'Position of the key visualization on the screen')}
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
                    <HugeiconsIcon icon={ParagraphSpacingIcon} size="1em" /> {t('margin', 'Margin')}
                </ItemTitle>
                <ItemDescription>
                    {t('spaceFromTheEdgeOfTheScreen', 'Space from the edge of the screen')}
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
                    aria-label={t('marginLinked', 'Margin linked')}
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

        <h2 className="text-sm text-muted-foreground font-medium">{t('animation', 'Animation')}</h2>
        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Time03Icon} size="1em" /> {t('duration', 'Duration')}
                </ItemTitle>
                <ItemDescription className="max-w-84">
                    {t('theDurationKeysStayOnScreenInSeconds', 'The duration keys stay on screen (in seconds)')}
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
                    <HugeiconsIcon icon={KeyframesDoubleIcon} size="1em" /> {t('animation', 'Animation')}
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <Select value={appearance.animation} onValueChange={(value) => setAppearance({ animation: value as any })}>
                    <SelectTrigger className="w-32">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="none">{t('none', 'None')}</SelectItem>
                            <SelectItem value="fade">{t('fade', 'Fade')}</SelectItem>
                            <SelectItem value="zoom">{t('zoom', 'Zoom')}</SelectItem>
                            <SelectItem value="float">{t('float', 'Float')}</SelectItem>
                            <SelectItem value="slide">{t('slide', 'Slide')}</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={KeyframesDoubleRemoveIcon} size="1em" /> {t('animationSpeed', 'Animation Speed')}
                </ItemTitle>
                <ItemDescription>
                    {t('higherTheValueSlowerTheAnimation', 'Higher the value, slower the animation')}
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