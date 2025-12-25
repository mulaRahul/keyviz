use std::{sync::Mutex, thread};

use rdev::{listen, Button, EventType, Key};
use serde::Serialize;
use tauri::{image::Image, include_image, menu::MenuItem, AppHandle, Emitter, Manager, Wry};

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

pub fn map_key(key: Key) -> String {
    match key {
        // ───────────── Modifiers ─────────────
        Key::ShiftLeft | Key::ShiftRight => "Shift",
        Key::ControlLeft | Key::ControlRight => "Ctrl",
        Key::Alt | Key::AltGr => "Alt",
        Key::MetaLeft | Key::MetaRight => "Meta",
        Key::CapsLock => "Caps Lock",
        Key::Function => "Fn",

        // ───────────── Navigation ─────────────
        Key::UpArrow => "↑",
        Key::DownArrow => "↓",
        Key::LeftArrow => "←",
        Key::RightArrow => "→",
        Key::Home => "Home",
        Key::End => "End",
        Key::PageUp => "Page Up",
        Key::PageDown => "Page Down",
        Key::Insert => "Insert",
        Key::Delete => "Delete",

        // ───────────── Editing / Control ─────────────
        Key::Return => "Enter",
        Key::KpReturn => "Num Enter",
        Key::Tab => "Tab",
        Key::Backspace => "Backspace",
        Key::Escape => "Esc",
        Key::Space => "Space",
        Key::PrintScreen => "Print Screen",
        Key::ScrollLock => "Scroll Lock",
        Key::Pause => "Pause",
        Key::NumLock => "Num Lock",

        // ───────────── Function keys ─────────────
        Key::F1 => "F1",
        Key::F2 => "F2",
        Key::F3 => "F3",
        Key::F4 => "F4",
        Key::F5 => "F5",
        Key::F6 => "F6",
        Key::F7 => "F7",
        Key::F8 => "F8",
        Key::F9 => "F9",
        Key::F10 => "F10",
        Key::F11 => "F11",
        Key::F12 => "F12",
        // Key::F13 => "F13", Key::F14 => "F14", Key::F15 => "F15",
        // Key::F16 => "F16", Key::F17 => "F17", Key::F18 => "F18",
        // Key::F19 => "F19", Key::F20 => "F20", Key::F21 => "F21",
        // Key::F22 => "F22", Key::F23 => "F23", Key::F24 => "F24",

        // ───────────── Number row ─────────────
        Key::Num1 => "1",
        Key::Num2 => "2",
        Key::Num3 => "3",
        Key::Num4 => "4",
        Key::Num5 => "5",
        Key::Num6 => "6",
        Key::Num7 => "7",
        Key::Num8 => "8",
        Key::Num9 => "9",
        Key::Num0 => "0",

        // ───────────── Letters ─────────────
        Key::KeyA => "A",
        Key::KeyB => "B",
        Key::KeyC => "C",
        Key::KeyD => "D",
        Key::KeyE => "E",
        Key::KeyF => "F",
        Key::KeyG => "G",
        Key::KeyH => "H",
        Key::KeyI => "I",
        Key::KeyJ => "J",
        Key::KeyK => "K",
        Key::KeyL => "L",
        Key::KeyM => "M",
        Key::KeyN => "N",
        Key::KeyO => "O",
        Key::KeyP => "P",
        Key::KeyQ => "Q",
        Key::KeyR => "R",
        Key::KeyS => "S",
        Key::KeyT => "T",
        Key::KeyU => "U",
        Key::KeyV => "V",
        Key::KeyW => "W",
        Key::KeyX => "X",
        Key::KeyY => "Y",
        Key::KeyZ => "Z",

        // ───────────── Punctuation ─────────────
        Key::BackQuote => "`",
        Key::Minus => "-",
        Key::Equal => "=",
        Key::LeftBracket => "[",
        Key::RightBracket => "]",
        Key::BackSlash | Key::IntlBackslash => "\\",
        Key::SemiColon => ";",
        Key::Quote => "'",
        Key::Comma => ",",
        Key::Dot => ".",
        Key::Slash => "/",

        // ───────────── Numpad ─────────────
        Key::Kp0 => "Num 0",
        Key::Kp1 => "Num 1",
        Key::Kp2 => "Num 2",
        Key::Kp3 => "Num 3",
        Key::Kp4 => "Num 4",
        Key::Kp5 => "Num 5",
        Key::Kp6 => "Num 6",
        Key::Kp7 => "Num 7",
        Key::Kp8 => "Num 8",
        Key::Kp9 => "Num 9",
        Key::KpPlus => "Num +",
        Key::KpMinus => "Num -",
        Key::KpMultiply => "Num *",
        Key::KpDivide => "Num /",
        Key::KpDecimal => "Num .",
        Key::KpEqual => "Num =",
        Key::KpComma => "Num ,",

        // ───────────── Media ─────────────
        Key::VolumeUp => "Volume +",
        Key::VolumeDown => "Volume -",
        Key::VolumeMute => "Mute",

        // ───────────── Language / IME ─────────────
        // Key::Lang1 => "Lang 1",
        // Key::Lang2 => "Lang 2",
        // Key::Lang3 => "Lang 3",
        // Key::Lang4 => "Lang 4",
        // Key::Lang5 => "Lang 5",
        // Key::Kana | Key::KanaMode => "Kana",
        // Key::Hangul => "Hangul",
        // Key::Hanja | Key::Hanji => "Hanja",
        // Key::Junja => "Junja",
        // Key::Final => "Final",

        // ───────────── System / Legacy ─────────────
        Key::Apps => "Menu",
        Key::Help => "Help",
        Key::Sleep => "Sleep",
        Key::Select => "Select",
        Key::Execute => "Execute",
        Key::Print => "Print",
        Key::Clear => "Clear",
        Key::Cancel => "Cancel",
        Key::Separator => "Separator",

        // ───────────── Unknown / Raw ─────────────
        // Key::RawKey(_) => "RawKey",
        _ => "Unknown",
    }
    .to_string()
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

        if let Err(err) = listen(move |event| {
            // get app state
            let state = app_handle.state::<Mutex<AppState>>();
            let mut app_state = state.lock().unwrap();

            // track pressed keys
            if let EventType::KeyPress(key) = event.event_type {
                let name = map_key(key);
                // if key is already marked as pressed, ignore repeat
                if app_state.pressed_keys.contains(&name) {
                    return;
                }
                // record key as pressed
                app_state.pressed_keys.push(name);
                // check if toggle shortcut is pressed
                if app_state.toggle_shortcut == app_state.pressed_keys {
                    app_state.listening = !app_state.listening;

                    if app_state.listening {
                        println!("🟢 Listening enabled via shortcut.");
                        toggle_menu_item.set_text("Stop").unwrap();
                        app_handle
                            .tray_by_id("keyviz-tray")
                            .unwrap()
                            .set_icon(Some(Image::from(include_image!("icons/tray.png"))))
                            .unwrap();
                    } else {
                        toggle_menu_item.set_text("Start").unwrap();
                        println!("🔴 Listening disabled via shortcut.");
                        app_handle
                            .tray_by_id("keyviz-tray")
                            .unwrap()
                            .set_icon(Some(Image::from(include_image!("icons/tray-disabled.png"))))
                            .unwrap();
                        // emit key releases for all pressed keys
                        for key_name in &app_state.pressed_keys {
                            app_handle
                                .emit(
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
                // remove key from pressed keys
                let name = map_key(key);
                app_state.pressed_keys.retain(|k| k != &name);
            }

            // emit event if listening
            if !app_state.listening {
                return;
            }
            let input_event = match event.event_type {
                EventType::KeyPress(key) => Some(InputEvent::KeyEvent {
                    pressed: true,
                    name: map_key(key),
                }),
                EventType::KeyRelease(key) => Some(InputEvent::KeyEvent {
                    pressed: false,
                    name: map_key(key),
                }),
                EventType::ButtonPress(button) => Some(InputEvent::MouseButtonEvent {
                    pressed: true,
                    button: map_mouse_button(button),
                }),
                EventType::ButtonRelease(button) => Some(InputEvent::MouseButtonEvent {
                    button: map_mouse_button(button),
                    pressed: false,
                }),
                EventType::MouseMove { x, y } => Some(InputEvent::MouseMoveEvent { x, y }),
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
