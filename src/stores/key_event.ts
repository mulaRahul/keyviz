import { EventPayload, KeyEvent, MappedKeys, MODIFIERS, MouseButton, MouseButtonEvent, MouseMoveEvent, MouseWheelEvent, RawKey, RawKeyEvent } from "@/types/event";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { createJSONStorage, persist } from "zustand/middleware";
import { tauriStorage } from "./storage";
import { createSyncedStore } from "./sync";

const HARD_MODIFIERS = new Set<string>([
    RawKey.ControlLeft,
    RawKey.ControlRight,
    RawKey.Alt,
    RawKey.MetaLeft,
    RawKey.MetaRight,
]);

const SOFT_MODIFIERS = new Set<string>([
    RawKey.ShiftLeft,
    RawKey.ShiftRight,
]);

const PUNCTUATION_KEYS = new Set<string>([
    RawKey.BackQuote,
    RawKey.Minus,
    RawKey.Equal,
    RawKey.LeftBracket,
    RawKey.RightBracket,
    RawKey.BackSlash,
    RawKey.SemiColon,
    RawKey.Quote,
    RawKey.Comma,
    RawKey.Dot,
    RawKey.Slash,
    RawKey.Space,
    RawKey.KpDecimal,
    RawKey.KpComma,
    RawKey.KpDivide,
    RawKey.KpMultiply,
    RawKey.KpMinus,
    RawKey.KpPlus,
    RawKey.KpEqual,
]);

const isPrintableKeyName = (name: string) => {
    if (name.startsWith("Key")) return true;
    if (/^Num[0-9]$/.test(name)) return true;
    if (name.startsWith("Kp") && /^Kp[0-9]$/.test(name)) return true;
    return PUNCTUATION_KEYS.has(name);
};

const isHardModifierName = (name: string) => HARD_MODIFIERS.has(name);


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
    showMouseEvents: boolean;
    lingerDurationMs: number;
    toggleShortcut: string[];
    textSequenceEnabled: boolean;
    capsLockOn: boolean;
}

interface KeyEventActions {
    // ───────────── setters ─────────────
    setDragThreshold(value: KeyEventState["dragThreshold"]): void;
    setFilter(value: KeyEventState["filter"]): void;
    setAllowedKeys(keys: KeyEventState["allowedKeys"]): void;
    setShowEventHistory(value: KeyEventState["showEventHistory"]): void;
    setMaxHistory(value: KeyEventState["maxHistory"]): void;
    setShowMouseEvents(value: KeyEventState["showMouseEvents"]): void;
    setLingerDurationMs(value: KeyEventState["lingerDurationMs"]): void;
    setToggleShortcut(value: KeyEventState["toggleShortcut"]): void;
    setTextSequenceEnabled(value: KeyEventState["textSequenceEnabled"]): void;
    // ───────────── event actions ─────────────
    onEvent(event: EventPayload): void;
    onKeyPress(event: RawKeyEvent): void;
    ignoreEvent(event: RawKeyEvent, pressedKeys: string[]): boolean;
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
        lingerDurationMs: 3_000,
        showMouseEvents: true,
        toggleShortcut: [RawKey.ShiftLeft, RawKey.F10],
        textSequenceEnabled: true,
        capsLockOn: false,

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
        setShowMouseEvents(value: boolean) {
            set({ showMouseEvents: value });
        },
        setLingerDurationMs(value: number) {
            set({ lingerDurationMs: value });
        },
        setToggleShortcut(value: string[]) {
            set({ toggleShortcut: value });
        },
        setTextSequenceEnabled(value: boolean) {
            set({ textSequenceEnabled: value });
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
            const nextCapsLockOn = event.name === RawKey.CapsLock && event.pressed
                ? !state.capsLockOn
                : state.capsLockOn;
            // 0. track physical state
            const pressedKeys = [...state.pressedKeys];
            pressedKeys.push(event.name);

            // 1. filter event
            if (state.filter !== "none" && state.ignoreEvent(event, pressedKeys)) {
                if (nextCapsLockOn !== state.capsLockOn) {
                    set({ pressedKeys, capsLockOn: nextCapsLockOn });
                } else {
                    set({ pressedKeys });
                }
                return;
            }

            let groups = [...state.groups];
            const last = groups.length - 1;
            const shiftActive = pressedKeys.includes(RawKey.ShiftLeft) || pressedKeys.includes(RawKey.ShiftRight);
            const key = new KeyEvent(event.name, { shifted: shiftActive, capsLock: nextCapsLockOn });

            const hardModifierDown = pressedKeys.some((keyName) => isHardModifierName(keyName));
            const textSequenceActive = state.textSequenceEnabled && isPrintableKeyName(key.name) && !hardModifierDown;

            if (textSequenceActive) {
                const createdAt = state.showEventHistory ? Date.now() : 0;
                if (last < 0) {
                    groups = [{ keys: [key], createdAt }];
                } else {
                    const lastGroup = groups[last];
                    const canAppend = lastGroup.keys.every((gKey) => (
                        isPrintableKeyName(gKey.name) || SOFT_MODIFIERS.has(gKey.name)
                    ));
                    if (canAppend) {
                        let lastPrintableIndex = -1;
                        for (let i = lastGroup.keys.length - 1; i >= 0; i -= 1) {
                            if (isPrintableKeyName(lastGroup.keys[i].name)) {
                                lastPrintableIndex = i;
                                break;
                            }
                        }
                        if (lastPrintableIndex >= 0) {
                            const lastPrintable = lastGroup.keys[lastPrintableIndex];
                            if (
                                lastPrintable.name === key.name &&
                                lastPrintable.shifted === key.shifted &&
                                lastPrintable.capsLock === key.capsLock
                            ) {
                                lastPrintable.press();
                            } else {
                                lastGroup.keys.push(key);
                            }
                        } else {
                            lastGroup.keys.push(key);
                        }
                    } else {
                        if (state.showEventHistory) {
                            groups.push({ keys: [key], createdAt });
                        } else {
                            groups = [{ keys: [key], createdAt }];
                        }
                    }
                }
                if (state.showEventHistory && groups.length > state.maxHistory) {
                    groups = groups.slice(groups.length - state.maxHistory);
                }
                set({ pressedKeys, groups, capsLockOn: nextCapsLockOn });
                return;
            }

            // 2. check if pressed again
            const existingKey = last >= 0 ? groups[last].keys.find(gKey => gKey.name === key.name) : undefined;
            if (existingKey) {
                // history mode, add new group
                if (state.showEventHistory && groups[last].keys.length > 1) {
                    const groupKeys: KeyEvent[] = [];
                    groups[last].keys.forEach(gKey => {
                        if (gKey.in(pressedKeys)) {
                            groupKeys.push(new KeyEvent(gKey.name, { shifted: gKey.shifted, capsLock: gKey.capsLock }));
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

            set({ pressedKeys, groups, capsLockOn: nextCapsLockOn });
        },
        ignoreEvent(event, pressedKeys) {
            const state = get();
            if (state.filter === "modifiers") {
                return pressedKeys.length === 1
                    ? !MODIFIERS.has(event.name) // single non-modifier
                    : !MODIFIERS.has(pressedKeys[0]); // combination not starting with modifier
            }
            else if (state.filter === "custom") {
                return pressedKeys.length === 1
                    ? !state.allowedKeys.includes(event.name)
                    : !state.allowedKeys.includes(pressedKeys[0]);
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
            if (state.showMouseEvents && mouse.dragStart && !mouse.dragging) {
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

                    // simulate drag as key press
                    state.onKeyPress({ type: "KeyEvent", name: "Drag", pressed: true });
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
            if (state.showMouseEvents) {
                state.onKeyPress({ type: "KeyEvent", name: event.button.toString(), pressed: true });
            }

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
            } else if (state.showMouseEvents) {
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
            // update mouse wheel state
            const mouse = {
                ...state.mouse,
                wheel: Math.sign(event.delta_y), // -1 for up, 1 for down
                lastScrollAt: Date.now()
            };
            const raw_key = event.delta_y > 0 ? RawKey.ScrollUp : RawKey.ScrollDown;
            // simulate mouse wheel as key press
            if (state.showMouseEvents && !state.pressedKeys.includes(raw_key)) {
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
                // simulate scroll key release
                state.onKeyRelease({ type: "KeyEvent", name: state.mouse.wheel > 0 ? RawKey.ScrollUp : RawKey.ScrollDown, pressed: false });
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
            const { pressedKeys, pressedMouseButton, mouse, groups, settingsOpen, capsLockOn, ...persistedState } = state;
            return persistedState;
        },
    }),
);

export const useKeyEvent = createKeyEventStore(getCurrentWindow().label === "settings");