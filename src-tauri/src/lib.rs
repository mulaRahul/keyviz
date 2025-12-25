use std::sync::Mutex;

use tauri::{
    image::Image,
    include_image,
    menu::{Menu, MenuItem},
    tray::TrayIconBuilder,
    Manager,
};

mod app;
use app::commands::{log, set_toggle_shortcut};
use app::event::start_listener;
use app::state::AppState;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let app_handle = app.handle();

            // manage app state
            app.manage(Mutex::new(AppState::new()));

            // tray actions
            let toggle_item = MenuItem::with_id(app, "toggle", "Stop", true, None::<&str>)?;
            let settings_item = MenuItem::with_id(app, "settings", "Settings", true, None::<&str>)?;
            let quit_item = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

            // start global input listener
            start_listener(app_handle.clone(), toggle_item.clone());

            // setup tray menu
            let tray_icon = Image::from(include_image!("icons/tray.png"));
            let menu = Menu::with_items(app, &[&toggle_item, &settings_item, &quit_item])?;
            let _ = TrayIconBuilder::with_id("keyviz-tray")
                .icon(tray_icon.clone())
                .menu(&menu)
                .show_menu_on_left_click(true)
                .on_menu_event(move |app, event| match event.id.as_ref() {
                    "toggle" => {
                        let state = app.state::<Mutex<AppState>>();
                        let mut app_state = state.lock().unwrap();

                        app_state.listening = !app_state.listening;

                        if app_state.listening {
                            println!("🟢 Listening enabled via tray menu.");
                            toggle_item.set_text("Stop").unwrap();
                            app.tray_by_id("keyviz-tray")
                                .unwrap()
                                .set_icon(Some(tray_icon.clone()))
                                .unwrap();
                        } else {
                            println!("🔴 Listening disabled via tray menu.");
                            toggle_item.set_text("Start").unwrap();
                            app.tray_by_id("keyviz-tray")
                                .unwrap()
                                .set_icon(Some(Image::from(include_image!(
                                    "icons/tray-disabled.png"
                                ))))
                                .unwrap();
                        }
                    }
                    "settings" => {}
                    "quit" => std::process::exit(0),
                    _ => println!("um... what?"),
                })
                .build(app);

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![log, set_toggle_shortcut])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
