import { create } from "zustand";

export interface KeyboardEvent {
  type: "Keyboard";
  event_type: "keydown" | "keyup";
  key_name: string;
  vk_code: number;
  modifiers: string[];
}

export interface MouseEvent {
  type: "Mouse";
  event_type: string;
  x: number;
  y: number;
  modifiers: string[];
}

export type HidEvent = KeyboardEvent | MouseEvent;

export type KeyEvent = {
  id: number;
  label: string;
  state: "pressed" | "released";
};

type KeyState = {
  // physical state
  pressedKeys: Set<number>;

  // visual state
  events: KeyEvent[];

  // config (later)
  lingerMs: number;

  // actions
  onEvent: (event: HidEvent) => void;
};

export const useHidStore = create<KeyState>((set, get) => ({
  pressedKeys: new Set(),
  events: [],
  lingerMs: 2000,

  // onEvent: (event) => {
  //   if (event.type === "Keyboard") {
  //     if (event.event_type === "keydown") {
  //       set((state) => {
  //         const pressed = new Set(state.pressedKeys);
  //         pressed.add(event.vk_code);
  //         return {
  //           pressedKeys: pressed,
  //           events: [
  //             ...state.events,
  //             {
  //               id: event.vk_code,
  //               label: event.key_name,
  //               state: "pressed",
  //               isMouse: false,
  //             },
  //           ],
  //         };
  //       });
  //     }

  //     if (event.event_type === "keyup") {
  //       set((state) => {
  //         const pressed = new Set(state.pressedKeys);
  //         pressed.delete(event.vk_code);

  //         return {
  //           pressedKeys: pressed,
  //           events: state.events.map((e) =>
  //             e.label === event.key_name && e.state === "pressed"
  //               ? { ...e, state: "released" }
  //               : e
  //           ),
  //         };
  //       });
  //     }
  //   }
  // },

  onEvent: (event) => {
    if (event.type === "Keyboard") {
      if (event.event_type === "keydown") {
        set((state) => {
          const pressed = new Set(state.pressedKeys);
          pressed.add(event.vk_code);
          return {
            pressedKeys: pressed,
            events: [
              ...state.events,
              {
                id: event.vk_code,
                label: event.key_name,
                state: "pressed",
              },
            ],
          };
        });
      }
      else if (event.event_type === "keyup") {
        set((state) => {
          const pressed = new Set(state.pressedKeys);
          pressed.delete(event.vk_code);
          return {
            pressedKeys: pressed,
            events: state.events.filter((e) => e.id !== event.vk_code),
          };
        });
      }
    }
  }
}));
