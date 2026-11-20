import { Alignment } from "@/types/style";
import { createJSONStorage, persist } from "zustand/middleware";
import { tauriStorage } from "./storage";
import { createSyncedStore } from "./sync";
import { windowLabel } from "@/lib/env";
import { readTextFile, writeTextFile } from "@tauri-apps/plugin-fs";
import { open, save } from "@tauri-apps/plugin-dialog";
import { toast } from "sonner";
import i18next from 'i18next'

export const KEY_STYLE_STORE = "key_style_store";

/** Pseudo display that serves the keycaps over HTTP for OBS Browser Source. */
export const BROWSER_DISPLAY = "__browser__";

/** Port the browser source binds to by default (below the Windows dynamic range). */
export const DEFAULT_BROWSER_PORT = 17650;

export interface AppearanceSettings {
    /**
     * Displays that render the keycaps, by monitor name. `null` means the user
     * never changed it (main window on the primary display); an empty array
     * means the user cleared every display, so nothing is drawn.
     */
    monitors: string[] | null;
    /**
     * Displays that render mouse clicks and the indicator, by monitor name.
     * `null` means every display (the default), an empty array means none.
     */
    mouseMonitors: string[] | null;
    /**
     * Master switch for the keycaps. When off, nothing is drawn anywhere; the
     * `monitors` selection is kept so turning it back on restores the setup.
     */
    keycapsEnabled: boolean;
    /** Master switch for the mouse visuals, same contract as `keycapsEnabled`. */
    mouseEnabled: boolean;
    flexDirection: "row" | "column";
    alignment: Alignment;
    marginX: number;
    marginY: number;
    animation: "none" | "fade" | "zoom" | "float" | "slide";
    animationDuration: number;
    style: "minimal" | "laptop" | "lowprofile" | "pbt";
}

export interface LayoutSettings {
    showIcon: boolean;
    showSymbol: boolean;
    showPressCount: boolean;
    iconAlignment: "flex-start" | "center" | "flex-end";
}

export interface ColorSettings {
    color: string;
    secondaryColor: string;
    useGradient: boolean;
}

export interface ModifierSettings {
    highlight: boolean;
    color: string;
    secondaryColor: string;
    textColor: string;
    borderColor: string;
}

export interface TextSettings {
    size: number;
    color: string;
    caps: "uppercase" | "capitalize" | "lowercase";
    variant: "icon" | "text" | "text-short";
    alignment: Alignment;
}

export interface BorderSettings {
    enabled: boolean;
    color: string;
    width: number;
    radius: number;
}

export interface BackgroundSettings {
    enabled: boolean;
    color: string;
}

export interface MouseSettings {
    showClicks: boolean;
    size: number;
    color: string;
    keepHighlight: boolean;
    showIndicator: boolean;
    keepIndicator: boolean;
    indicatorSize: number;
    indicatorOffsetX: number;
    indicatorOffsetY: number;
}

export interface KeyStyleState {
    appearance: AppearanceSettings;
    layout: LayoutSettings;
    color: ColorSettings;
    modifier: ModifierSettings;
    text: TextSettings;
    border: BorderSettings;
    background: BackgroundSettings;
    mouse: MouseSettings;
    /** Port the OBS browser-source page listens on when that output is selected. */
    browserSourcePort: number;
}

interface KeyStyleActions {
    setAppearance: (appearance: Partial<AppearanceSettings>) => void;
    setLayout: (layout: Partial<LayoutSettings>) => void;
    setColor: (color: Partial<ColorSettings>) => void;
    setModifier: (modifier: Partial<ModifierSettings>) => void;
    setText: (text: Partial<TextSettings>) => void;
    setBorder: (border: Partial<BorderSettings>) => void;
    setBackground: (background: Partial<BackgroundSettings>) => void;
    setMouse: (mouse: Partial<MouseSettings>) => void;
    setBrowserSourcePort: (port: number) => void;
    import: () => Promise<void>;
    export: () => Promise<void>;
}

export type KeyStyleStore = KeyStyleState & KeyStyleActions;

const createKeyStyleStore = createSyncedStore<KeyStyleStore>(
    KEY_STYLE_STORE,
    (set, get) => ({
        appearance: {
            monitors: null,
            mouseMonitors: null,
            keycapsEnabled: true,
            mouseEnabled: true,
            flexDirection: "column",
            alignment: "bottom-center",
            marginX: 100,
            marginY: 100,
            animation: "fade",
            animationDuration: 0.25,
            style: "lowprofile",
        },
        layout: {
            showIcon: true,
            showSymbol: true,
            showPressCount: true,
            iconAlignment: "flex-end",
        },
        color: {
            color: "#ffffff",
            secondaryColor: "#1a1a1a",
            useGradient: true,
        },
        modifier: {
            highlight: false,
            color: "#3a86ff",
            secondaryColor: "#000000",
            textColor: "#000000",
            borderColor: "#000000",
        },
        text: {
            size: 32,
            color: "#000000",
            caps: "capitalize",
            variant: "text-short",
            alignment: "center",
        },
        border: {
            enabled: true,
            width: 2,
            color: "#1a1a1a",
            radius: 0.5,
        },
        background: {
            enabled: true,
            color: "#ffffff99",
        },
        mouse: {
            showClicks: false,
            size: 150,
            color: "#009dff",
            keepHighlight: false,
            showIndicator: true,
            keepIndicator: true,
            indicatorSize: 50,
            indicatorOffsetX: 50,
            indicatorOffsetY: 50,
        },
        browserSourcePort: DEFAULT_BROWSER_PORT,

        setAppearance: (appearance) => set((state) => ({ appearance: { ...state.appearance, ...appearance } })),
        setLayout: (layout) => set((state) => ({ layout: { ...state.layout, ...layout } })),
        setColor: (color) => set((state) => ({ color: { ...state.color, ...color } })),
        setModifier: (modifier) => set((state) => ({ modifier: { ...state.modifier, ...modifier } })),
        setText: (text) => set((state) => ({ text: { ...state.text, ...text } })),
        setBorder: (border) => set((state) => ({ border: { ...state.border, ...border } })),
        setBackground: (background) => set((state) => ({ background: { ...state.background, ...background } })),
        setMouse: (mouse) => set((state) => ({ mouse: { ...state.mouse, ...mouse } })),
        setBrowserSourcePort: (browserSourcePort) => set({ browserSourcePort }),

        import: async () => {
            try {
                const filePath = await open({
                    multiple: false,
                    filters: [{
                        name: i18next.t('jsonFiles', 'JSON Files'),
                        extensions: ['json']
                    }]
                });
                if (!filePath || typeof filePath !== 'string') return;

                const content = await readTextFile(filePath);
                const parsedData: KeyStyleState = JSON.parse(content);

                if (
                    !parsedData.appearance || !parsedData.layout || !parsedData.color ||
                    !parsedData.modifier || !parsedData.text || !parsedData.border ||
                    !parsedData.background || !parsedData.mouse
                ) {
                    toast.warning(i18next.t('invalidFileFormat', 'Invalid file format'), { description: filePath });
                    return;
                }
                set(() => ({
                    appearance: parsedData.appearance,
                    layout: parsedData.layout,
                    color: parsedData.color,
                    modifier: parsedData.modifier,
                    text: parsedData.text,
                    border: parsedData.border,
                    background: parsedData.background,
                    mouse: parsedData.mouse,
                }));
                toast.success("Imported successfully", { description: filePath });
            } catch (err) {
                toast.error(i18next.t('errorImportingFile', 'Error importing file'), {
                    description: err instanceof Error ? err.message : String(err),
                })
            }
        },
        export: async () => {
            const state = get();
            const exportData: KeyStyleState = {
                appearance: state.appearance,
                layout: state.layout,
                color: state.color,
                modifier: state.modifier,
                text: state.text,
                border: state.border,
                background: state.background,
                mouse: state.mouse,
                browserSourcePort: state.browserSourcePort,
            };
            try {
                const filePath = await save({
                    defaultPath: "key_style.json",
                    filters: [{ name: i18next.t('jsonFiles', 'JSON Files'), extensions: ["json"] }],
                });
                if (!filePath) return;
                await writeTextFile(filePath, JSON.stringify(exportData, null, 2));
                toast.success("Exported successfully", { description: filePath });
            } catch (err) {
                toast.error(i18next.t('errorExportingFile', 'Error exporting file'), {
                    description: err instanceof Error ? err.message : String(err),
                })
            }
        }
    }),
    (config) => persist(config, {
        name: KEY_STYLE_STORE,
        storage: createJSONStorage(() => tauriStorage),
        version: 2,
        // v1 stored a single `appearance.monitor` string. Both the keycaps and
        // the mouse effects followed it, so the same display fills both lists.
        // When it was never set, both stay `null` (= default behaviour).
        migrate: (persisted, version) => {
            const state = persisted as Partial<KeyStyleStore>;
            const appearance = state?.appearance as (Partial<AppearanceSettings> & { monitor?: string | null }) | undefined;

            if (version < 2 && appearance) {
                const monitor = appearance.monitor ?? null;

                if (monitor) {
                    appearance.monitors = appearance.monitors ?? [monitor];
                    appearance.mouseMonitors = appearance.mouseMonitors ?? [monitor];
                }
                delete appearance.monitor;
            }

            return state as KeyStyleStore;
        },
    }),
);

export const useKeyStyle = createKeyStyleStore(windowLabel() === "settings");