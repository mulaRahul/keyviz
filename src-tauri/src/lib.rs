mod platform;

use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread;
use tauri::{AppHandle, Emitter};

static LISTENER_RUNNING: AtomicBool = AtomicBool::new(false);
static CLICK_THROUGH_ENABLED: AtomicBool = AtomicBool::new(true);

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

#[cfg(target_os = "windows")]
fn configure_overlay_impl(
    click_through: bool,
    hide_from_alt_tab: bool,
    focusable: bool,
) -> Result<(), String> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;
    use windows_sys::Win32::Foundation::HWND;
    use windows_sys::Win32::UI::WindowsAndMessaging::{
        FindWindowW, GetWindowLongPtrW, SetLayeredWindowAttributes, SetWindowLongPtrW, SetWindowPos,
        GWL_EXSTYLE, HWND_TOPMOST, LWA_ALPHA, SWP_NOMOVE, SWP_NOSIZE, WS_EX_LAYERED, WS_EX_NOACTIVATE,
        WS_EX_TOOLWINDOW, WS_EX_TRANSPARENT,
    };

    // Find the window by the configured title from tauri.conf.json
    let title = OsStr::new("keyviz")
        .encode_wide()
        .chain(std::iter::once(0))
        .collect::<Vec<u16>>();

    let hwnd: HWND = unsafe { FindWindowW(std::ptr::null::<u16>(), title.as_ptr()) };
    if hwnd.is_null() {
        return Err("unable to find window handle".into());
    }

    unsafe {
        let mut ex = GetWindowLongPtrW(hwnd, GWL_EXSTYLE) as u32;
        ex |= WS_EX_LAYERED;

        if click_through {
            ex |= WS_EX_TRANSPARENT;
        } else {
            ex &= !WS_EX_TRANSPARENT;
        }

        if hide_from_alt_tab {
            ex |= WS_EX_TOOLWINDOW;
        } else {
            ex &= !WS_EX_TOOLWINDOW;
        }

        if !focusable {
            ex |= WS_EX_NOACTIVATE;
        } else {
            ex &= !WS_EX_NOACTIVATE;
        }

        SetWindowLongPtrW(hwnd, GWL_EXSTYLE, ex as isize);
        // Keep opaque pixels; transparency is provided by the webview background
        SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA);
        // Reassert topmost after style change
        SetWindowPos(
            hwnd,
            HWND_TOPMOST,
            0,
            0,
            0,
            0,
            SWP_NOMOVE | SWP_NOSIZE,
        );
    }

    Ok(())
}

#[tauri::command]
fn configure_overlay(
    _app: AppHandle,
    click_through: bool,
    hide_from_alt_tab: bool,
    focusable: bool,
) -> Result<(), String> {
    #[cfg(target_os = "windows")]
    {
        return configure_overlay_impl(click_through, hide_from_alt_tab, focusable);
    }

    #[allow(unreachable_code)]
    Err("configure_overlay is only available on Windows".into())
}

#[tauri::command]
fn toggle_click_through(_app: AppHandle) -> Result<bool, String> {
    let new_state = !CLICK_THROUGH_ENABLED.load(Ordering::SeqCst);
    CLICK_THROUGH_ENABLED.store(new_state, Ordering::SeqCst);
    
    #[cfg(target_os = "windows")]
    {
        configure_overlay_impl(new_state, true, false)?;
    }
    
    Ok(new_state)
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
        .setup(|app| {
            #[cfg(target_os = "windows")]
            {
                let _ = configure_overlay_impl(true, true, false);
            }
            // Fire up the listener on startup
            let _ = start_listener(app.handle().clone());

            // Create system tray
            use tauri::menu::{MenuBuilder, MenuItemBuilder};
            use tauri::tray::TrayIconBuilder;

            if let (Ok(toggle_item), Ok(quit_item)) = (
                MenuItemBuilder::new("Toggle Listener")
                    .id("toggle_listener")
                    .build(app),
                MenuItemBuilder::new("Quit")
                    .id("quit")
                    .build(app),
            ) {
                let menu = MenuBuilder::new(app)
                    .items(&[&toggle_item, &quit_item])
                    .build();

                if let Ok(menu) = menu {
                    let _tray = TrayIconBuilder::new()
                        .menu(&menu)
                        .on_menu_event(|app, event| {
                            match event.id.as_ref() {
                                "quit" => {
                                    app.exit(0);
                                }
                                "toggle_listener" => {
                                    let enabled = !CLICK_THROUGH_ENABLED.load(Ordering::SeqCst);
                                    CLICK_THROUGH_ENABLED.store(enabled, Ordering::SeqCst);
                                    
                                    #[cfg(target_os = "windows")]
                                    {
                                        let _ = configure_overlay_impl(enabled, true, false);
                                    }
                                }
                                _ => {}
                            }
                        })
                        .build(app);
                }
            }

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            start_listener,
            configure_overlay,
            toggle_click_through
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
