import type { TFunction } from "i18next";
import { keymaps, type DisplayData } from "@/lib/keymaps";

export function displayLabel(display: DisplayData | undefined, rawKey: string, t: TFunction, short = false): string {
  const label = short ? display?.shortLabel ?? display?.label : display?.label;
  if (!label) return rawKey;
  return t(`keyNames.${label}`, { defaultValue: label });
}

export function translateKeyLabel(rawKey: string, t: TFunction, short = false): string {
  return displayLabel(keymaps[rawKey], rawKey, t, short);
}

// letters follow shift instead of the "text cap" setting
export function isCaseSensitive(display: DisplayData | undefined, matchCase: boolean | undefined): boolean {
  return matchCase !== false && display?.category === "letter";
}

export function applyCase(label: string, shifted: boolean): string {
  return shifted ? label.toUpperCase() : label.toLowerCase();
}
