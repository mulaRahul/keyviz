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
import { ArrowHorizontalIcon, ArrowVerticalIcon, FilterHorizontalIcon, FilterIcon, InternetIcon, LayerIcon, ToggleOnIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { CustomFilter } from '../custom-filter';
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'


export const GeneralSettings = () => {
    const { t, i18n } = useTranslation()
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
        <h1 className="text-xl font-semibold">{t('general', 'General')}</h1>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={InternetIcon} size="1em" /> {t('language', 'Language')}
                </ItemTitle>
            </ItemContent>
            <ItemActions>
                <Select value={i18n.language} onValueChange={(language) => {
                    invoke('set_locale', { locale: language })
                        .then(() => i18n.changeLanguage(language))
                        .catch((error) => {
                            console.error("Failed to change language:", error);
                            toast.error(t('languageChangeFailed', 'Failed to change language.'));
                        });
                }}>
                    <SelectTrigger className="w-28" aria-label={t('language', 'Language')}>
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="en-US">{'English'}</SelectItem>
                            <SelectItem value="zh-CN">{'中文'}</SelectItem>
                            <SelectItem value="fr-FR">{'Français'}</SelectItem>
                            <SelectItem value="es-ES">{'Español'}</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={FilterIcon} size="1em" /> {t('filter', 'Filter')}
                </ItemTitle>
                <ItemDescription>
                    {filter === 'none' && t('noFilterAppliedAllKeysWillBeShown', 'No filter applied, all keys will be shown.')}
                    {filter === 'modifiers' && t('onlyModifierKeysWillBeShown', 'Only modifier keys will be shown.')}
                    {filter === 'custom' && t('customFilterAppliedLengthKeysAllowed', 'Custom filter applied, {{length}} keys allowed.', { length: allowedKeys.length })}
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
                                    <DrawerTitle>{t('customFilter', 'Custom Filter')}</DrawerTitle>
                                    <DrawerDescription>{t('selectWhichKeysToDisplayHoldDownCtrlTo', 'Select which keys to display. Hold down Ctrl to toggle related keys.')}</DrawerDescription>
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
                    <ToggleGroupItem value="none" aria-label={t('noFilter', 'No Filter')}>{t('off', 'Off')}</ToggleGroupItem>
                    <ToggleGroupItem value="modifiers" aria-label={t('modifiersOnly', 'Modifiers Only')}>{t('hotkeys', 'Hotkeys')}</ToggleGroupItem>
                    <ToggleGroupItem value="custom" aria-label={t('customFilter', 'Custom Filter')}>{t('custom', 'Custom')}</ToggleGroupItem>
                </ToggleGroup>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LayerIcon} size="1em" /> {t('history', 'History')}
                </ItemTitle>
                <ItemDescription>
                    {t('keepPreviouslyPressedKeystrokesInTheView', 'Keep previously pressed keystrokes in the view')}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch checked={showEventHistory} onCheckedChange={setShowEventHistory} />
            </ItemActions>
        </Item>

        <div className={cn("flex flex-col gap-4 md:flex-row", showEventHistory ? "" : "pointer-events-none opacity-50", "transition-opacity")}>
            <Item variant="muted" className="flex-7">
                <ItemContent>
                    <ItemTitle>{t('direction', 'Direction')}</ItemTitle>
                </ItemContent>
                <ItemActions>
                    <ToggleGroup
                        size="sm"
                        type="single"
                        variant="outline"
                        value={direction}
                        onValueChange={(value) => setAppearance({ flexDirection: value as KeyStyleState["appearance"]["flexDirection"] })}
                    >
                        <ToggleGroupItem value="row" aria-label={t('horizontal', 'Horizontal')}>
                            <HugeiconsIcon icon={ArrowHorizontalIcon} strokeWidth={2} size={10} /> {t('row', 'Row')}
                        </ToggleGroupItem>
                        <ToggleGroupItem value="column" aria-label={t('vertical', 'Vertical')}>
                            <HugeiconsIcon icon={ArrowVerticalIcon} strokeWidth={2} /> {t('column', 'Column')}
                        </ToggleGroupItem>
                    </ToggleGroup>
                </ItemActions>
            </Item>
            <Item variant="muted" className="flex-5">
                <ItemContent>
                    <ItemTitle>{t('maxCount', 'Max Count')}</ItemTitle>
                </ItemContent>
                <ItemActions className="max-w-20">
                    <NumberInput className="h-8" value={maxHistory} onChange={setMaxHistory} minValue={2} maxValue={12} />
                </ItemActions>
            </Item>
        </div>

        <Item variant="muted">
            <ItemHeader className="flex-col items-start">
                <ItemTitle>
                    <HugeiconsIcon icon={ToggleOnIcon} size="1em" /> {t('toggleShortcut', 'Toggle Shortcut')}
                </ItemTitle>
                <ItemDescription>
                    {t('globalShortcutToShowhideTheKeyVisualizer', 'Global shortcut to show/hide the key visualizer, click box to set')}
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