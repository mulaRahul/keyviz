use std::{sync::Mutex, thread};

use rdev::{listen, Button, EventType};
use serde::Serialize;
use tauri::{menu::MenuItem, AppHandle, Emitter, Manager, Wry};

use crate::app::{monitors, state::AppState};

#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type")]
pub enum InputEvent {
    KeyEvent {
        pressed: bool,
        name: String,
    },
    MouseButtonEvent {
        pressed: bool,
        button: MouseButton,
        /// Click position, local to the window the event is delivered to.
        x: f64,
        y: f64,
    },
    MouseMoveEvent {
        x: f64,
        y: f64,
    },
    MouseWheelEvent {
        delta_x: i64,
        delta_y: i64,
        /// Cursor position, local to the window the event is delivered to.
        x: f64,
        y: f64,
    },
}

#[derive(Debug, Clone, Serialize)]
pub enum MouseButton {
    Left,
    Right,
    Middle,
    Back,
    Forward,
    Other,
}

/// A resolved destination for an input event. Labels are only built when the
/// event is actually sent, after the state lock has been released.
enum Emission {
    Main(InputEvent),
    /// Monitor index, delivered to the `overlay-{index}` window.
    Overlay(usize, InputEvent),
    /// Monitor index, delivered to the `keys-{index}` window.
    Keys(usize, InputEvent),
}

pub fn map_mouse_button(button: Button) -> MouseButton {
    match button {
        Button::Left => MouseButton::Left,
        Button::Right => MouseButton::Right,
        Button::Middle => MouseButton::Middle,
        // Common side-button codes across Windows, macOS, and Linux/X11.
        Button::Unknown(code) if matches!(code, 1 | 3 | 8) => MouseButton::Back,
        Button::Unknown(code) if matches!(code, 2 | 4 | 9) => MouseButton::Forward,
        _ => MouseButton::Other,
    }
}

pub fn start_listener(app_handle: AppHandle, toggle_menu_item: MenuItem<Wry>) {
    thread::spawn(move || {
        println!("Starting global input listener...");

        if let Err(err) = listen(move |event| {
            let emissions = {
                let state = app_handle.state::<Mutex<AppState>>();
                let mut app_state = state.lock().unwrap();

                handle_event(&app_handle, &mut app_state, &toggle_menu_item, event.event_type)
            };

            // Send outside the lock: emitting while holding it would stall the
            // input listener behind a busy webview, and `.unwrap()` here used
            // to panic whenever a window had just been closed.
            for emission in emissions {
                match emission {
                    Emission::Main(event) => {
                        let _ = app_handle.emit_to("main", "input-event", event);
                    }
                    Emission::Keys(index, event) => {
                        let _ = app_handle.emit_to(format!("keys-{index}"), "input-event", event);
                    }
                    Emission::Overlay(index, event) => {
                        let _ =
                            app_handle.emit_to(format!("overlay-{index}"), "input-event", event);
                    }
                }
            }
        }) {
            eprintln!("rdev listen failed: {:?}", err);
        }
    });
}

/// Updates the listener state and returns everything that has to be sent for
/// this event.
fn handle_event(
    app_handle: &AppHandle,
    app_state: &mut AppState,
    toggle_menu_item: &MenuItem<Wry>,
    event: EventType,
) -> Vec<Emission> {
    let mut emissions = Vec::new();

    // track pressed keys before filtering, so the toggle shortcut keeps
    // working while the listener is off
    if let EventType::KeyPress(key) = &event {
        let key_name = format!("{:?}", key);
        // If the name contains parenthesis (like "RawKey(123)", "Unknown()"), ignore it.
        if key_name.contains('(') {
            return emissions;
        }
        // if key is already marked as pressed, ignore repeat
        if app_state.pressed_keys.contains(&key_name) {
            return emissions;
        }
        // record key as pressed
        app_state.pressed_keys.push(key_name);

        // check if toggle shortcut is pressed
        if app_state.toggle_shortcut == app_state.pressed_keys {
            app_state.toggle_listener(app_handle, toggle_menu_item);

            if !app_state.listening {
                // emit key releases for all pressed keys
                for key_name in &app_state.pressed_keys {
                    push_key(app_state, &mut emissions, false, key_name.clone());
                }

                return emissions;
            }
        }
    } else if let EventType::KeyRelease(key) = &event {
        let key_name = format!("{:?}", key);
        if key_name.contains('(') {
            return emissions;
        }
        // remove key from pressed keys
        app_state.pressed_keys.retain(|k| k != &key_name);
    }

    // emit event if listening
    if !app_state.listening {
        return emissions;
    }

    match event {
        EventType::KeyPress(key) => {
            push_key(app_state, &mut emissions, true, format!("{:?}", key));
        }
        EventType::KeyRelease(key) => {
            push_key(app_state, &mut emissions, false, format!("{:?}", key));
        }
        EventType::ButtonPress(button) => {
            let pointer = app_state.pointer;

            emit_mouse(app_state, &mut emissions, pointer, |x, y| {
                InputEvent::MouseButtonEvent {
                    pressed: true,
                    button: map_mouse_button(button),
                    x,
                    y,
                }
            });
        }
        EventType::ButtonRelease(button) => {
            let pointer = app_state.pointer;

            emit_mouse(app_state, &mut emissions, pointer, |x, y| {
                InputEvent::MouseButtonEvent {
                    pressed: false,
                    button: map_mouse_button(button),
                    x,
                    y,
                }
            });
        }
        EventType::MouseMove { x, y } => {
            app_state.pointer = (x, y);

            emit_mouse(app_state, &mut emissions, (x, y), |x, y| {
                InputEvent::MouseMoveEvent { x, y }
            });
        }
        EventType::Wheel { delta_x, delta_y } => {
            let pointer = app_state.pointer;

            emit_mouse(app_state, &mut emissions, pointer, |x, y| {
                InputEvent::MouseWheelEvent {
                    delta_x,
                    delta_y,
                    x,
                    y,
                }
            });
        }
    }

    emissions
}

/// Queues a key event for the main window and for every display that renders
/// its own keycaps.
fn push_key(app_state: &AppState, emissions: &mut Vec<Emission>, pressed: bool, name: String) {
    emissions.push(Emission::Main(InputEvent::KeyEvent {
        pressed,
        name: name.clone(),
    }));

    for index in &app_state.key_stages {
        emissions.push(Emission::Keys(
            *index,
            InputEvent::KeyEvent {
                pressed,
                name: name.clone(),
            },
        ));
    }
}

/// Queues a mouse event for every window that should draw it: the main window
/// (keys, drag detection, legacy rendering) and, when enabled, the overlay of
/// the monitor the pointer is on.
///
/// Each copy carries coordinates local to its own window, which is the whole
/// point of the per-monitor overlay: a click on a display the main window does
/// not cover still lands at the right pixel of that display.
fn emit_mouse<F>(app_state: &AppState, emissions: &mut Vec<Emission>, global: (f64, f64), build: F)
where
    F: Fn(f64, f64) -> InputEvent,
{
    let (main_x, main_y) = monitors::to_local(app_state.monitor_position, global.0, global.1);
    emissions.push(Emission::Main(build(main_x, main_y)));

    if !app_state.mouse_overlays {
        return;
    }

    let Some(index) = monitors::monitor_at(&app_state.monitors, global.0, global.1) else {
        return;
    };
    let Some(rect) = app_state.monitors.get(index) else {
        return;
    };

    let (x, y) = rect.to_local(global.0, global.1);
    emissions.push(Emission::Overlay(index, build(x, y)));
}
