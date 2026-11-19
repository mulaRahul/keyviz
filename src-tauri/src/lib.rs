use std::sync::Mutex;

use tauri::{
    image::Image,
    include_image,
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    Emitter, Manager, WebviewWindowBuilder,
};

mod app;
use app::browser_source::BrowserSource;
use app::commands::{
    browser_source_port, browser_source_start, browser_source_stop, browser_source_update, log,
    resync_mouse_pointer, set_key_displays, set_locale, set_main_window_monitor, set_mouse_displays,
    set_mouse_overlay_enabled, set_toggle_shortcut,
};
use app::event::start_listener;
use app::state::{tray_labels, AppState, TrayMenuItems};
use app::window::{config_window, sync_overlay_windows};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_single_instance::init(|_, __, ___| {}))
        .plugin(tauri_plugin_prevent_default::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_store::Builder::new().build())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            // prepare window
            if let Some(window) = app.get_webview_window("main") {
                config_window(&window);
            }

            let app_handle = app.handle();
            let mut app_state = AppState::new(&app_handle);
            let labels = tray_labels(&app_state.locale);

            // tray actions
            let toggle_item = MenuItem::with_id(app, "toggle", labels.stop, true, None::<&str>)?;
            let settings_item =
                MenuItem::with_id(app, "settings", labels.settings, true, None::<&str>)?;
            let quit_item = MenuItem::with_id(app, "quit", labels.quit, true, None::<&str>)?;

            app_state.tray_menu_items = Some(TrayMenuItems {
                toggle: toggle_item.clone(),
                settings: settings_item.clone(),
                quit: quit_item.clone(),
            });
            app.manage(Mutex::new(app_state));

            // local page for OBS Browser Source, started on demand
            app.manage(Mutex::new(BrowserSource::default()));

            // Cache the monitor layout before the input listener starts, so the
            // first mouse event can already be routed to the right display.
            {
                let state = app_handle.state::<Mutex<AppState>>();
                state.lock().unwrap().refresh_monitors(app_handle);
            }

            // Displays can be plugged in, unplugged or rescaled while the app
            // runs, and not every platform reports that as a window event.
            // Re-reading the layout is cheap, so poll it while stage windows are
            // needed and only rebuild when something actually changed.
            let monitor_watcher = app_handle.clone();
            std::thread::spawn(move || loop {
                std::thread::sleep(std::time::Duration::from_secs(2));

                let (enabled, changed) = {
                    let Some(state) = monitor_watcher.try_state::<Mutex<AppState>>() else {
                        return;
                    };
                    let mut state = state.lock().unwrap();
                    let enabled = state.mouse_overlays
                        || state
                            .key_displays
                            .as_ref()
                            .is_some_and(|displays| !displays.is_empty());

                    (enabled, enabled && state.refresh_monitors(&monitor_watcher))
                };

                if enabled && changed {
                    let _ = sync_overlay_windows(&monitor_watcher);
                }
            });

            // start global input listener
            start_listener(app_handle.clone(), toggle_item.clone());

            // setup tray menu
            let menu = Menu::with_items(app, &[&toggle_item, &settings_item, &quit_item])?;
            let _ = TrayIconBuilder::with_id("keyviz-tray")
                .icon(Image::from(include_image!("icons/tray.png")))
                .menu(&menu)
                .show_menu_on_left_click(true)
                .on_menu_event(move |app, event| match event.id.as_ref() {
                    "toggle" => {
                        let state = app.state::<Mutex<AppState>>();
                        let mut app_state = state.lock().unwrap();
                        app_state.toggle_listener(app, &toggle_item);
                    }
                    "settings" => {
                        if let Some(window) = app.get_webview_window("settings") {
                            let _ = window.set_focus();
                            return;
                        }
                        let webview_url = tauri::WebviewUrl::App("index.html#/settings".into());
                        WebviewWindowBuilder::new(app, "settings", webview_url.clone())
                            .title("Keyviz")
                            .always_on_top(true)
                            .inner_size(800.0, 640.0)
                            .min_inner_size(640.0, 480.0)
                            .max_inner_size(1000.0, 800.0)
                            .maximizable(false)
                            .build()
                            .unwrap();

                        app.emit_to("main", "settings-window", true).unwrap();
                    }
                    "quit" => std::process::exit(0),
                    _ => println!("um... what?"),
                })
                .build(app);

            Ok(())
        })
        .on_window_event(|window, event| {
            if window.label() != "settings" {
                return;
            }
            match event {
                tauri::WindowEvent::CloseRequested { .. } => {
                    window
                        .app_handle()
                        .emit_to("main", "settings-window", false)
                        .unwrap();
                }
                _ => {}
            }
        })
        .invoke_handler(tauri::generate_handler![
            log,
            set_locale,
            set_toggle_shortcut,
            set_main_window_monitor,
            set_key_displays,
            set_mouse_displays,
            set_mouse_overlay_enabled,
            resync_mouse_pointer,
            browser_source_start,
            browser_source_stop,
            browser_source_update,
            browser_source_port
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
