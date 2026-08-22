use std::{sync::Mutex, thread, time::Instant};

use rdev::{listen, Button, EventType, Key};
use serde::Serialize;
use tauri::{menu::MenuItem, AppHandle, Emitter, Manager, Wry};

use crate::app::state::AppState;

#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type")]
pub enum InputEvent {
    KeyEvent { pressed: bool, name: String },
    MouseButtonEvent { pressed: bool, button: MouseButton },
    MouseMoveEvent { x: f64, y: f64 },
    MouseWheelEvent { delta_x: i64, delta_y: i64 },
}

#[derive(Debug, Clone, Serialize)]
pub enum MouseButton {
    Left,
    Right,
    Middle,
    Other,
}

pub fn map_mouse_button(button: Button) -> MouseButton {
    match button {
        Button::Left => MouseButton::Left,
        Button::Right => MouseButton::Right,
        Button::Middle => MouseButton::Middle,
        _ => MouseButton::Other,
    }
}

pub fn start_listener(app_handle: AppHandle, toggle_menu_item: MenuItem<Wry>) {
    thread::spawn(move || {
        println!("Starting global input listener...");

        // AltGr detection state
        // Windows sends AltGr as Ctrl+Alt at the low-level hook.
        // We merge them back into a single AltGr key.
        let mut last_ctrl_press: Option<Instant> = None;
        let mut altgr_active = false;
        let mut skip_next_alt_release = false;
        const ALTGR_WINDOW_MS: u128 = 50;

        if let Err(err) = listen(move |event| {
            // get app state
            let state = app_handle.state::<Mutex<AppState>>();
            let mut app_state = state.lock().unwrap();

            // ─── AltGr merge: press side ───
            // When Alt is pressed right after ControlLeft, it's actually AltGr.
            if let EventType::KeyPress(key) = event.event_type {
                if key == Key::Alt {
                    if let Some(instant) = last_ctrl_press {
                        if instant.elapsed().as_millis() < ALTGR_WINDOW_MS {
                            // This is AltGr, not separate Ctrl+Alt
                            // Undo the ControlLeft that was already processed
                            app_state.pressed_keys.retain(|k| k != "ControlLeft");
                            let _ = app_handle.emit("input-event", InputEvent::KeyEvent {
                                pressed: false,
                                name: "ControlLeft".to_string(),
                            });
                            // Track AltGr instead
                            altgr_active = true;
                            last_ctrl_press = None;
                            let altgr_name = "AltGr".to_string();
                            if !app_state.pressed_keys.contains(&altgr_name) {
                                app_state.pressed_keys.push(altgr_name.clone());
                            }
                            // Emit AltGr press if listening
                            if app_state.listening {
                                let _ = app_handle.emit("input-event", InputEvent::KeyEvent {
                                    pressed: true,
                                    name: altgr_name,
                                });
                            }
                            return;
                        }
                    }
                }
                // Track ControlLeft press time for AltGr detection
                if key == Key::ControlLeft {
                    last_ctrl_press = Some(Instant::now());
                } else if key != Key::Alt {
                    last_ctrl_press = None;
                }
            }

            // ─── AltGr merge: release side ───
            if let EventType::KeyRelease(key) = event.event_type {
                // ControlLeft release while AltGr is active → emit AltGr release
                if altgr_active && key == Key::ControlLeft {
                    app_state.pressed_keys.retain(|k| k != "AltGr");
                    altgr_active = false;
                    skip_next_alt_release = true;
                    if app_state.listening {
                        let _ = app_handle.emit("input-event", InputEvent::KeyEvent {
                            pressed: false,
                            name: "AltGr".to_string(),
                        });
                    }
                    return;
                }
                // Skip the Alt release that follows AltGr release
                if skip_next_alt_release && key == Key::Alt {
                    skip_next_alt_release = false;
                    return;
                }
            }

            // track pressed keys
            if let EventType::KeyPress(key) = event.event_type {
                let key_name = format!("{:?}", key);
                // If the name contains parenthesis (like "RawKey(123)", "Unknown()"), ignore it.
                if key_name.contains('(') {
                    return;
                }
                // if key is already marked as pressed, ignore repeat
                if app_state.pressed_keys.contains(&key_name) {
                    return;
                }
                // record key as pressed
                app_state.pressed_keys.push(key_name);
                // check if toggle shortcut is pressed
                if app_state.toggle_shortcut == app_state.pressed_keys {
                    app_state.toggle_listener(&app_handle, &toggle_menu_item);

                    if !app_state.listening {
                        // emit key releases for all pressed keys
                        for key_name in &app_state.pressed_keys {
                            app_handle
                                .emit_to(
                                    "main",
                                    "input-event",
                                    InputEvent::KeyEvent {
                                        pressed: false,
                                        name: key_name.clone(),
                                    },
                                )
                                .unwrap()
                        }
                    }
                }
            } else if let EventType::KeyRelease(key) = event.event_type {
                let key_name = format!("{:?}", key);
                if key_name.contains('(') {
                    return;
                }
                // remove key from pressed keys
                app_state.pressed_keys.retain(|k| k != &key_name);
            }

            // emit event if listening
            if !app_state.listening {
                return;
            }
            let input_event = match event.event_type {
                EventType::KeyPress(key) => Some(InputEvent::KeyEvent {
                    pressed: true,
                    name: format!("{:?}", key),
                }),
                EventType::KeyRelease(key) => Some(InputEvent::KeyEvent {
                    pressed: false,
                    name: format!("{:?}", key),
                }),
                EventType::ButtonPress(button) => Some(InputEvent::MouseButtonEvent {
                    pressed: true,
                    button: map_mouse_button(button),
                }),
                EventType::ButtonRelease(button) => Some(InputEvent::MouseButtonEvent {
                    button: map_mouse_button(button),
                    pressed: false,
                }),
                EventType::MouseMove { x, y } => {
                    // Convert Physical -> Logical
                    #[cfg(target_os = "macos")]
                    let (logical_x, logical_y) = (
                        x - app_state.monitor_position.0 as f64,
                        y - app_state.monitor_position.1 as f64,
                    );

                    #[cfg(not(target_os = "macos"))]
                    let (logical_x, logical_y) = {
                        let (offset_x, offset_y) = app_state.monitor_position;
                        (x - offset_x as f64, y - offset_y as f64)
                    };

                    Some(InputEvent::MouseMoveEvent {
                        x: logical_x,
                        y: logical_y,
                    })
                }
                EventType::Wheel { delta_x, delta_y } => {
                    Some(InputEvent::MouseWheelEvent { delta_x, delta_y })
                }
            };

            app_handle.emit("input-event", input_event).unwrap();
        }) {
            eprintln!("rdev listen failed: {:?}", err);
        }
    });
}
