import type { KeyboardLayoutDef } from "./types";

const modules = import.meta.glob<{ default: KeyboardLayoutDef }>("./*.ts", {
    eager: true,
});

export const layouts: KeyboardLayoutDef[] = Object.values(modules)
    .map((m) => m.default)
    .filter((def): def is KeyboardLayoutDef => !!def);

export const layoutMap: Record<string, KeyboardLayoutDef> = Object.fromEntries(
    layouts.map((l) => [l.id, l]),
);

export const layoutIds: string[] = layouts.map((l) => l.id);

export type KeyboardLayout = string;
