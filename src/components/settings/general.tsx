import { invoke } from '@tauri-apps/api/core';

import { LanguageSelect } from "@/components/settings/language-select";
import { useI18n } from "@/i18n";
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
import { ArrowHorizontalIcon, ArrowVerticalIcon, FilterHorizontalIcon, FilterIcon, LayerIcon, Settings03Icon, ToggleOnIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { CustomFilter } from '../custom-filter';


export const GeneralSettings = () => {
    const { t } = useI18n();
    const {
        filter, setFilter,
        allowedKeys,
        showEventHistory, setShowEventHistory,
        maxHistory, setMaxHistory,
        toggleShortcut, setToggleShortcut
    } = useKeyEvent();

    const appearance = useKeyStyle(state => state.appearance);
    const direction = appearance.flexDirection;
    const setAppearance = useKeyStyle(state => state.setAppearance);

    return <div className="flex flex-col gap-y-4 p-6">
        <h1 className="text-xl font-semibold">{t("General", "通用")}</h1>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={Settings03Icon} size="1em" /> {t("Language", "语言")}
                </ItemTitle>
                <ItemDescription>
                    {t("Choose the app language or follow the system setting.", "选择应用语言，或跟随系统语言设置。")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <LanguageSelect />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LayerIcon} size="1em" /> {t("Always On Top", "窗口置顶")}
                </ItemTitle>
                <ItemDescription>
                    {t("Keep the overlay above other windows.", "让按键显示层始终保持在其他窗口上方。")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch
                    checked={appearance.alwaysOnTop}
                    onCheckedChange={(alwaysOnTop) => setAppearance({ alwaysOnTop })}
                />
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={FilterIcon} size="1em" /> {t("Filter", "过滤")}
                </ItemTitle>
                <ItemDescription>
                    {filter === 'none' && t('No filter applied, all keys will be shown.', '不过滤，显示所有按键。')}
                    {filter === 'modifiers' && t('Only modifier keys will be shown.', '仅显示修饰键组合。')}
                    {filter === 'custom' && t(`Custom filter applied, ${allowedKeys.length} keys allowed.`, `已启用自定义过滤，当前允许 ${allowedKeys.length} 个按键。`)}
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
                                    <DrawerTitle>{t("Custom Filter", "自定义过滤")}</DrawerTitle>
                                    <DrawerDescription>{t("Select which keys to display. Hold down Ctrl to toggle related keys.", "选择要显示的按键。按住 Ctrl 可切换关联按键。")}</DrawerDescription>
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
                    <ToggleGroupItem value="none" aria-label={t("No Filter", "无过滤")}>{t("Off", "关闭")}</ToggleGroupItem>
                    <ToggleGroupItem value="modifiers" aria-label={t("Modifiers Only", "仅修饰键")}>{t("Hotkeys", "快捷键")}</ToggleGroupItem>
                    <ToggleGroupItem value="custom" aria-label={t("Custom Filter", "自定义过滤")}>{t("Custom", "自定义")}</ToggleGroupItem>
                </ToggleGroup>
            </ItemActions>
        </Item>

        <Item variant="muted">
            <ItemContent>
                <ItemTitle>
                    <HugeiconsIcon icon={LayerIcon} size="1em" /> {t("History", "历史记录")}
                </ItemTitle>
                <ItemDescription>
                    {t("Keep previously pressed keystrokes in the view", "在画面中保留之前按过的按键")}
                </ItemDescription>
            </ItemContent>
            <ItemActions>
                <Switch checked={showEventHistory} onCheckedChange={setShowEventHistory} />
            </ItemActions>
        </Item>

        <div className={cn("flex flex-col gap-4 md:flex-row", showEventHistory ? "" : "pointer-events-none opacity-50", "transition-opacity")}>
            <Item variant="muted" className="flex-7">
                <ItemContent>
                    <ItemTitle>{t("Direction", "方向")}</ItemTitle>
                </ItemContent>
                <ItemActions>
                    <ToggleGroup
                        size="sm"
                        type="single"
                        variant="outline"
                        value={direction}
                        onValueChange={(value) => setAppearance({ flexDirection: value as KeyStyleState["appearance"]["flexDirection"] })}
                    >
                        <ToggleGroupItem value="row" aria-label={t("Horizontal", "水平")}>
                            <HugeiconsIcon icon={ArrowHorizontalIcon} strokeWidth={2} size={10} /> {t("Row", "横向")}
                        </ToggleGroupItem>
                        <ToggleGroupItem value="column" aria-label={t("Vertical", "垂直")}>
                            <HugeiconsIcon icon={ArrowVerticalIcon} strokeWidth={2} /> {t("Column", "纵向")}
                        </ToggleGroupItem>
                    </ToggleGroup>
                </ItemActions>
            </Item>
            <Item variant="muted" className="flex-5">
                <ItemContent>
                    <ItemTitle>{t("Max Count", "最大数量")}</ItemTitle>
                </ItemContent>
                <ItemActions className="max-w-20">
                    <NumberInput className="h-8" value={maxHistory} onChange={setMaxHistory} minValue={2} maxValue={12} />
                </ItemActions>
            </Item>
        </div>

        <Item variant="muted">
            <ItemHeader className="flex-col items-start">
                <ItemTitle>
                    <HugeiconsIcon icon={ToggleOnIcon} size="1em" /> {t("Toggle Shortcut", "切换快捷键")}
                </ItemTitle>
                <ItemDescription>
                    {t("Global shortcut to show/hide the key visualizer, click box to set", "用于显示/隐藏按键可视化的全局快捷键，点击输入框设置")}
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
