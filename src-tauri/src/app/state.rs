use serde::Deserialize;
use tauri::{image::Image, include_image, menu::MenuItem, AppHandle, Emitter, Manager, Wry};
use tauri_plugin_store::StoreExt;

#[derive(Default)]
pub struct AppState {
    pub listening: bool,
    pub pressed_keys: Vec<String>,
    pub toggle_shortcut: Vec<String>,

    pub monitor_name: Option<String>,
    pub monitor_scale: f64,
    pub monitor_position: (i32, i32),
    pub language: String,
    pub toggle_menu_item: Option<MenuItem<Wry>>,
    pub settings_menu_item: Option<MenuItem<Wry>>,
    pub quit_menu_item: Option<MenuItem<Wry>>,
}

impl AppState {
    pub fn new(app: &tauri::AppHandle) -> Self {
        let mut toggle_shortcut = vec!["Shift".to_string(), "F10".to_string()];
        let mut language = "en".to_string();

        // load saved config from store
        if let Ok(store) = app.store("store.json") {
            if let Some(value) = store.get("language_preference").and_then(|value| value.as_str().map(str::to_owned)) {
                if value == "en" || value == "fr" {
                    language = value;
                }
            }
            if let Some(value) = store.get("key_event_store") {
                // the value comes in as a String: "{\"state\": ...}"
                if let Some(json_str) = value.as_str() {
                    // parse the inner string
                    match serde_json::from_str::<KeyEventStore>(json_str) {
                        Ok(parsed) => {
                            toggle_shortcut = parsed.state.toggle_shortcut;
                        }
                        Err(e) => eprintln!("Failed to parse inner config JSON: {}", e),
                    }
                }
            }
        }

        Self {
            listening: true,
            pressed_keys: vec![],
            toggle_shortcut,
            monitor_name: None,
            monitor_scale: 1.0,
            monitor_position: (0, 0),
            language,
            toggle_menu_item: None,
            settings_menu_item: None,
            quit_menu_item: None,
        }
    }

    pub fn set_language(&mut self, app: &AppHandle, language: String) {
        self.language = if language == "fr" { "fr" } else { "en" }.to_string();
        let is_french = self.language == "fr";

        if let Some(item) = &self.toggle_menu_item {
            let text = match (is_french, self.listening) {
                (true, true) => "Arrêter",
                (true, false) => "Démarrer",
                (false, true) => "Stop",
                (false, false) => "Start",
            };
            item.set_text(text).unwrap_or(());
        }
        if let Some(item) = &self.settings_menu_item {
            item.set_text(if is_french { "Paramètres" } else { "Settings" }).unwrap_or(());
        }
        if let Some(item) = &self.quit_menu_item {
            item.set_text(if is_french { "Quitter" } else { "Quit" }).unwrap_or(());
        }
        if let Some(window) = app.get_webview_window("settings") {
            window
                .set_title(if is_french { "Keyviz - Paramètres" } else { "Keyviz - Settings" })
                .unwrap_or(());
        }
    }

    pub fn toggle_listener(&mut self, app: &tauri::AppHandle, toggle: &tauri::menu::MenuItem<Wry>) {
        self.listening = !self.listening;

        if self.listening {
            println!("🟢 Listening enabled");
            toggle.set_text(if self.language == "fr" { "Arrêter" } else { "Stop" }).unwrap();
            app.tray_by_id("keyviz-tray")
                .unwrap()
                .set_icon(Some(Image::from(include_image!("icons/tray.png"))))
                .unwrap();
        } else {
            println!("🔴 Listening disabled");
            toggle.set_text(if self.language == "fr" { "Démarrer" } else { "Start" }).unwrap();
            app.tray_by_id("keyviz-tray")
                .unwrap()
                .set_icon(Some(Image::from(include_image!("icons/tray-disabled.png"))))
                .unwrap();
        }

        app.emit_to("main", "listening-toggle", self.listening)
            .unwrap();
    }
}

#[derive(Debug, Deserialize)]
struct KeyEventStore {
    pub state: KeyEventState,
    // pub version: u32,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct KeyEventState {
    // pub drag_threshold: u32,
    // pub filter_hotkeys: bool,
    // pub ignore_modifiers: Vec<String>,
    // pub show_event_history: bool,
    // pub max_history: u32,
    // pub linger_duration_ms: u32,
    // pub show_mouse_events: bool,
    pub toggle_shortcut: Vec<String>,
}
