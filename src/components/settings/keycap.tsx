import { AlignmentSelector } from "@/components/ui/alignment-selector";
import { Button } from "@/components/ui/button";
import { ColorInput } from "@/components/ui/color-picker";
import { useI18n } from "@/i18n";
import { Item, ItemActions, ItemContent, ItemDescription, ItemGrid, ItemGroup, ItemTitle } from "@/components/ui/item";
import { Label } from "@/components/ui/label";
import { NumberInput } from "@/components/ui/number-input";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group";
import { KeyStyleState, useKeyStyle } from "@/stores/key_style";
import { AlignHorizontalCenterIcon, AlignLeftIcon, AlignRightIcon, Download01Icon, PaintBoardIcon, Refresh01Icon, Upload01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { DropdownMenu, DropdownMenuContent, DropdownMenuGroup, DropdownMenuItem, DropdownMenuTrigger } from "../ui/dropdown-menu";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "../ui/collapsible";

export interface KeycapTheme {
    name: string;
    primary: string;
    secondary: string;
    text: string;
}

export const colorSchemes: KeycapTheme[] = [
    {
        name: "Silver",
        primary: "#f8f8f8",
        secondary: "#dcdcdc",
        text: "#000000",
    },
    {
        name: "Stone",
        primary: "#606060",
        secondary: "#4b4b4b",
        text: "#f8f8f8",
    },
    {
        name: "Lime",
        primary: "#606060",
        secondary: "#4b4b4b",
        text: "#D6ED17",
    },
    {
        name: "Cyber",
        primary: "#00B1D2",
        secondary: "#008ea8",
        text: "#FDDB27",
    },
    {
        name: "Turquoise",
        primary: "#42EADD",
        secondary: "#2ec4b8",
        text: "#ffffff",
    },
    {
        name: "Blue",
        primary: "#2196f3",
        secondary: "#1976d2",
        text: "#ffffff",
    },
    {
        name: "Yellow",
        primary: "#FDDB27",
        secondary: "#dfc019",
        text: "#000000",
    },
    {
        name: "Green",
        primary: "#66bb6a",
        secondary: "#43a047",
        text: "#ffffff",
    },
    {
        name: "Pink",
        primary: "#f06292",
        secondary: "#d81b60",
        text: "#ffffff",
    },
    {
        name: "Red",
        primary: "#ef5350",
        secondary: "#c62828",
        text: "#ffffff",
    },
    {
        name: "Pansy",
        primary: "#673ab7",
        secondary: "#4527a0",
        text: "#ffc107",
    },
    {
        name: "Eclipse",
        primary: "#343148",
        secondary: "#252333",
        text: "#D7C49E",
    },
    {
        name: "Bumblebee",
        primary: "#404040",
        secondary: "#2e2e2e",
        text: "#FDDB27",
    },
    {
        name: "Charcoal",
        primary: "#404040",
        secondary: "#2e2e2e",
        text: "#FFFFFF",
    },
];

export const KeycapSettings = () => {
    const { t } = useI18n();
    const appearance = useKeyStyle(state => state.appearance);
    const setAppearance = useKeyStyle(state => state.setAppearance);

    const text = useKeyStyle(state => state.text);
    const setTextStyle = useKeyStyle(state => state.setText);

    const layout = useKeyStyle(state => state.layout);
    const setLayoutStyle = useKeyStyle(state => state.setLayout);

    const modifier = useKeyStyle(state => state.modifier);
    const setModifierStyle = useKeyStyle(state => state.setModifier);

    const color = useKeyStyle(state => state.color);
    const setColorStyle = useKeyStyle(state => state.setColor);

    const border = useKeyStyle(state => state.border);
    const setBorderStyle = useKeyStyle(state => state.setBorder);

    const background = useKeyStyle(state => state.background);
    const setBackgroundStyle = useKeyStyle(state => state.setBackground);

    const importStyle = useKeyStyle(state => state.import);
    const exportStyle = useKeyStyle(state => state.export);

    const onStyleChange = (value: string) => {
        if (value === "minimal") {
            setTextStyle({ variant: "icon" });
            setModifierStyle({ highlight: false });
            setLayoutStyle({ showIcon: true });
        }
        setAppearance({ style: value as KeyStyleState["appearance"]["style"] });
    }

    const randomizeStyle = () => {
        const scheme = colorSchemes[Math.floor(Math.random() * colorSchemes.length)];
        setLayoutStyle({
            showIcon: Math.random() > 0.5,
            showSymbol: Math.random() > 0.5,
        });
        setColorStyle({
            color: scheme.primary,
            secondaryColor: scheme.secondary,
            useGradient: Math.random() > 0.5,
        });
        setBorderStyle({ color: scheme.secondary, radius: Math.random() });
        setTextStyle({ color: scheme.text });
        if (modifier.highlight) {
            const modScheme = colorSchemes[Math.floor(Math.random() * colorSchemes.length)];
            setModifierStyle({
                color: modScheme.primary,
                secondaryColor: modScheme.secondary,
                borderColor: modScheme.secondary,
                textColor: modScheme.text,
            });
        } else if (background.enabled) {
            setBackgroundStyle({ color: scheme.text });
        }
    }

    return <div className="flex flex-col p-6 gap-y-4">
        <h1 className="text-xl font-semibold">{t("Keycap", "键帽")}</h1>

        <h2 className="text-sm text-muted-foreground font-medium">{t("Preset", "预设")}</h2>
        <Item variant="muted">
            <ItemActions className="w-full">
                <Select value={appearance.style} onValueChange={onStyleChange}>
                    <SelectTrigger className="w-28">
                        <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectGroup>
                            <SelectItem value="minimal">{t("Minimal", "极简")}</SelectItem>
                            <SelectItem value="laptop">{t("Laptop", "笔记本")}</SelectItem>
                            <SelectItem value="lowprofile">{t("Lowprofile", "低矮")}</SelectItem>
                            <SelectItem value="pbt" >PBT</SelectItem>
                        </SelectGroup>
                    </SelectContent>
                </Select>
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="outline" size="icon">
                            <HugeiconsIcon icon={PaintBoardIcon} />
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent>
                        <DropdownMenuGroup>
                            {
                                colorSchemes.map((scheme) => (
                                    <DropdownMenuItem key={scheme.name} onClick={() => {
                                        setColorStyle({ color: scheme.primary, secondaryColor: scheme.secondary });
                                        setBorderStyle({ color: scheme.secondary });
                                        setTextStyle({ color: scheme.text });
                                    }
                                    }>
                                        <div
                                            className="w-4 h-4 flex justify-center items-center mr-1 text-center text-xs border border-muted-foreground/20 rounded-xs"
                                            style={{ backgroundColor: scheme.primary, color: scheme.text }}
                                        >
                                            A</div>
                                        {scheme.name}
                                    </DropdownMenuItem>
                                ))
                            }
                        </DropdownMenuGroup>
                    </DropdownMenuContent>
                </DropdownMenu>
                <Button variant="ghost" size="icon" onClick={randomizeStyle} className="active:rotate-90">
                    <HugeiconsIcon icon={Refresh01Icon} />
                </Button>

                <Button variant="outline" size="sm" className="ml-auto" onClick={importStyle}>
                    <HugeiconsIcon icon={Download01Icon} className="mr-2" /> {t("Import", "导入")}
                </Button>
                <Button variant="outline" size="sm" onClick={exportStyle}>
                    <HugeiconsIcon icon={Upload01Icon} className="mr-2" /> {t("Export", "导出")}
                </Button>
            </ItemActions>
        </Item>

        <Collapsible defaultOpen={true}>
            <CollapsibleTrigger>
                <h2 className="text-sm text-muted-foreground font-medium">{t("Text", "文字")}</h2>
            </CollapsibleTrigger>
            <CollapsibleContent className="flex flex-col gap-y-4 pt-4">
                <ItemGrid className="md:grid-cols-[240px_1fr]">
                    <AlignmentSelector
                        value={text.alignment}
                        onChange={(value) => setTextStyle({ alignment: value })}
                        className="w-full h-48 text-2xl"
                    />
                    <ItemGroup>
                        <Item variant="muted" className="flex-2">
                            <ItemContent>
                                <ItemTitle>{t("Size", "尺寸")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <NumberInput
                                    value={text.size}
                                    onChange={(value) => setTextStyle({ size: value })} minValue={8}
                                    className="w-28 h-8"
                                />
                            </ItemActions>
                        </Item>
                        <Item variant="muted" className="flex-2">
                            <ItemContent>
                                <ItemTitle>{t("Variant", "样式")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <Select value={text.variant} onValueChange={(value) => {
                                    setTextStyle({ variant: value as KeyStyleState["text"]["variant"] });
                                    if (value === "icon") {
                                        setLayoutStyle({ showIcon: true });
                                    }
                                }}>
                                    <SelectTrigger className="w-28">
                                        <SelectValue placeholder="text variant" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="text">{t("Full Text", "完整文字")}</SelectItem>
                                        <SelectItem value="text-short">{t("Short Text", "短文字")}</SelectItem>
                                        <SelectItem value="icon">{t("Icon Only", "仅图标")}</SelectItem>
                                    </SelectContent>
                                </Select>

                            </ItemActions>
                        </Item>
                        <Item variant="muted" className="flex-2">
                            <ItemContent>
                                <ItemTitle>{t("Text Case", "大小写")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <ToggleGroup
                                    type="single"
                                    value={text.caps} onValueChange={(value) => setTextStyle({ caps: value as KeyStyleState["text"]["caps"] })}
                                    variant="outline"
                                    className="w-28"
                                >
                                    <ToggleGroupItem className="w-1/3" value="uppercase">AA</ToggleGroupItem>
                                    <ToggleGroupItem className="w-1/3" value="capitalize">Aa</ToggleGroupItem>
                                    <ToggleGroupItem className="w-1/3" value="lowercase">aa</ToggleGroupItem>
                                </ToggleGroup>
                            </ItemActions>
                        </Item>
                    </ItemGroup>
                </ItemGrid>
                <ItemGrid>
                    <Item variant="muted" className={modifier.highlight ? "" : "col-span-2"}>
                        <ItemContent>
                            <ItemTitle>{t("Text Color", "文字颜色")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <ColorInput value={text.color} onChange={(color) => setTextStyle({ color })} />
                        </ItemActions>
                    </Item>
                    {
                        modifier.highlight &&
                        <Item variant="muted">
                            <ItemContent>
                                <ItemTitle>{t("Modifier Color", "修饰键颜色")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <ColorInput value={modifier.textColor} onChange={(textColor) => setModifierStyle({ textColor })} />
                            </ItemActions>
                        </Item>
                    }
                </ItemGrid>
            </CollapsibleContent>
        </Collapsible>

        <Collapsible>
            <CollapsibleTrigger>
                <h2 className="text-sm text-muted-foreground font-medium">{t("Layout", "布局")}</h2>
            </CollapsibleTrigger>
            <CollapsibleContent className="flex flex-col gap-y-4 pt-4">
                <ItemGrid>
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Icon", "图标")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <Switch
                                checked={layout.showIcon}
                                onCheckedChange={(showIcon) => setLayoutStyle({ showIcon })}
                                disabled={text.variant === "icon"}
                            />
                        </ItemActions>
                    </Item>
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Alignment", "对齐")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <ToggleGroup
                                type="single"
                                value={layout.iconAlignment}
                                onValueChange={(value) => setLayoutStyle({ iconAlignment: value as KeyStyleState["layout"]["iconAlignment"] })}
                                variant="outline"
                                className="w-28"
                                disabled={!layout.showIcon}
                            >
                                <ToggleGroupItem className="w-1/3" value="flex-start">
                                    <HugeiconsIcon icon={AlignLeftIcon} />
                                </ToggleGroupItem>
                                <ToggleGroupItem className="w-1/3" value="center">
                                    <HugeiconsIcon icon={AlignHorizontalCenterIcon} />
                                </ToggleGroupItem>
                                <ToggleGroupItem className="w-1/3" value="flex-end">
                                    <HugeiconsIcon icon={AlignRightIcon} />
                                </ToggleGroupItem>
                            </ToggleGroup>
                        </ItemActions>
                    </Item>
                </ItemGrid>
                <Item variant="muted">
                    <ItemContent>
                        <ItemTitle>{t("Symbol", "符号")}</ItemTitle>
                        <ItemDescription>{t("Display symbol characters like !, @, #, etc.", "显示 !、@、# 等符号字符。")}</ItemDescription>
                    </ItemContent>
                    <ItemActions>
                        <Switch
                            checked={layout.showSymbol}
                            onCheckedChange={(showSymbol) => setLayoutStyle({ showSymbol })}
                        />
                    </ItemActions>
                </Item>
                {
                    appearance.style !== "minimal" &&
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Press Count", "按下次数")}</ItemTitle>
                            <ItemDescription>{t("Display the number of times a key has been pressed.", "显示按键被按下的次数。")}</ItemDescription>
                        </ItemContent>
                        <ItemActions>
                            <Switch
                                checked={layout.showPressCount}
                                onCheckedChange={(showPressCount) => setLayoutStyle({ showPressCount })}
                            />
                        </ItemActions>
                    </Item>
                }
            </CollapsibleContent>
        </Collapsible>

        {
            appearance.style !== "minimal" &&
            <Collapsible>
                <CollapsibleTrigger>
                    <h2 className="text-sm text-muted-foreground font-medium">{t("Color", "颜色")}</h2>
                </CollapsibleTrigger>
                <CollapsibleContent className="flex flex-col gap-y-4 pt-4">
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Highlight Modifier", "高亮修饰键")}</ItemTitle>
                            <ItemDescription>{t("Use different color for modifier keys", "为修饰键使用不同颜色")}</ItemDescription>
                        </ItemContent>
                        <ItemActions>
                            <Switch checked={modifier.highlight} onCheckedChange={(highlight) => setModifierStyle({ highlight })} />
                        </ItemActions>
                    </Item>
                    {
                        appearance.style !== "lowprofile" &&
                        <Item variant="muted">
                            <ItemContent>
                                <ItemTitle>{t("Gradient", "渐变")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <Switch
                                    checked={color.useGradient}
                                    onCheckedChange={(useGradient) => setColorStyle({ useGradient })}
                                />
                            </ItemActions>
                        </Item>
                    }
                    {
                        (appearance.style === "laptop") ?
                            <ItemGrid>
                                <Item variant="muted" className={modifier.highlight ? "" : "col-span-2"}>
                                    <ItemContent>
                                        <ItemTitle>{t("Normal", "普通键")}</ItemTitle>
                                    </ItemContent>
                                    <ItemActions>
                                        <ColorInput value={color.color} onChange={(color) => setColorStyle({ color })} />
                                    </ItemActions>
                                </Item>
                                {
                                    modifier.highlight &&
                                    <Item variant="muted">
                                        <ItemContent>
                                                <ItemTitle>{t("Modifier", "修饰键")}</ItemTitle>
                                        </ItemContent>
                                        <ItemActions>
                                            <ColorInput value={modifier.color} onChange={(color) => setModifierStyle({ color })} />
                                        </ItemActions>
                                    </Item>
                                }
                            </ItemGrid> :
                            <>
                                {modifier.highlight && <h1>{t("Normal Color", "普通键颜色")}</h1>}
                                <ItemGrid>
                                    <Item variant="muted">
                                        <ItemContent>
                                            <ItemTitle>{t("Primary", "主色")}</ItemTitle>
                                        </ItemContent>
                                        <ItemActions>
                                            <ColorInput
                                                value={color.color}
                                                onChange={(color) => setColorStyle({ color })}
                                            />
                                        </ItemActions>
                                    </Item>
                                    <Item variant="muted">
                                        <ItemContent>
                                            <ItemTitle>{t("Secondary", "辅色")}</ItemTitle>
                                        </ItemContent>
                                        <ItemActions>
                                            <ColorInput
                                                value={color.secondaryColor}
                                                onChange={(secondaryColor) => setColorStyle({ secondaryColor })}
                                            />
                                        </ItemActions>
                                    </Item>
                                </ItemGrid>
                                {
                                    modifier.highlight && <>
                                        <h1>{t("Modifier Color", "修饰键颜色")}</h1>
                                        <ItemGrid>
                                            <Item variant="muted">
                                                <ItemContent>
                                                    <ItemTitle>{t("Primary", "主色")}</ItemTitle>
                                                </ItemContent>
                                                <ItemActions>
                                                    <ColorInput
                                                        value={modifier.color}
                                                        onChange={(color) => setModifierStyle({ color })}
                                                    />
                                                </ItemActions>
                                            </Item>
                                            <Item variant="muted">
                                                <ItemContent>
                                                    <ItemTitle>{t("Secondary", "辅色")}</ItemTitle>
                                                </ItemContent>
                                                <ItemActions>
                                                    <ColorInput
                                                        value={modifier.secondaryColor}
                                                        onChange={(secondaryColor) => setModifierStyle({ secondaryColor })}
                                                    />
                                                </ItemActions>
                                            </Item>
                                        </ItemGrid>
                                    </>
                                }
                            </>
                    }
                </CollapsibleContent>
            </Collapsible>
        }

        <Collapsible>
            <CollapsibleTrigger>
                <h2 className="text-sm text-muted-foreground font-medium">{t("Border", "边框")}</h2>
            </CollapsibleTrigger>
            <CollapsibleContent className="flex flex-col gap-y-4 pt-4">
                <ItemGrid>
                    <Item variant="muted">
                        <ItemContent className="min-h-6 h-full justify-center">
                            <ItemTitle>{t("Enable", "启用")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <Switch id="borderEnabled" checked={border.enabled} onCheckedChange={(enabled) => setBorderStyle({ enabled })} />
                        </ItemActions>
                    </Item>
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Width", "宽度")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <NumberInput
                                minValue={0.5}
                                step={0.5}
                                value={border.width}
                                onChange={(width) => setBorderStyle({ width })}
                                className="max-w-20 h-8"
                                isDisabled={!border.enabled}
                            />
                        </ItemActions>
                    </Item>
                    <Item variant="muted" className={modifier.highlight ? "" : "col-span-2"}>
                        <ItemContent>
                            <ItemTitle>{t("Color", "颜色")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <ColorInput
                                value={border.color}
                                onChange={(color) => setBorderStyle({ color })}
                                disabled={!border.enabled}
                            />
                        </ItemActions>
                    </Item>
                    {
                        modifier.highlight && <Item variant="muted">
                            <ItemContent>
                                <ItemTitle>{t("Modifier Color", "修饰键颜色")}</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <ColorInput
                                    value={modifier.borderColor}
                                    onChange={(color) => setModifierStyle({ borderColor: color })}
                                    disabled={!border.enabled}
                                />
                            </ItemActions>
                        </Item>
                    }
                </ItemGrid>
                <Item variant="muted">
                    <ItemContent>
                        <ItemTitle>{t("Radius", "圆角")}</ItemTitle>
                    </ItemContent>
                    <ItemActions>
                        <div className="w-4 h-4 border-l-2 border-t-2 border-primary/50" style={{ borderTopLeftRadius: `${border.radius * 100}%` }} />
                        <Slider
                            min={0}
                            max={1}
                            step={0.01}
                            value={[border.radius]}
                            onValueChange={(value) => setBorderStyle({ radius: value[0] })}
                            className="w-40 h-8 mx-2"
                        />
                        <Label htmlFor="borderRadius" className="w-[4ch] font-mono text-right">{(border.radius * 100).toFixed(0)}%</Label>
                    </ItemActions>
                </Item>
            </CollapsibleContent>
        </Collapsible>

        <Collapsible>
            <CollapsibleTrigger>
                <h2 className="text-sm text-muted-foreground font-medium">{t("Background", "背景")}</h2>
            </CollapsibleTrigger>
            <CollapsibleContent className="flex flex-col gap-y-4 pt-4">
                <ItemGrid>
                    <Item variant="muted">
                        <ItemContent className="min-h-6 h-full justify-center">
                            <ItemTitle>{t("Enable", "启用")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <Switch checked={background.enabled} onCheckedChange={(enabled) => setBackgroundStyle({ enabled })} />
                        </ItemActions>
                    </Item>
                    <Item variant="muted">
                        <ItemContent>
                            <ItemTitle>{t("Color", "颜色")}</ItemTitle>
                        </ItemContent>
                        <ItemActions>
                            <ColorInput value={background.color} onChange={(color) => setBackgroundStyle({ color })} disabled={!background.enabled} />
                        </ItemActions>
                    </Item>
                </ItemGrid>
            </CollapsibleContent>
        </Collapsible>
    </div>;
}
