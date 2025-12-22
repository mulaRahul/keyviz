import { create } from "zustand";
import { EventPayload, KeyEvent, MouseButton, MouseButtonEvent, MouseMoveEvent, MouseWheelEvent } from "../types/event";
import { Key } from "../types/key";


export interface KeyEventStore {
    // ───────────── physical state ─────────────
    pressedKeys: Set<string>;
    pressedMouseButton: MouseButton | null;
    mouse: { x: number; y: number; wheel: number };
    // ───────────── visual state ─────────────
    groups: Key[][];
    // ───────────── config ─────────────
    lingerDurationMs: number;
    showEventHistory: boolean;
    // ───────────── actions ─────────────
    onEvent(event: EventPayload): void;
    onKeyPress(event: KeyEvent): void;
    onKeyRelease(event: KeyEvent): void;
    onMouseMove(event: MouseMoveEvent): void;
    onMouseButtonPress(event: MouseButtonEvent): void;
    onMouseButtonRelease(event: MouseButtonEvent): void;
    onMouseWheel(event: MouseWheelEvent): void;
    tick(): void;
}


export const useKeyEvent = create<KeyEventStore>((set, get) => ({
    pressedKeys: new Set<string>(),
    pressedMouseButton: null,
    mouse: { x: 0, y: 0, wheel: 0 },
    groups: [],
    lingerDurationMs: 3000,
    showEventHistory: false,
    onEvent(event: EventPayload) {
        const state = get();
        switch (event.type) {
            case "KeyEvent":
                if (event.pressed) {
                    state.onKeyPress(event);
                } else {
                    state.onKeyRelease(event);
                }
                break;

            case "MouseMoveEvent":
                state.onMouseMove(event);
                break;

            case "MouseButtonEvent":
                if (event.pressed) {
                    state.onMouseButtonPress(event);
                } else {
                    state.onMouseButtonRelease(event);
                }
                break;

            case "MouseWheelEvent":
                state.onMouseWheel(event);
                break;
        }
    },
    onKeyPress(event: KeyEvent) {
        const state = get();

        // 0. track pyhsical state
        if (state.pressedKeys.has(event.name)) {
            return;
        }
        state.pressedKeys.add(event.name);

        // 1. filter event
        if (event.name === "Unknown") {
            return;
        }

        const key = new Key(event.name);
        const groupIndex = state.groups.length - 1;

        // 2. check if pressed again
        const existingKey = groupIndex >= 0 ? state.groups[groupIndex].find(k => k.name === key.name) : undefined;
        if (existingKey !== undefined) {
            // increment pressed count and update timestamp
            existingKey.pressedCount += 1;
            existingKey.lastPressedAt = key.lastPressedAt;
            // replace mode
            if (!state.showEventHistory) {
                // replace group with only this key
                state.groups[groupIndex] = [key];
            }
            // history mode, last group has only this key
            else if (state.groups[groupIndex].length === 1) {
                state.groups[groupIndex].push(existingKey);
            }
        }
        // 3. add to group
        else {
            // check if need to create new group
            if (state.pressedKeys.size === 1 || groupIndex < 0) {
                if (state.showEventHistory) {
                    state.groups.push([key]);
                } else {
                    state.groups = [[key]];
                }
            } else {
                state.groups[groupIndex].push(key);
            }
        }

        set({ pressedKeys: state.pressedKeys, groups: state.groups });
        // Old logic:
        // 1. hotkey filter
        // 2. filter unknown
        // 3. key pressed again
        // └─| show history
        //   ├─ yes - update key, remove all but this, return
        //   └─ no - update key, if last group has only this, return
        // 4. find group index
        // 5. show history
        // ├─ yes - ensure max history
        // └─ no - remove all if this is only in pressed
        // 6. add key to group
    },
    onKeyRelease(event: KeyEvent) {
        const state = get();

        // track physical state
        state.pressedKeys.delete(event.name);

        // find key in last group
        const groupIndex = state.groups.length - 1;
        const key = groupIndex >= 0 ? state.groups[groupIndex].find(k => k.name === event.name) : undefined;

        // if (key !== undefined) {
        //     key.lastPressedAt = Date.now();
        //     state.groups[groupIndex].push(key);
        // }

        set({ pressedKeys: state.pressedKeys, groups: state.groups });
    },
    onMouseMove(event: MouseMoveEvent) {
        const state = get();
        state.mouse.x = event.x;
        state.mouse.y = event.y;
        set({ mouse: state.mouse });
    },
    onMouseButtonPress(event: MouseButtonEvent) {
        const state = get();
        state.onKeyPress({ name: event.button.toString(), pressed: false } as KeyEvent);
        set({ pressedMouseButton: event.button });
    },
    onMouseButtonRelease(event: MouseButtonEvent) {
        const state = get();
        state.onKeyRelease({ name: event.button.toString(), pressed: false } as KeyEvent);
        set({ pressedMouseButton: null });
    },
    onMouseWheel(event: MouseWheelEvent) {
        const state = get();
        state.mouse.wheel = event.delta_y;

        set({ mouse: state.mouse });
    },
    tick() {
        const state = get();
        const now = Date.now();
        let notify = false;

        const groups = <Key[][]>[];

        for (const group of state.groups) {
            const g = group.filter((key) => {
                return (
                    // is pressed
                    state.pressedKeys.has(key.name) ||
                    // within linger duration 
                    now - key.lastPressedAt < state.lingerDurationMs
                );
            })
            if (g.length !== group.length) {
                notify = true;
            }
            if (g.length > 0) {
                groups.push(g);
            }
        }

        if (notify) {
            set({ groups });
        }
    }
}));

export const useKeyGroups = () => useKeyEvent((state) => state.groups);
