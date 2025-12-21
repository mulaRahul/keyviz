import { create } from "zustand";
import { EventPayload, KeyEvent, MouseButton, MouseButtonEvent, MouseMoveEvent, MouseWheelEvent } from "../types/event";
import { KeyGroup } from "../types/key";


export interface KeyEventStore {
    // ───────────── physical state ─────────────
    pressedKeys: Set<string>;
    pressedMouseButton: MouseButton | null;
    mouse: { x: number; y: number; wheel: number };
    // ───────────── visual state ─────────────
    groups: Map<string, KeyGroup>;
    // ───────────── config ─────────────
    // ───────────── actions ─────────────
    onEvent(event: EventPayload): void;
    onKeyPress(event: KeyEvent): void;
    onKeyRelease(event: KeyEvent): void;
    onMouseMove(event: MouseMoveEvent): void;
    onMouseButtonPress(event: MouseButtonEvent): void;
    onMouseButtonRelease(event: MouseButtonEvent): void;
    onMouseWheel(event: MouseWheelEvent): void;
}


export const useKeyEvent = create<KeyEventStore>((set, get) => ({
    pressedKeys: new Set<string>(),
    pressedMouseButton: null,
    mouse: { x: 0, y: 0, wheel: 0 },
    groups: new Map<string, KeyGroup>(),
    onEvent(e: EventPayload) {
        const state = get();
        switch (e.type) {

            case "KeyEvent":
                if (e.pressed) {
                    state.pressedKeys.add(e.name);
                    state.onKeyPress(e);
                } else {
                    state.pressedKeys.delete(e.name);
                    state.onKeyRelease(e);
                }
                break;

            case "MouseMoveEvent":
                state.mouse.x = e.x;
                state.mouse.y = e.y;
                state.onMouseMove(e);
                break;

            case "MouseButtonEvent":
                if (e.pressed) {
                    state.pressedMouseButton = e.button;
                    state.onMouseButtonPress(e);
                } else {
                    state.pressedMouseButton = null;
                    state.onMouseButtonRelease(e);
                }
                break;

            case "MouseWheelEvent":
                state.mouse.wheel = e.delta_y;
                state.onMouseWheel(e);
                break;
        }
        set({ ...state });
    },
    onKeyPress(event: KeyEvent) {
    },
    onKeyRelease(event: KeyEvent) {
    },
    onMouseMove(event: MouseMoveEvent) {
    },
    onMouseButtonPress(event: MouseButtonEvent) {
    },
    onMouseButtonRelease(event: MouseButtonEvent) {
    },
    onMouseWheel(event: MouseWheelEvent) {
    },
}));

