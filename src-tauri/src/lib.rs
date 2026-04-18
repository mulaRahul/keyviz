use std::sync::Mutex;

use tauri::{
    image::Image,
    include_image,
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    Emitter, Manager, WebviewWindowBuilder,
};

mod app;
use app::commands::{log, resize_overlay_window, set_main_window_monitor, set_toggle_shortcut};
use app::event::start_listener;
use app::state::AppState;
use app::window::config_window;

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
            // prepare main (key overlay) window
            if let Some(window) = app.get_webview_window("main") {
                config_window(&window);
            }

            let app_handle = app.handle();

            // manage app state
            app.manage(Mutex::new(AppState::new(&app_handle)));

            // seed monitor scale from primary monitor so resize_overlay_window
            // works correctly on HiDPI screens before a monitor is explicitly set
            if let Some(window) = app.get_webview_window("main") {
                if let Ok(Some(monitor)) = window.primary_monitor() {
                    let state = app_handle.state::<Mutex<AppState>>();
                    let mut app_state = state.lock().unwrap();
                    if app_state.monitor_name.is_none() {
                        app_state.monitor_scale = monitor.scale_factor();
                        app_state.monitor_position =
                            (monitor.position().x, monitor.position().y);
                    }
                }
            }

            // tray actions
            let toggle_item = MenuItem::with_id(app, "toggle", "Stop", true, None::<&str>)?;
            let settings_item = MenuItem::with_id(app, "settings", "Settings", true, None::<&str>)?;
            let quit_item = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

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
            set_toggle_shortcut,
            set_main_window_monitor,
            resize_overlay_window
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
