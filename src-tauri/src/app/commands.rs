use std::sync::Mutex;

use tauri::{Emitter, Manager, PhysicalPosition, PhysicalSize};

use crate::app::{browser_source::BrowserSource, state::AppState, window::sync_overlay_windows};

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
pub fn set_locale(app: tauri::AppHandle, locale: String) -> Result<(), String> {
    let state = app.state::<Mutex<AppState>>();
    let mut app_state = state
        .lock()
        .map_err(|error| format!("Failed to access app state: {error}"))?;
    app_state.set_locale(&app, &locale)
}

#[tauri::command]
pub async fn set_main_window_monitor(app: tauri::AppHandle, monitor_name: String) {
    let state = app.state::<Mutex<AppState>>();

    {
        let mut app_state = state.lock().unwrap();

        // Displays can be rearranged or rescaled at any time, so refresh the
        // cached layout before matching the saved monitor by name.
        app_state.refresh_monitors(&app);

        if app_state.monitor_name == Some(monitor_name.clone()) {
            drop(app_state);
            let _ = sync_overlay_windows(&app);
            return;
        }

        if let Some(window) = app.get_webview_window("main") {
            let monitors = window.available_monitors().unwrap_or_default();
            let target_monitor = monitors.iter().find(|m| m.name() == Some(&monitor_name));

            if let Some(monitor) = target_monitor {
                let position = monitor.position();
                let size = monitor.size();
                let scale = monitor.scale_factor();

                // Update AppState
                app_state.monitor_name = Some(monitor_name.clone());
                app_state.monitor_scale = scale;
                app_state.monitor_position = (position.x, position.y);

                // Update window
                // a fullscreen window can't leave its monitor
                #[cfg(target_os = "windows")]
                window.set_fullscreen(false).unwrap_or(());
                window
                    .set_position(PhysicalPosition {
                        x: position.x,
                        y: position.y,
                    })
                    .unwrap_or(());
                window
                    .set_size(PhysicalSize {
                        width: size.width,
                        height: size.height,
                    })
                    .unwrap_or(());
                #[cfg(target_os = "windows")]
                window.set_fullscreen(true).unwrap_or(());
            }
        }
    }

    // The keycaps move with the main window, the mouse visuals live in the
    // per-monitor overlays and only need their geometry refreshed.
    let _ = sync_overlay_windows(&app);
}

/// Sends the current cursor position, in the coordinates of the calling
/// overlay window, so a freshly created window can place the mouse indicator
/// under the pointer instead of at the top-left corner until the first move.
#[tauri::command]
pub fn resync_mouse_pointer(app: tauri::AppHandle, window: tauri::WebviewWindow) {
    let Some(index) = crate::app::window::overlay_index(window.label()) else {
        return;
    };

    let state = app.state::<Mutex<AppState>>();
    let (pointer, monitors) = {
        let app_state = state.lock().unwrap();
        (app_state.pointer, app_state.monitors.clone())
    };

    let Some(rect) = monitors.get(index) else {
        return;
    };

    let (x, y) = rect.to_local(pointer.0, pointer.1);
    let _ = window.emit("input-event", crate::app::event::InputEvent::MouseMoveEvent { x, y });
}

/// Selects the displays that should draw mouse visuals, by monitor name.
/// `None` keeps the default (every display); an empty list draws none.
/// `enabled` is the master switch: when false nothing is drawn, whatever the
/// list says, but the list itself is preserved.
#[tauri::command]
pub async fn set_mouse_displays(
    app: tauri::AppHandle,
    displays: Option<Vec<String>>,
    enabled: bool,
) -> bool {
    {
        let state = app.state::<Mutex<AppState>>();
        let mut app_state = state.lock().unwrap();

        app_state.mouse_displays = displays;
        app_state.mouse_enabled = enabled;
        app_state.refresh_monitors(&app);
    }

    sync_overlay_windows(&app)
}

/// Stores the displays that should render keycaps and rebuilds their windows.
/// `None` keeps the default (the main window on the primary display).
/// `enabled` is the master switch, as in [`set_mouse_displays`].
#[tauri::command]
pub async fn set_key_displays(
    app: tauri::AppHandle,
    displays: Option<Vec<String>>,
    enabled: bool,
) -> bool {
    {
        let state = app.state::<Mutex<AppState>>();
        let mut app_state = state.lock().unwrap();

        // The browser source is an output, not a monitor: keep it out of the
        // window layout, the frontend starts the HTTP server for it.
        app_state.key_displays = displays.map(|displays| {
            displays
                .into_iter()
                .filter(|display| display != crate::app::state::BROWSER_DISPLAY)
                .collect()
        });
        app_state.key_enabled = enabled;
        app_state.refresh_monitors(&app);
    }

    sync_overlay_windows(&app)
}

/// Turns the per-monitor mouse overlay on or off and reports whether it ended
/// up active. The frontend calls this whenever a mouse visual is toggled or
/// the listener is stopped.
#[tauri::command]
pub async fn set_mouse_overlay_enabled(app: tauri::AppHandle, enabled: bool) -> bool {
    {
        let state = app.state::<Mutex<AppState>>();
        let mut app_state = state.lock().unwrap();

        app_state.mouse_overlays = enabled;
        app_state.refresh_monitors(&app);
    }

    let mut active = enabled && sync_overlay_windows(&app);

    if enabled && !active {
        // At least one monitor has no usable overlay window. Draw in the main
        // window instead, which is what every version before this one did.
        {
            let state = app.state::<Mutex<AppState>>();
            let mut app_state = state.lock().unwrap();
            app_state.mouse_overlays = false;
        }

        let _ = sync_overlay_windows(&app);
        active = false;
    }

    let _ = app.emit_to("main", "mouse-overlays", active);

    active
}

/// Starts the local page that OBS Browser Source can capture and returns its
/// port. Calling it while the server is already running is a no-op.
#[tauri::command]
pub fn browser_source_start(app: tauri::AppHandle, port: u16) -> Result<u16, String> {
    let source = app.state::<Mutex<BrowserSource>>();
    let mut source = source.lock().map_err(|err| err.to_string())?;
    source.start(app.clone(), port)
}

#[tauri::command]
pub fn browser_source_stop(app: tauri::AppHandle) -> bool {
    if let Ok(mut source) = app.state::<Mutex<BrowserSource>>().lock() {
        source.stop();
    }
    true
}

/// Receives the current visual state from the main window and forwards it to
/// every attached OBS browser source.
#[tauri::command]
pub fn browser_source_update(app: tauri::AppHandle, payload: String) -> bool {
    if let Ok(source) = app.state::<Mutex<BrowserSource>>().lock() {
        source.update(payload);
    }
    true
}

#[tauri::command]
pub fn browser_source_port(app: tauri::AppHandle) -> Option<u16> {
    app.state::<Mutex<BrowserSource>>()
        .lock()
        .ok()
        .and_then(|source| source.port())
}
