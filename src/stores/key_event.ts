import { EventPayload, KeyEvent, MappedKeys, MODIFIERS, MouseButton, MouseButtonEvent, MouseMoveEvent, MouseWheelEvent, RawKey, RawKeyEvent } from "@/types/event";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { createJSONStorage, persist } from "zustand/middleware";
import { tauriStorage } from "./storage";
import { createSyncedStore } from "./sync";


export const KEY_EVENT_STORE = "key_event_store";
const SCROLL_LINGER_MS = 300;

interface KeyGroup {
    keys: KeyEvent[];
    createdAt: number;
}

export interface KeyEventState {
    // ───────────── physical state ─────────────
    pressedKeys: string[];
    pressedMouseButton: MouseButton | null;
    mouse: {
        x: number;
        y: number;
        wheel: number;
        lastScrollAt?: number;
        dragStart?: { x: number; y: number; };
        dragging: boolean;
    };
    // ───────────── visual state ─────────────
    settingsOpen: boolean;
    groups: KeyGroup[];
    // ───────────── config ─────────────
    dragThreshold: number;
    filter: "none" | "modifiers" | "custom";
    allowedKeys: string[];
    showEventHistory: boolean;
    maxHistory: number;
    lingerDurationMs: number;
    toggleShortcut: string[];
}

interface KeyEventActions {
    // ───────────── setters ─────────────
    setDragThreshold(value: KeyEventState["dragThreshold"]): void;
    setFilter(value: KeyEventState["filter"]): void;
    setAllowedKeys(keys: KeyEventState["allowedKeys"]): void;
    setShowEventHistory(value: KeyEventState["showEventHistory"]): void;
    setMaxHistory(value: KeyEventState["maxHistory"]): void;
    // setShowMouseEvents(value: KeyEventState["showMouseEvents"]): void;
    setLingerDurationMs(value: KeyEventState["lingerDurationMs"]): void;
    setToggleShortcut(value: KeyEventState["toggleShortcut"]): void;
    // ───────────── event actions ─────────────
    onEvent(event: EventPayload): void;
    onKeyPress(event: RawKeyEvent): void;
    ignoreEvent(pressedKeys: string[]): boolean;
    onKeyRelease(event: RawKeyEvent): void;
    onMouseMove(event: MouseMoveEvent): void;
    onMouseButtonPress(event: MouseButtonEvent): void;
    onMouseButtonRelease(event: MouseButtonEvent): void;
    onMouseWheel(event: MouseWheelEvent): void;
    tick(): void;
}

export type KeyEventStore = KeyEventState & KeyEventActions;

const createKeyEventStore = createSyncedStore<KeyEventStore>(
    KEY_EVENT_STORE,
    (set, get) => ({
        pressedKeys: <string[]>[],
        pressedMouseButton: null,
        mouse: { x: 0, y: 0, wheel: 0, dragging: false },
        groups: <KeyGroup[]>[],
        listening: true,
        settingsOpen: false,
        dragThreshold: 50,
        filter: "modifiers",
        allowedKeys: [
            RawKey.ControlLeft,
            RawKey.MetaLeft,
            RawKey.Alt
        ],
        showEventHistory: false,
        maxHistory: 5,
        lingerDurationMs: 5_000,
        toggleShortcut: [RawKey.ShiftLeft, RawKey.F10],

        setDragThreshold(value: number) {
            set({ dragThreshold: value });
        },
        setFilter(value: "none" | "modifiers" | "custom") {
            set({ filter: value });
        },
        setAllowedKeys(keys: string[]) {
            set({ allowedKeys: keys });
        },
        setShowEventHistory(value: boolean) {
            set({ showEventHistory: value });
        },
        setMaxHistory(value: number) {
            set({ maxHistory: value });
        },
        setLingerDurationMs(value: number) {
            set({ lingerDurationMs: value });
        },
        setToggleShortcut(value: string[]) {
            set({ toggleShortcut: value });
        },
        onEvent(event: EventPayload) {
            const state = get();
            switch (event.type) {
                case "KeyEvent":
                    if (!MappedKeys.has(event.name)) return;
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
        onKeyPress(event: RawKeyEvent) {
            const state = get();
            // 0. track physical state
            const pressedKeys = [...state.pressedKeys];
            pressedKeys.push(event.name);

            // 1. filter event
            if (state.filter !== "none" && state.ignoreEvent(pressedKeys)) {
                set({ pressedKeys });
                return;
            }

            let groups = [...state.groups];
            const last = groups.length - 1;
            const key = new KeyEvent(event.name);

            // 2. check if pressed again
            const existingKey = last >= 0 ? groups[last].keys.find(gKey => gKey.name === key.name) : undefined;
            if (existingKey) {
                // history mode, add new group
                if (state.showEventHistory && groups[last].keys.length > 1) {
                    const groupKeys: KeyEvent[] = [];
                    groups[last].keys.forEach(gKey => {
                        if (gKey.in(pressedKeys)) {
                            groupKeys.push(new KeyEvent(gKey.name));
                        }
                    });
                    groups.push({ keys: groupKeys, createdAt: state.showEventHistory ? Date.now() : 0 });
                }
                // replace mode, only currently pressed keys
                // or
                // history mode, last group has only this key
                else {
                    let groupKeys = <KeyEvent[]>[];
                    groups[last].keys.forEach(gKey => {
                        if (gKey.name === key.name) {
                            // update existing key's pressed count and time
                            existingKey.press();
                            groupKeys.push(existingKey);
                        } else if (gKey.in(pressedKeys)) {
                            groupKeys.push(gKey);
                        }
                    });
                    groups[last].keys = groupKeys;
                }
            }
            // 3. add to group
            else {
                const createdAt = state.showEventHistory ? Date.now() : 0;
                // add new group
                if (pressedKeys.length === 1 || last < 0) {
                    if (state.showEventHistory) {
                        groups.push({ keys: [key], createdAt });
                    } else {
                        groups = [{ keys: [key], createdAt }];
                    }
                }
                // key combination
                else {
                    if (state.showEventHistory && groups[last].keys.some(gKey => !gKey.in(pressedKeys))) {
                        // history mode, partial combination, add new group
                        const groupKeys = groups[last].keys.filter(gKey => gKey.in(pressedKeys));
                        groupKeys.push(key);
                        groups.push({ keys: groupKeys, createdAt });
                    } else {
                        groups[last].keys.push(key);
                    }
                }
            }
            // ensure max history
            if (state.showEventHistory && groups.length > state.maxHistory) {
                groups = groups.slice(groups.length - state.maxHistory);
            }

            set({ pressedKeys, groups });
        },
        ignoreEvent(pressedKeys) {
            const state = get();
            if (state.filter === "modifiers") {
                return !MODIFIERS.has(pressedKeys[0]);
            }
            else if (state.filter === "custom") {
                return !state.allowedKeys.includes(pressedKeys[0]);
            }
            return false;
        },
        onKeyRelease(event: RawKeyEvent) {
            const state = get();
            // track physical state
            const pressedKeys = state.pressedKeys.filter(keyName => keyName !== event.name);

            // update last pressed time
            const groups = [...state.groups];
            const last = groups.length - 1;

            const kIndex = last >= 0 ? groups[last].keys.findIndex(key => key.name === event.name) : undefined;
            if (kIndex && kIndex >= 0) {
                groups[last].keys[kIndex].lastPressedAt = Date.now();
                set({ pressedKeys, groups });
            } else {
                set({ pressedKeys });
            }
        },
        onMouseMove(event: MouseMoveEvent) {
            const state = get();
            const mouse = { ...state.mouse };
            // update position
            mouse.x = event.x;
            mouse.y = event.y;
            // check dragging
            if (mouse.dragStart && !mouse.dragging) {
                const dx = mouse.x - mouse.dragStart.x;
                const dy = mouse.y - mouse.dragStart.y;
                const dragDistance = Math.hypot(dx, dy);

                if (dragDistance > state.dragThreshold) {
                    mouse.dragging = true;

                    // remove mouse button from pressed keys
                    const pressedKeys = state.pressedKeys.filter(keyName => keyName !== state.pressedMouseButton?.toString());

                    // remove mouse button from last group
                    const groups = [...state.groups];
                    const last = groups.length - 1;
                    if (last >= 0) {
                        groups[last].keys = groups[last].keys.filter(key => key.name !== state.pressedMouseButton?.toString());
                    }

                    set({ pressedKeys, mouse, groups });

                    // Check if group has any keys to visualize (in combination) or simulate drag if allowed
                    const hasGroupKeys = last >= 0 && groups[last].keys.length > 0;
                    const dragAllowed = state.filter != "custom" || (
                        state.pressedMouseButton &&
                        state.allowedKeys.includes(state.pressedMouseButton.toString()) &&
                        state.allowedKeys.includes("Drag")
                    );

                    if (hasGroupKeys || dragAllowed) {
                        // simulate drag as key press
                        state.onKeyPress({ type: "KeyEvent", name: "Drag", pressed: true });
                    }
                    return;
                }
            }
            set({ mouse });
        },
        onMouseButtonPress(event: MouseButtonEvent) {
            const state = get();
            // set drag start position
            const mouse = {
                ...state.mouse,
                dragStart: { x: state.mouse.x, y: state.mouse.y },
            };

            // simulate mouse button press as key
            state.onKeyPress({ type: "KeyEvent", name: event.button.toString(), pressed: true });

            set({
                pressedMouseButton: event.button,
                mouse
            });
        },
        onMouseButtonRelease(event: MouseButtonEvent) {
            const state = get();
            // reset drag state
            const mouse = {
                ...state.mouse,
                dragging: false,
                dragStart: undefined
            };
            // check if was dragging
            if (state.mouse.dragging) {
                // simulate drag release as key
                state.onKeyRelease({ type: "KeyEvent", name: "Drag", pressed: false });
            } else {
                // simulate mouse button release as key
                state.onKeyRelease({ type: "KeyEvent", name: event.button.toString(), pressed: false });
            }
            set({
                pressedMouseButton: null,
                mouse
            });
        },
        onMouseWheel(event: MouseWheelEvent) {
            // bug: history mode, ctrl + scroll, scroll
            const state = get();
            const wheel = Math.sign(event.delta_y);

            if (wheel === 0) return;

            const raw_key = wheel > 0 ? RawKey.ScrollUp : RawKey.ScrollDown;
            const previous_raw_key = state.mouse.wheel > 0 ? RawKey.ScrollUp : RawKey.ScrollDown;

            if (
                state.mouse.wheel !== 0 &&
                state.mouse.wheel !== wheel &&
                state.pressedKeys.includes(previous_raw_key)
            ) {
                state.onKeyRelease({ type: "KeyEvent", name: previous_raw_key, pressed: false });
            }

            // update mouse wheel state
            const mouse = {
                ...state.mouse,
                wheel, // -1 for down, 1 for up
                lastScrollAt: Date.now()
            };
            // simulate mouse wheel as key press
            if (!get().pressedKeys.includes(raw_key)) {
                state.onKeyPress({ type: "KeyEvent", name: raw_key, pressed: true });
            }

            set({ mouse });
        },
        tick() {
            // todo: remove pressed keys with unsually long linger duration
            const state = get();
            const now = Date.now();
            let notify = false;

            const groups = <KeyGroup[]>[];

            // handle scroll linger
            if (state.mouse.lastScrollAt && now - state.mouse.lastScrollAt > SCROLL_LINGER_MS) {
                if (state.pressedKeys.includes(RawKey.ScrollUp)) {
                    state.onKeyRelease({ type: "KeyEvent", name: RawKey.ScrollUp, pressed: false });
                }
                if (state.pressedKeys.includes(RawKey.ScrollDown)) {
                    state.onKeyRelease({ type: "KeyEvent", name: RawKey.ScrollDown, pressed: false });
                }
                set({ mouse: { ...state.mouse, wheel: 0, lastScrollAt: undefined } });
            }

            // don't remove keys while styling
            if (state.settingsOpen) return;

            // remove keys that have exceeded linger duration
            for (const group of state.groups) {
                const updatedKeys = group.keys.filter((key) => {
                    // keep key if
                    return (
                        // is pressed
                        state.pressedKeys.includes(key.name) ||
                        // within linger duration 
                        now - key.lastPressedAt < state.lingerDurationMs
                    );
                })
                if (updatedKeys.length !== group.keys.length) {
                    notify = true;
                }
                if (updatedKeys.length > 0) {
                    groups.push({ keys: updatedKeys, createdAt: group.createdAt });
                }
            }

            if (notify) {
                set({ groups });
            }
        }
    }),
    (config) => persist(config, {
        name: KEY_EVENT_STORE,
        storage: createJSONStorage(() => tauriStorage),
        partialize: (state) => {
            const { pressedKeys, pressedMouseButton, mouse, groups, settingsOpen, ...persistedState } = state;
            return persistedState;
        },
    }),
);

export const useKeyEvent = createKeyEventStore(getCurrentWindow().label === "settings");