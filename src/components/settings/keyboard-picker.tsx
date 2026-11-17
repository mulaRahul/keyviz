import { Button } from "@/components/ui/button";
import { Item, ItemActions, ItemContent, ItemDescription, ItemTitle } from "@/components/ui/item";
import { Select, SelectContent, SelectGroup, SelectItem, SelectSeparator, SelectTrigger, SelectValue } from "@/components/ui/select";
import { BUILTIN_GLYPHS, BUILTIN_ICONS, duplicateKeyboard, listUserKeyboards, loadKeyboardSvg, openKeyboardFolder } from "@/lib/keyboard";
import { useKeyStyle } from "@/stores/key_style";
import { Copy01Icon, FolderOpenIcon, RefreshIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useCallback, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { toast } from "sonner";

// "" is not a valid Select value
const ICONS_VALUE = "builtin:icons";

export const KeyboardPicker = () => {
    const { t } = useTranslation();
    const keyboard = useKeyStyle(state => state.keyboard);
    const setKeyboard = useKeyStyle(state => state.setKeyboard);
    const [userKeyboards, setUserKeyboards] = useState<string[]>([]);

    const fail = (err: unknown) => toast.error(t("Keyboard error"), {
        description: err instanceof Error ? err.message : String(err),
    });

    const select = useCallback(async (name: string) => {
        try {
            setKeyboard({ name, svg: await loadKeyboardSvg(name) });
        } catch (err) {
            fail(err);
        }
    }, [setKeyboard]);

    // list the user folder and pick up edits made to the current file
    const refresh = useCallback(async () => {
        try {
            setUserKeyboards(await listUserKeyboards());
            if (keyboard.name) await select(keyboard.name);
        } catch (err) {
            fail(err);
        }
    }, [keyboard.name, select]);

    useEffect(() => {
        void refresh();
        // only on open: later refreshes are manual
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const duplicate = async () => {
        try {
            const fileName = await duplicateKeyboard(keyboard.name);
            setUserKeyboards(await listUserKeyboards());
            await select(fileName);
            await openKeyboardFolder();
            toast.success(t("Keyboard duplicated"), { description: fileName });
        } catch (err) {
            fail(err);
        }
    };

    return <Item variant="muted">
        <ItemContent>
            <ItemTitle>{t("Keyboard")}</ItemTitle>
            <ItemDescription>{t("Key drawings, one SVG file per keyboard")}</ItemDescription>
        </ItemContent>
        <ItemActions>
            <Select
                value={keyboard.name === BUILTIN_ICONS ? ICONS_VALUE : keyboard.name}
                onValueChange={(value) => void select(value === ICONS_VALUE ? BUILTIN_ICONS : value)}
            >
                <SelectTrigger className="w-44">
                    <SelectValue />
                </SelectTrigger>
                <SelectContent>
                    <SelectGroup>
                        <SelectItem value={ICONS_VALUE}>{t("Icons (default)")}</SelectItem>
                        <SelectItem value={BUILTIN_GLYPHS}>{t("Glyphs")}</SelectItem>
                    </SelectGroup>
                    {userKeyboards.length > 0 && <SelectSeparator />}
                    <SelectGroup>
                        {userKeyboards.map(name => (
                            <SelectItem key={name} value={name}>{name.replace(/\.svg$/i, "")}</SelectItem>
                        ))}
                    </SelectGroup>
                </SelectContent>
            </Select>
            <Button variant="outline" size="icon" title={t("Duplicate to edit")} onClick={duplicate}>
                <HugeiconsIcon icon={Copy01Icon} />
            </Button>
            <Button variant="outline" size="icon" title={t("Open keyboard folder")} onClick={() => openKeyboardFolder().catch(fail)}>
                <HugeiconsIcon icon={FolderOpenIcon} />
            </Button>
            <Button variant="ghost" size="icon" title={t("Reload")} onClick={refresh}>
                <HugeiconsIcon icon={RefreshIcon} />
            </Button>
        </ItemActions>
    </Item>;
};
