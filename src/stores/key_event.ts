import { create } from "zustand";
import { EventPayload, KeyEvent, MouseButton, MouseButtonEvent, MouseMoveEvent, MouseWheelEvent } from "../types/event";
import { Key } from "../types/key";
import { invoke } from "@tauri-apps/api/core";


function log(message: string) {
    invoke("log", { message });
}

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
    maxGroups: number;
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
    lingerDurationMs: 6_000,
    showEventHistory: true,
    maxGroups: 5,
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
        let groups = [...state.groups];
        let pressedKeys = new Set(state.pressedKeys);

        // 0. track pyhsical state
        if (pressedKeys.has(event.name)) {
            // ignore repeat events
            return;
        }
        pressedKeys.add(event.name);

        // 1. filter event
        if (event.name === "Unknown") {
            // update pressed keys only
            set({ pressedKeys });
            return;
        }

        const key = new Key(event.name);
        const last = groups.length - 1;

        // 2. check if pressed again
        const existingKey = last >= 0 ? groups[last].find(gKey => gKey.name === key.name) : undefined;
        if (existingKey) {
            // history mode, add new group
            if (state.showEventHistory && groups[last].length > 1) {
                const group = groups[last].filter(gKey => gKey.in(pressedKeys));
                groups.push(group); // todo: ensure max history
            }
            // replace mode, only currently pressed keys
            // or
            // history mode, last group has only this key
            else {
                let group = <Key[]>[];

                groups[last].forEach(gKey => {
                    if (gKey.name === key.name) {
                        existingKey.press();
                        group.push(existingKey);
                    } else if (gKey.in(pressedKeys)) {
                        group.push(gKey);
                    }
                });

                groups[last] = group;
            }
        }
        // 3. add to group
        else {
            // add new group
            if (pressedKeys.size === 1 || last < 0) {
                if (state.showEventHistory) {
                    groups.push([key]);
                } else {
                    groups = [[key]];
                }
            }
            // key combination
            else {
                if (state.showEventHistory && groups[last].some(gKey => !gKey.in(pressedKeys))) {
                    // history mode, partial combination, add new group
                    const group = groups[last].filter(gKey => gKey.in(pressedKeys));
                    group.push(key);
                    groups.push(group);
                } else {
                    groups[last].push(key);
                }
            }
        }
        // ensure max history
        if (state.showEventHistory && groups.length > state.maxGroups) {
            groups = groups.slice(groups.length - state.maxGroups);
        }

        set({ pressedKeys, groups });
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