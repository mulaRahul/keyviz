import { isTauri } from "@tauri-apps/api/core";
import { getCurrentWindow } from "@tauri-apps/api/window";

/**
 * True inside the Tauri app, false when the same bundle runs in a normal
 * browser (the OBS browser source page).
 */
export const inTauri = isTauri();

/**
 * Label of the current Tauri window, or `"viewer"` outside Tauri so the
 * stores can be imported by the browser source page without touching the
 * window API.
 */
export function windowLabel(): string {
    return inTauri ? getCurrentWindow().label : "viewer";
}
