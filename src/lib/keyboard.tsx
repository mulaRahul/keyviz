import { useMemo } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { appDataDir, join } from "@tauri-apps/api/path";
import { BaseDirectory, exists, mkdir, readDir, readTextFile, writeTextFile } from "@tauri-apps/plugin-fs";
import { openPath } from "@tauri-apps/plugin-opener";
import { useKeyStyle } from "@/stores/key_style";
import { keymaps, type DisplayData, type KeyIcon } from "./keymaps";

// ───────────── Keyboard files ─────────────
// A keyboard is one SVG file. Every element whose id (or data-key) is a key
// name (ControlLeft, Escape, KeyA…) replaces that key's icon. Optional attributes:
//   (sheet) dashed frame    a rect just before a caption text naming the key:
//                           displayed area, the drawing keeps its transform
//   data-viewbox="x y w h"  without frame: drawing area in the element's own coordinates
//                           (otherwise the bounding box of its content)
//   data-label / data-short-label  replace the key's text
//   data-icon-only="true"   show the drawing alone, never with the text

const SVG_NS = "http://www.w3.org/2000/svg";
const KEYBOARD_DIR = "keyboards";
const baseDir = BaseDirectory.AppData;

export const BUILTIN_ICONS = "";
export const BUILTIN_GLYPHS = "builtin:glyphs";

export interface KeyDisplay extends DisplayData {
    // the key comes from the keyboard file
    custom?: boolean;
    iconOnly?: boolean;
}

interface KeyDrawing {
    icon: KeyIcon;
    label?: string;
    shortLabel?: string;
    iconOnly: boolean;
}

// ───────────── Parsing ─────────────
// attributes that position or identify the element, not drawn by the copy
const SKIPPED_ATTRIBUTES = /^(id|transform|viewBox|data-.*|x|y|width|height)$/;

let cached: { svg: string; drawings: Map<string, KeyDrawing> } | undefined;

function parseViewBox(value: string | null): [number, number, number, number] | undefined {
    const parts = value?.trim().split(/[\s,]+/).map(Number);
    if (!parts || parts.length !== 4 || parts.some(Number.isNaN) || parts[2] <= 0 || parts[3] <= 0) return undefined;
    return parts as [number, number, number, number];
}

function createDrawingIcon(viewBox: [number, number, number, number], markup: string): KeyIcon {
    const ratio = viewBox[2] / viewBox[3];
    return ({ color, size = 24 }) => (
        <svg
            xmlns={SVG_NS}
            viewBox={viewBox.join(" ")}
            height={size}
            width={typeof size === "number" ? size * ratio : size}
            style={{ color, overflow: "visible", flexShrink: 0 }}
            dangerouslySetInnerHTML={{ __html: markup }}
        />
    );
}

// ───────────── Colors ─────────────
// Black paints become currentColor, so they follow the keycap text color.
// The root `color` counts too: Inkscape writes it in place of currentColor.
const BLACK = /^(#000|#000000|black|rgb\(\s*0\s*,\s*0\s*,\s*0\s*\))$/i;
const PAINT_PROPERTIES = ["fill", "stroke", "color", "stop-color", "flood-color"];

function followTextColor(doc: Document) {
    const root = doc.documentElement;
    const rootColor = (root.style?.color || root.getAttribute("color") || "").trim().toLowerCase();
    const isText = (value: string) => {
        const color = value.trim().toLowerCase();
        return BLACK.test(color) || (rootColor !== "" && color === rootColor);
    };

    doc.querySelectorAll("*").forEach((element) => {
        if (element === root) return;
        for (const property of PAINT_PROPERTIES) {
            const value = element.getAttribute(property);
            if (value && isText(value)) element.setAttribute(property, "currentColor");
        }
        const style = element.getAttribute("style");
        if (style) {
            element.setAttribute("style", style.split(";").map((declaration) => {
                const [name, ...rest] = declaration.split(":");
                return PAINT_PROPERTIES.includes(name.trim().toLowerCase()) && isText(rest.join(":"))
                    ? `${name}:currentColor`
                    : declaration;
            }).join(";"));
        }
    });
}

// ───────────── Frames ─────────────
// On a sheet, each key has a dashed frame (rect) followed by its caption (text = key name).
// The frame is the displayed area: scaling or moving the drawing inside it shows in Keyviz.
function findFrames(doc: Document): Map<string, Element> {
    const frames = new Map<string, Element>();
    doc.querySelectorAll("text").forEach((caption) => {
        const key = caption.textContent?.trim() ?? "";
        const frame = caption.previousElementSibling;
        if (keymaps[key] && frame?.localName === "rect" && !frames.has(key)) frames.set(key, frame);
    });
    return frames;
}

// wrap markup in the transforms of the element's ancestors (Inkscape layers…)
function inSheetSpace(element: Element, markup: string): string {
    const root = element.ownerDocument.documentElement;
    for (let parent = element.parentElement; parent && parent !== root; parent = parent.parentElement) {
        const transform = parent.getAttribute("transform");
        if (transform) markup = `<g transform="${escapeXml(transform)}">${markup}</g>`;
    }
    return markup;
}

function parseKeyboard(svg: string): Map<string, KeyDrawing> {
    if (cached?.svg === svg) return cached.drawings;
    const drawings = new Map<string, KeyDrawing>();
    cached = { svg, drawings };
    if (!svg.trim()) return drawings;

    const doc = new DOMParser().parseFromString(svg, "image/svg+xml");
    if (doc.querySelector("parsererror")) {
        console.error("Invalid keyboard SVG");
        return drawings;
    }
    followTextColor(doc);
    const defs = Array.from(doc.querySelectorAll("defs"), (d) => d.outerHTML).join("");

    // getBBox only works on rendered elements: measure in a hidden host
    const host = document.createElementNS(SVG_NS, "svg");
    host.setAttribute("style", "position:absolute;left:-10000px;top:-10000px;visibility:hidden");
    host.innerHTML = defs;
    document.body.appendChild(host);
    const measure = (markup: string) => {
        const group = document.createElementNS(SVG_NS, "g");
        group.innerHTML = markup;
        host.appendChild(group);
        const box = group.getBBox();
        group.remove();
        return box;
    };
    try {
        const frames = findFrames(doc);
        doc.querySelectorAll("[id], [data-key]").forEach((element) => {
            const key = element.getAttribute("data-key") ?? element.id;
            if (!keymaps[key] || drawings.has(key)) return;
            // with a frame, the drawing stays where it is on the sheet: keep its transform
            const frame = frames.get(key);

            let markup: string;
            if (["g", "symbol", "svg", "a"].includes(element.localName)) {
                // container: keep its styling (fill, stroke…) on a plain wrapper
                const attributes = Array.from(element.attributes)
                    .filter((attr) => (frame && attr.name === "transform")
                        || (!SKIPPED_ATTRIBUTES.test(attr.name) && !attr.name.includes(":")))
                    .map((attr) => ` ${attr.name}="${escapeXml(attr.value)}"`)
                    .join("");
                markup = `<g${attributes}>${element.innerHTML}</g>`;
            } else {
                // single shape: drawn as is
                const shape = element.cloneNode(true) as Element;
                shape.removeAttribute("id");
                markup = shape.outerHTML;
            }

            let viewBox: [number, number, number, number] | undefined;
            if (frame) {
                markup = inSheetSpace(element, markup);
                const box = measure(inSheetSpace(frame, frame.outerHTML));
                if (box.width > 0 && box.height > 0) viewBox = [box.x, box.y, box.width, box.height];
            }
            viewBox ??= parseViewBox(element.getAttribute("data-viewbox"))
                ?? (element.localName === "symbol" ? parseViewBox(element.getAttribute("viewBox")) : undefined);
            if (!viewBox) {
                const box = measure(markup);
                if (box.width <= 0 && box.height <= 0) return;
                // bounding box ignores stroke width: leave some room
                const pad = Math.max(box.width, box.height) * 0.08;
                viewBox = [box.x - pad, box.y - pad, box.width + pad * 2, box.height + pad * 2];
            }

            drawings.set(key, {
                icon: createDrawingIcon(viewBox, defs + markup),
                label: element.getAttribute("data-label") ?? undefined,
                shortLabel: element.getAttribute("data-short-label") ?? undefined,
                iconOnly: element.getAttribute("data-icon-only") === "true",
            });
        });
    } finally {
        host.remove();
    }
    return drawings;
}

export function resolveKeyDisplay(name: string, svg: string): KeyDisplay {
    const base: KeyDisplay = keymaps[name] ?? { label: name };
    const drawing = parseKeyboard(svg).get(name);
    if (!drawing) return base;
    return {
        ...base,
        label: drawing.label ?? base.label,
        // a new full label without short one must not show the old short text
        shortLabel: drawing.shortLabel ?? (drawing.label ? undefined : base.shortLabel),
        icon: drawing.icon,
        custom: true,
        iconOnly: drawing.iconOnly,
    };
}

// display data of a key, with the selected keyboard applied
export function useKeyDisplay(name: string): KeyDisplay {
    const svg = useKeyStyle((state) => state.keyboard?.svg ?? "");
    return useMemo(() => resolveKeyDisplay(name, svg), [name, svg]);
}

// ───────────── Templates ─────────────
// editable sheet of every key, laid out on a grid with a caption under each cell

const CELL = 24;
const PITCH = 48;
const COLUMNS = 8;

function escapeXml(text: string): string {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function iconContent(Icon: KeyIcon): string | undefined {
    const markup = renderToStaticMarkup(<Icon />);
    const root = new DOMParser().parseFromString(markup, "image/svg+xml").documentElement;
    if (root.localName !== "svg") return undefined;
    const attributes = Array.from(root.attributes)
        .filter((attr) => ["fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin"].includes(attr.name))
        .map((attr) => ` ${attr.name}="${escapeXml(attr.value)}"`)
        .join("");
    return `${attributes}>${root.innerHTML}`;
}

function glyphContent(glyph: string): string {
    return ` fill="currentColor"><text x="12" y="12" font-size="18" font-family="Segoe UI Symbol, sans-serif" text-anchor="middle" dominant-baseline="central">${escapeXml(glyph)}</text>`;
}

export function buildKeyboardTemplate(kind: "icons" | "glyphs"): string {
    const cells: string[] = [];
    for (const [key, display] of Object.entries(keymaps)) {
        const content = kind === "icons"
            ? display.icon && iconContent(display.icon)
            : display.glyph && glyphContent(display.glyph);
        if (!content) continue;

        const x = (cells.length % COLUMNS) * PITCH + (PITCH - CELL) / 2;
        const y = Math.floor(cells.length / COLUMNS) * PITCH + 6;
        cells.push(
            `  <rect x="${x}" y="${y}" width="${CELL}" height="${CELL}" fill="none" stroke="#bbb" stroke-width="0.3" stroke-dasharray="1 1"/>\n` +
            `  <text x="${x + CELL / 2}" y="${y + CELL + 6}" font-size="4" font-family="sans-serif" fill="#888" text-anchor="middle">${key}</text>\n` +
            `  <g id="${key}" data-viewbox="0 0 ${CELL} ${CELL}" transform="translate(${x} ${y})"${content}</g>`
        );
    }
    const width = COLUMNS * PITCH;
    const height = Math.ceil(cells.length / COLUMNS) * PITCH;
    return `<?xml version="1.0" encoding="UTF-8"?>
<!--
  Clavier Keyviz. Un groupe par touche : id = nom de la touche (ControlLeft, Escape, KeyA…).
  Le cadre pointillé est la zone affichée : agrandir, déplacer ou tourner le dessin dans son cadre se voit dans Keyviz.
  Garder chaque cadre juste avant sa légende. Sans cadre : data-viewbox (en coordonnées du groupe), sinon le contour du dessin.
  Le noir (et currentColor) prend la couleur du texte des touches ; les autres couleurs restent telles quelles.
  Attributs facultatifs : data-label, data-short-label (texte), data-icon-only="true" (dessin seul).
  Une touche absente garde son icône intégrée ; un groupe supprimé rend l'icône d'origine.
  Noms de touches possibles : ${Object.keys(keymaps).join(", ")}
-->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width * 3}" height="${height * 3}" color="#000000" style="color:#000000">
${cells.join("\n")}
</svg>
`;
}

// ───────────── Files ─────────────

export async function listUserKeyboards(): Promise<string[]> {
    if (!(await exists(KEYBOARD_DIR, { baseDir }))) return [];
    const entries = await readDir(KEYBOARD_DIR, { baseDir });
    return entries
        .filter((entry) => entry.isFile && entry.name.toLowerCase().endsWith(".svg"))
        .map((entry) => entry.name)
        .sort((a, b) => a.localeCompare(b));
}

export async function loadKeyboardSvg(name: string): Promise<string> {
    if (name === BUILTIN_ICONS) return "";
    if (name === BUILTIN_GLYPHS) return buildKeyboardTemplate("glyphs");
    return readTextFile(`${KEYBOARD_DIR}/${name}`, { baseDir });
}

// copy a keyboard into the user folder, returns the new file name
export async function duplicateKeyboard(name: string): Promise<string> {
    const source = name === BUILTIN_ICONS ? buildKeyboardTemplate("icons") : await loadKeyboardSvg(name);
    const stem = name === BUILTIN_ICONS ? "icons"
        : name === BUILTIN_GLYPHS ? "glyphs"
        : name.replace(/\.svg$/i, "");
    await mkdir(KEYBOARD_DIR, { baseDir, recursive: true });
    let fileName = `${stem} copy.svg`;
    for (let i = 2; await exists(`${KEYBOARD_DIR}/${fileName}`, { baseDir }); i++) {
        fileName = `${stem} copy ${i}.svg`;
    }
    await writeTextFile(`${KEYBOARD_DIR}/${fileName}`, source, { baseDir });
    return fileName;
}

export async function openKeyboardFolder(): Promise<void> {
    await mkdir(KEYBOARD_DIR, { baseDir, recursive: true });
    await openPath(await join(await appDataDir(), KEYBOARD_DIR));
}
