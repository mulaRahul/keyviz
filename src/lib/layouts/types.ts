import type { DisplayData } from "@/lib/keymaps";

export interface KeyboardLayoutDef {
    /** Unique identifier, e.g. "us", "es", "fr" */
    id: string;
    /** Human-readable name for the settings dropdown */
    name: string;
    /** Key-by-key overrides; only keys that differ from the base keymap */
    overrides: Record<string, Partial<DisplayData>>;
}
