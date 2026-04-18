use std::sync::Mutex;

use tauri::{Manager, PhysicalPosition, PhysicalSize};

use crate::app::state::AppState;

#[tauri::command]
pub fn resize_overlay_window(app: tauri::AppHandle, x: f64, y: f64, width: f64, height: f64) {
    let state = app.state::<Mutex<AppState>>();
    let app_state = state.lock().unwrap();

    let scale = app_state.monitor_scale;
    let (mon_x, mon_y) = app_state.monitor_position;

    if let Some(window) = app.get_webview_window("main") {
        let phys_x = mon_x + (x * scale) as i32;
        let phys_y = mon_y + (y * scale) as i32;
        let phys_w = ((width * scale) as u32).max(1);
        let phys_h = ((height * scale) as u32).max(1);

        window
            .set_position(PhysicalPosition {
                x: phys_x,
                y: phys_y,
            })
            .unwrap_or(());
        window
            .set_size(PhysicalSize {
                width: phys_w,
                height: phys_h,
            })
            .unwrap_or(());
    }
}

#[tauri::command]
pub fn set_mouse_overlay_size(app: tauri::AppHandle, size: u32) {
    let state = app.state::<Mutex<AppState>>();
    let scale = {
        let mut app_state = state.lock().unwrap();
        app_state.mouse_overlay_size = size;
        app_state.monitor_scale
    };

    if let Some(mouse_window) = app.get_webview_window("mouse-overlay") {
        let phys = ((size as f64 * scale) as u32).max(1);
        mouse_window
            .set_size(PhysicalSize {
                width: phys,
                height: phys,
            })
            .unwrap_or(());
    }
}

#[tauri::command]
pub fn log(message: String) {
    println!("[LOG] {}", message);
}

#[tauri::command]
pub fn set_toggle_shortcut(app: tauri::AppHandle, shortcut: Vec<String>) {
    let state = app.state::<Mutex<AppState>>();
    let mut app_state = state.lock().unwrap();
    app_state.toggle_shortcut = shortcut;
}

#[tauri::command]
pub fn set_main_window_monitor(app: tauri::AppHandle, monitor_name: String) {
    let state = app.state::<Mutex<AppState>>();
    let mut app_state = state.lock().unwrap();

    if app_state.monitor_name == Some(monitor_name.clone()) {
        return;
    }

    if let Some(window) = app.get_webview_window("main") {
        let monitors = window.available_monitors().unwrap_or_default();
        let target_monitor = monitors.iter().find(|m| m.name() == Some(&monitor_name));

        if let Some(monitor) = target_monitor {
            let position = monitor.position();
            let scale = monitor.scale_factor();

            // Update AppState so resize_overlay_window uses the new monitor's offset/scale
            app_state.monitor_name = Some(monitor_name.clone());
            app_state.monitor_scale = scale;
            app_state.monitor_position = (position.x, position.y);

            // Drop the lock before touching windows
            drop(app_state);

            // Move the key-overlay window to the new monitor origin at minimal size.
            // The JS ResizeObserver will call resize_overlay_window to correct the bounds.
            // The mouse-overlay window is positioned by the rdev event loop and needs no move here.
            if let Some(main_window) = app.get_webview_window("main") {
                main_window
                    .set_position(PhysicalPosition {
                        x: position.x,
                        y: position.y,
                    })
                    .unwrap_or(());
                main_window
                    .set_size(PhysicalSize { width: 1, height: 1 })
                    .unwrap_or(());
            }
        }
    }
}
