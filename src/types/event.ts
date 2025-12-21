export type EventPayload =
  | KeyEvent
  | MouseButtonEvent
  | MouseMoveEvent
  | MouseWheelEvent;

export interface KeyEvent {
  type: "KeyEvent";
  pressed: boolean;
  name: string;
}

export interface MouseButtonEvent {
  type: "MouseButtonEvent";
  pressed: boolean;
  button: MouseButton;
}

export interface MouseMoveEvent {
  type: "MouseMoveEvent";
  x: number;
  y: number;
}

export interface MouseWheelEvent {
  type: "MouseWheelEvent";
  delta_x: number;
  delta_y: number;
}

export type MouseButton =
  | "Left"
  | "Right"
  | "Middle"
  | "Other";
