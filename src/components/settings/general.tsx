import { invoke } from '@tauri-apps/api/core';

import { ShortcutRecorder } from '@/components/shortcut-recorder';
import { useI18n } from '@/hooks/use-i18n';
import type { Language } from '@/i18n';
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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from "@/components/ui/switch";
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group';
import { cn } from "@/lib/utils";
import { KeyEventState, useKeyEvent } from "@/stores/key_event";
import { KeyStyleState, useKeyStyle } from "@/stores/key_style";
import { usePreferences } from "@/stores/preferences";
import { ArrowHorizontalIcon, ArrowVerticalIcon, FilterHorizontalIcon, FilterIcon, LanguageSquareIcon, LayerIcon, ToggleOnIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { CustomFilter } from '../custom-filter';


export const GeneralSettings = () => {
    const {
        filter, setFilter,
        allowedKeys,
        showEventHistory, setShowEventHistory,
        maxHistory, setMaxHistory,
        toggleShortcut, setToggleShortcut
    } = useKeyEvent();

    const direction = useKeyStyle(state => state.appearance.flexDirection);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    const { t } = useI18n();
    const language = usePreferences(state => state.language);
    const setLanguage = usePreferences(state => state.setLanguage);

    const onLanguageChange = (value: string) => {
        const nextLanguage = value as Language;
        setLanguage(nextLanguage);
        invoke('set_app_language', { language: nextLanguage });
    };

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t("settings.general.title")}</h1>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LanguageSquareIcon} size="1em" /> {t("settings.general.language.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.general.language.description")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Select value={language} onValueChange={onLanguageChange}>
                    <SelectTrigger className="w-40">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="en">
                            {t("settings.general.language.option.en")}
                        </SelectItem>
                        <SelectItem value="zh-CN">
                            {t("settings.general.language.option.zhCN")}
                        </SelectItem>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={FilterIcon} size="1em" /> {t("settings.general.filter.title")}
                </ItemTitle>
                <ItemDescription>
                    {filter === 'none' && t("settings.general.filter.state.none")}
                    {filter === 'modifiers' && t("settings.general.filter.state.modifiers")}
                    {filter === 'custom' && t("settings.general.filter.state.custom", { count: allowedKeys.length })}
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
                                    <DrawerTitle>{t("settings.general.filter.drawer.title")}</DrawerTitle>
                                    <DrawerDescription>{t("settings.general.filter.drawer.description")}</DrawerDescription>
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
                    <ToggleGroupItem value="none" aria-label={t("settings.general.filter.aria.none")}>{t("settings.general.filter.option.off")}</ToggleGroupItem>
                    <ToggleGroupItem value="modifiers" aria-label={t("settings.general.filter.aria.modifiers")}>{t("settings.general.filter.option.hotkeys")}</ToggleGroupItem>
                    <ToggleGroupItem value="custom" aria-label={t("settings.general.filter.aria.custom")}>{t("settings.general.filter.option.custom")}</ToggleGroupItem>
                </ToggleGroup>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LayerIcon} size="1em" /> {t("settings.general.history.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.general.history.description")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch checked={showEventHistory} onCheckedChange={setShowEventHistory} />
            </ItemActions>
        </Item>

        <div className={cn("flex flex-col gap-4 md:flex-row", showEventHistory ? "" : "pointer-events-none opacity-50", "transition-opacity")}>
            <Item variant="muted" className="flex-7">
                <ItemContent>
                    <ItemTitle>{t("settings.general.direction.title")}</ItemTitle>
                </ItemContent>
                <ItemActions>
                    <ToggleGroup
                        size="sm"
                        type="single"
                        variant="outline"
                        value={direction}
                        onValueChange={(value) => setAppearance({ flexDirection: value as KeyStyleState["appearance"]["flexDirection"] })}
                    >
                        <ToggleGroupItem value="row" aria-label={t("settings.general.direction.aria.horizontal")}>
                            <HugeiconsIcon icon={ArrowHorizontalIcon} strokeWidth={2} size={10} /> {t("settings.general.direction.row")}
                        </ToggleGroupItem>
                        <ToggleGroupItem value="column" aria-label={t("settings.general.direction.aria.vertical")}>
                            <HugeiconsIcon icon={ArrowVerticalIcon} strokeWidth={2} /> {t("settings.general.direction.column")}
                        </ToggleGroupItem>
                    </ToggleGroup>
                </ItemActions>
            </Item>
            <Item variant="muted" className="flex-5">
                <ItemContent>
                    <ItemTitle>{t("settings.general.maxCount.title")}</ItemTitle>
                </ItemContent>
                <ItemActions className="max-w-20">
                    <NumberInput className="h-8" value={maxHistory} onChange={setMaxHistory} minValue={2} maxValue={12} />
                </ItemActions>
            </Item>
        </div>

        <Item variant="muted">
            <ItemHeader className="flex-col items-start">
                <ItemTitle>
                    <HugeiconsIcon icon={ToggleOnIcon} size="1em" /> {t("settings.general.toggleShortcut.title")}
                </ItemTitle>
                <ItemDescription>
                    {t("settings.general.toggleShortcut.description")}
                </ItemDescription>
            </ItemHeader>
            <ItemContent>
                <ShortcutRecorder value={toggleShortcut} onChange={shortcut => {
                    setToggleShortcut(shortcut);
                    invoke('set_toggle_shortcut', { shortcut });
                }} />
            </ItemContent>
        </Item>
    </div>;
}
