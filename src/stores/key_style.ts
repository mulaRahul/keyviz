import { Alignment } from "@/types/style";
import { create } from "zustand";

export interface AppearanceSettings {
    flexDirection: "row" | "column";
    alignment: Alignment;
    marginX: number;
    marginY: number;
    animation: "none" | "fade" | "zoom" | "slide";
    animationDuration: number;
    motionBlur: boolean;
}

export interface KeycapSettings {
    type: "minimal" | "flat" | "elevated" | "plastic" | "mechanical";
    useGradient: boolean;
    color: string;
    secondaryColor: string;
    showIcon: boolean;
    alignment: Alignment;
}

export interface ModifierSettings {
    highlight: boolean;
    color: string;
    secondaryColor: string;
    textColor: string;
    textVariant: "icon" | "text" | "text-short";
    borderColor: string;
}

export interface TextSettings {
    size: number;
    color: string;
    caps: "uppercase" | "title" | "lowercase";
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
    keepHighlight: boolean;
    filled: boolean;
    color: string;
    animation: "ripple" | "flash" | "static";
}

export interface KeyStyleStore {
    appearance: AppearanceSettings;
    keycap: KeycapSettings;
    modifier: ModifierSettings;
    text: TextSettings;
    border: BorderSettings;
    background: BackgroundSettings;
    mouse: MouseSettings;
    // ───────────── setters ─────────────
    setAppearance: (appearance: Partial<AppearanceSettings>) => void;
    setKeycap: (keycap: Partial<KeycapSettings>) => void;
    setModifier: (modifier: Partial<ModifierSettings>) => void;
    setText: (text: Partial<TextSettings>) => void;
    setBorder: (border: Partial<BorderSettings>) => void;
    setBackground: (background: Partial<BackgroundSettings>) => void;
    setMouse: (mouse: Partial<MouseSettings>) => void;
}

export const useKeyStyle = create<KeyStyleStore>((set) => ({
    appearance: {
        flexDirection: "column",
        alignment: "bottom-center",
        marginX: 5,
        marginY: 5,
        animation: "fade",
        motionBlur: true,
        animationDuration: 300,
    },
    keycap: {
        type: "elevated",
        useGradient: true,
        color: "#ffffffff",
        secondaryColor: "#ccccccff",
        showIcon: true,
        alignment: "bottom-center",
    },
    modifier: {
        highlight: true,
        color: "#ff0000ff",
        secondaryColor: "#cc0000ff",
        textColor: "#ffffffff",
        textVariant: "text-short",
        borderColor: "#990000ff",
    },
    text: {
        size: 18,
        color: "#000000ff",
        caps: "title",
    },
    border: {
        enabled: true,
        color: "#000000ff",
        width: 1,
        radius: 0.4,
    },
    background: {
        enabled: true,
        color: "#ffffff80",
    },
    mouse: {
        showClicks: true,
        keepHighlight: false,
        showEvents: true,
        filled: false,
        color: "#0000ffff",
        animation: "ripple",
    },
    // ───────────── setters ─────────────
    setAppearance: (appearance) => set((state) => ({ appearance: { ...state.appearance, ...appearance } })),
    setKeycap: (keycap) => set((state) => ({ keycap: { ...state.keycap, ...keycap } })),
    setModifier: (modifier) => set((state) => ({ modifier: { ...state.modifier, ...modifier } })),
    setText: (text) => set((state) => ({ text: { ...state.text, ...text } })),
    setBorder: (border) => set((state) => ({ border: { ...state.border, ...border } })),
    setBackground: (background) => set((state) => ({ background: { ...state.background, ...background } })),
    setMouse: (mouse) => set((state) => ({ mouse: { ...state.mouse, ...mouse } })),
}));