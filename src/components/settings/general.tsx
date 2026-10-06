import { invoke } from '@tauri-apps/api/core';

import { ShortcutRecorder } from '@/components/shortcut-recorder';
import { Button } from '@/components/ui/button';
import {
    Drawer,
    DrawerContent,
    DrawerDescription,
    DrawerHeader,
    DrawerTitle,
    DrawerTrigger,
} from "@/components/ui/drawer";
import { Item, ItemActions, ItemContent, ItemDescription, ItemHeader, ItemTitle } from "@/components/ui/item";
import { NumberInput } from '@/components/ui/number-input';
import { Switch } from "@/components/ui/switch";
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group';
import { cn } from "@/lib/utils";
import { KeyEventState, useKeyEvent } from "@/stores/key_event";
import { KeyStyleState, useKeyStyle } from "@/stores/key_style";
import { ArrowHorizontalIcon, ArrowVerticalIcon, FilterHorizontalIcon, FilterIcon, LayerIcon, ToggleOnIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { CustomFilter } from '../custom-filter';
import { useTranslation } from "react-i18next";
import { getLanguagePreference, setLanguagePreference, type LanguagePreference } from "@/i18n";
import { useState } from "react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";


export const GeneralSettings = () => {
    const { t } = useTranslation();
    const [languagePreference, setPreference] = useState(getLanguagePreference());
    const {
        filter, setFilter,
        allowedKeys,
        showEventHistory, setShowEventHistory,
        maxHistory, setMaxHistory,
        toggleShortcut, setToggleShortcut
    } = useKeyEvent();

    const direction = useKeyStyle(state => state.appearance.flexDirection);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t("General")}</h1>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={FilterIcon} size="1em" /> {t("Filter")}
                </ItemTitle>
                <ItemDescription>
                    {filter === 'none' && t("No filter applied, all keys will be shown.")}
                    {filter === 'modifiers' && t("Only modifier keys will be shown.")}
                    {filter === 'custom' && t(
                        allowedKeys.length === 1
                            ? "Custom filter applied, one key allowed."
                            : "Custom filter applied, {{count}} keys allowed.",
                        { count: allowedKeys.length },
                    )}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                {
                    filter === 'custom' &&
                    <Drawer>
                        <DrawerTrigger asChild>
                            <Button variant="outline" size="icon-sm">
                                <HugeiconsIcon icon={FilterHorizontalIcon} />
                            </Button>
                        </DrawerTrigger>
                        <DrawerContent>
                            <DrawerContent>
                                <DrawerHeader>
                                    <DrawerTitle>{t("Custom Filter")}</DrawerTitle>
                                    <DrawerDescription>{t("Select which keys to display. Hold down Ctrl to toggle related keys.")}</DrawerDescription>
                                </DrawerHeader>
                                <CustomFilter />
                            </DrawerContent>
                        </DrawerContent>
                    </Drawer>
                }
                <ToggleGroup
                    size="sm"
                    type="single"
                    variant="outline"
                    value={filter}
                    onValueChange={(value) => setFilter(value as KeyEventState["filter"])}
                >
                    <ToggleGroupItem value="none" aria-label={t("No Filter")}>{t("Off")}</ToggleGroupItem>
                    <ToggleGroupItem value="modifiers" aria-label={t("Modifiers Only")}>{t("Hotkeys")}</ToggleGroupItem>
                    <ToggleGroupItem value="custom" aria-label={t("Custom Filter")}>{t("Custom")}</ToggleGroupItem>
                </ToggleGroup>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LayerIcon} size="1em" /> {t("History")}
                </ItemTitle>
                <ItemDescription>
                    {t("Keep previously pressed keystrokes in the view")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch checked={showEventHistory} onCheckedChange={setShowEventHistory} />
            </ItemActions>
        </Item>

        <div className={cn("flex flex-col gap-4 md:flex-row", showEventHistory ? "" : "pointer-events-none opacity-50", "transition-opacity")}>
            <Item variant="muted" className="flex-7">
                <ItemContent>
                    <ItemTitle>{t("Direction")}</ItemTitle>
                </ItemContent>
                <ItemActions>
                    <ToggleGroup
                        size="sm"
                        type="single"
                        variant="outline"
                        value={direction}
                        onValueChange={(value) => setAppearance({ flexDirection: value as KeyStyleState["appearance"]["flexDirection"] })}
                    >
                        <ToggleGroupItem value="row" aria-label={t("Horizontal")}>
                            <HugeiconsIcon icon={ArrowHorizontalIcon} strokeWidth={2} size={10} /> {t("Row")}
                        </ToggleGroupItem>
                        <ToggleGroupItem value="column" aria-label={t("Vertical")}>
                            <HugeiconsIcon icon={ArrowVerticalIcon} strokeWidth={2} /> {t("Column")}
                        </ToggleGroupItem>
                    </ToggleGroup>
                </ItemActions>
            </Item>
            <Item variant="muted" className="flex-5">
                <ItemContent>
                    <ItemTitle>{t("Max Count")}</ItemTitle>
                </ItemContent>
                <ItemActions className="max-w-20">
                    <NumberInput className="h-8" value={maxHistory} onChange={setMaxHistory} minValue={2} maxValue={12} />
                </ItemActions>
            </Item>
        </div>

        <Item variant="muted">
            <ItemHeader className="flex-col items-start">
                <ItemTitle>
                    <HugeiconsIcon icon={ToggleOnIcon} size="1em" /> {t("Toggle Shortcut")}
                </ItemTitle>
                <ItemDescription>
                    {t("Global shortcut to show/hide the key visualizer, click box to set")}
                </ItemDescription>
            </ItemHeader>
            <ItemContent>
                <ShortcutRecorder value={toggleShortcut} onChange={shortcut => {
                    setToggleShortcut(shortcut);
                    invoke('set_toggle_shortcut', { shortcut });
                }} />
            </ItemContent>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>{t("Language")}</ItemTitle>
                <ItemDescription>{t("Choose the interface language")}</ItemDescription>
            </ItemContent>
            <ItemActions>
                <Select
                    value={languagePreference}
                    onValueChange={(value) => {
                        if (value !== "system" && value !== "en" && value !== "fr") return;
                        const preference = value as LanguagePreference;
                        setPreference(preference);
                        void setLanguagePreference(preference);
                    }}
                >
                    <SelectTrigger className="w-36">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="system">{t("System")}</SelectItem>
                        <SelectItem value="fr">{t("Français")}</SelectItem>
                        <SelectItem value="en">{t("English")}</SelectItem>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>
    </div>;
}