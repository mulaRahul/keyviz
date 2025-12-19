pub mod domain;
pub mod platform;
pub mod app;

use crate::app::commands::{
    set_click_through_command,
    start_listener_command,
    stop_listener_command,
};
use crate::app::AppState;
use std::sync::Mutex;
use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .manage(Mutex::new(AppState::default()))
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            {
                let handle = app.handle();
                if let Some(state) = app.try_state::<Mutex<AppState>>() {
                    if let Ok(mut state) = state.lock() {
                        let _ = state.apply_overlay(true);
                        let _ = state.start_listener(handle);
                    }
                }
            }

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
                                    if let Some(state) = app.try_state::<Mutex<AppState>>() {
                                        if let Ok(mut state) = state.lock() {
                                            if state.listener_running {
                                                let _ = state.stop_listener();
                                            } else {
                                                let _ = state.start_listener(app);
                                            }
                                        }
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
            start_listener_command,
            stop_listener_command,
            set_click_through_command,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
