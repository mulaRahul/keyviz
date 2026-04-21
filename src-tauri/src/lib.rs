use std::sync::Mutex;

#[cfg(target_os = "macos")]
use tauri::ActivationPolicy;
use tauri::{
    image::Image,
    include_image,
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    AppHandle, Emitter, Manager, WebviewUrl, WebviewWindow, WebviewWindowBuilder,
};

mod app;
use app::commands::{log, set_main_window_monitor, set_toggle_shortcut};
use app::event::start_listener;
use app::state::AppState;
use app::window::config_window;

#[cfg(target_os = "macos")]
fn set_settings_switcher_visibility(app: &AppHandle, visible: bool) {
    let activation_policy = if visible {
        ActivationPolicy::Regular
    } else {
        ActivationPolicy::Accessory
    };

    if let Err(err) = app.set_activation_policy(activation_policy) {
        eprintln!("Failed to set activation policy: {err}");
    }

    if let Err(err) = app.set_dock_visibility(visible) {
        eprintln!("Failed to set dock visibility: {err}");
    }
}

#[cfg(not(target_os = "macos"))]
fn set_settings_switcher_visibility(_app: &AppHandle, _visible: bool) {}

fn emit_settings_window_state(app: &AppHandle, visible: bool) {
    let _ = app.emit_to("main", "settings-window", visible);
}

fn build_settings_window(app: &AppHandle) -> tauri::Result<WebviewWindow> {
    let webview_url = WebviewUrl::App("index.html#/settings".into());

    WebviewWindowBuilder::new(app, "settings", webview_url)
        .title("Keyviz")
        .inner_size(800.0, 640.0)
        .min_inner_size(640.0, 480.0)
        .max_inner_size(1000.0, 800.0)
        .maximizable(false)
        .build()
}

fn show_settings_window(app: &AppHandle) {
    set_settings_switcher_visibility(app, true);

    #[cfg(target_os = "macos")]
    let _ = app.show();

    let window = match app.get_webview_window("settings") {
        Some(window) => window,
        None => match build_settings_window(app) {
            Ok(window) => window,
            Err(err) => {
                eprintln!("Failed to create settings window: {err}");
                set_settings_switcher_visibility(app, false);

                #[cfg(target_os = "macos")]
                let _ = app.hide();

                return;
            }
        },
    };

    let _ = window.unminimize();
    let _ = window.show();
    let _ = window.set_focus();
    emit_settings_window_state(app, true);
}

fn hide_settings_window(app: &AppHandle) {
    if let Some(window) = app.get_webview_window("settings") {
        let _ = window.hide();
    }

    emit_settings_window_state(app, false);
    set_settings_switcher_visibility(app, false);

    #[cfg(target_os = "macos")]
    let _ = app.hide();
}

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
            // manage app state
            app.manage(Mutex::new(AppState::new(&app_handle)));

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
                    "settings" => show_settings_window(app),
                    "quit" => std::process::exit(0),
                    _ => println!("um... what?"),
                })
                .build(app);

            set_settings_switcher_visibility(&app_handle, false);

            #[cfg(target_os = "macos")]
            let _ = app_handle.hide();

            Ok(())
        })
        .on_window_event(|window, event| {
            if window.label() != "settings" {
                return;
            }

            if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                api.prevent_close();
                hide_settings_window(&window.app_handle());
            }
        })
        .invoke_handler(tauri::generate_handler![
            log,
            set_toggle_shortcut,
            set_main_window_monitor
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
