mod platform;

use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread;
use tauri::{AppHandle, Emitter};

static LISTENER_RUNNING: AtomicBool = AtomicBool::new(false);

/// Combined event for frontend consumption
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum HidEvent {
    Keyboard {
        event_type: String,
        key_name: String,
        vk_code: u32,
        modifiers: Vec<String>,
    },
    Mouse {
        event_type: String,
        x: i32,
        y: i32,
        modifiers: Vec<String>,
    },
}

/// Convert modifiers struct to a list of strings
fn modifiers_to_vec(mods: &platform::Modifiers) -> Vec<String> {
    let mut result = Vec::new();
    if mods.ctrl {
        result.push("Ctrl".to_string());
    }
    if mods.alt {
        result.push("Alt".to_string());
    }
    if mods.shift {
        result.push("Shift".to_string());
    }
    if mods.meta {
        result.push("Win".to_string());
    }
    result
}

#[tauri::command]
fn start_listener(app: AppHandle) -> Result<(), String> {
    if LISTENER_RUNNING.swap(true, Ordering::SeqCst) {
        return Ok(()); // Already running
    }

    let (kb_rx, mouse_rx) = platform::start_listener();

    // Spawn thread to forward keyboard events (all events)
    let app_kb = app.clone();
    thread::spawn(move || {
        while let Ok(event) = kb_rx.recv() {
            let hid_event = HidEvent::Keyboard {
                event_type: match event.event_type {
                    platform::KeyEventType::KeyDown => "keydown".to_string(),
                    platform::KeyEventType::KeyUp => "keyup".to_string(),
                },
                key_name: event.key_name,
                vk_code: event.vk_code,
                modifiers: modifiers_to_vec(&event.modifiers),
            };
            let _ = app_kb.emit("hid-event", hid_event);
        }
    });

    // Spawn thread to forward mouse events (all events)
    let app_mouse = app.clone();
    thread::spawn(move || {
        while let Ok(event) = mouse_rx.recv() {
            let event_type = match event.event_type {
                platform::MouseEventType::LeftButtonDown => "left-down".to_string(),
                platform::MouseEventType::LeftButtonUp => "left-up".to_string(),
                platform::MouseEventType::RightButtonDown => "right-down".to_string(),
                platform::MouseEventType::RightButtonUp => "right-up".to_string(),
                platform::MouseEventType::MiddleButtonDown => "middle-down".to_string(),
                platform::MouseEventType::MiddleButtonUp => "middle-up".to_string(),
                platform::MouseEventType::XButtonDown => "x-down".to_string(),
                platform::MouseEventType::XButtonUp => "x-up".to_string(),
                platform::MouseEventType::MouseMove => "move".to_string(),
                platform::MouseEventType::MouseWheel => "wheel".to_string(),
            };

            let hid_event = HidEvent::Mouse {
                event_type,
                x: event.x,
                y: event.y,
                modifiers: modifiers_to_vec(&event.modifiers),
            };
            let _ = app_mouse.emit("hid-event", hid_event);
        }
    });

    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![start_listener])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
