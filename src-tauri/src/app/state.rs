use serde::Deserialize;
use tauri::{image::Image, include_image, menu::MenuItem, Emitter, Wry};
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
            if let Some(value) = store.get("key_event_store") {
                // the value comes in as a String: "{\"state\": ...}"
                if let Some(json_str) = value.as_str() {
                    // parse the inner string
                    match serde_json::from_str::<KeyEventStore>(json_str) {
                        Ok(parsed) => {
                            toggle_shortcut = parsed.state.toggle_shortcut;
                        }
                        Err(e) => eprintln!("Failed to parse key event JSON: {}", e),
                    }
                }
            }

            if let Some(value) = store.get("preferences_store") {
                if let Some(json_str) = value.as_str() {
                    match serde_json::from_str::<PreferencesStore>(json_str) {
                        Ok(parsed) => {
                            language = normalize_language_code(&parsed.state.language).to_string();
                        }
                        Err(e) => eprintln!("Failed to parse preferences JSON: {}", e),
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

    pub fn set_tray_items(
        &mut self,
        toggle_item: MenuItem<Wry>,
        settings_item: MenuItem<Wry>,
        quit_item: MenuItem<Wry>,
    ) {
        self.toggle_menu_item = Some(toggle_item);
        self.settings_menu_item = Some(settings_item);
        self.quit_menu_item = Some(quit_item);
        self.apply_tray_labels();
    }

    pub fn set_language(&mut self, language: String) {
        self.language = normalize_language_code(&language).to_string();
        self.apply_tray_labels();
    }

    pub fn label_toggle(&self) -> &'static str {
        if self.listening {
            self.t("tray.stop")
        } else {
            self.t("tray.start")
        }
    }

    pub fn label_settings(&self) -> &'static str {
        self.t("tray.settings")
    }

    pub fn label_quit(&self) -> &'static str {
        self.t("tray.quit")
    }

    pub fn apply_tray_labels(&self) {
        if let Some(toggle) = &self.toggle_menu_item {
            let _ = toggle.set_text(self.label_toggle());
        }
        if let Some(settings) = &self.settings_menu_item {
            let _ = settings.set_text(self.label_settings());
        }
        if let Some(quit) = &self.quit_menu_item {
            let _ = quit.set_text(self.label_quit());
        }
    }

    fn t(&self, key: &str) -> &'static str {
        let is_zh_cn = self.language == "zh-CN";
        match key {
            "tray.start" => {
                if is_zh_cn {
                    "开始"
                } else {
                    "Start"
                }
            }
            "tray.stop" => {
                if is_zh_cn {
                    "停止"
                } else {
                    "Stop"
                }
            }
            "tray.settings" => {
                if is_zh_cn {
                    "设置"
                } else {
                    "Settings"
                }
            }
            "tray.quit" => {
                if is_zh_cn {
                    "退出"
                } else {
                    "Quit"
                }
            }
            _ => "Unknown",
        }
    }

    pub fn toggle_listener(&mut self, app: &tauri::AppHandle, toggle: &tauri::menu::MenuItem<Wry>) {
        self.listening = !self.listening;

        if self.listening {
            println!("Listening enabled");
            toggle.set_text(self.label_toggle()).unwrap();
            app.tray_by_id("keyviz-tray")
                .unwrap()
                .set_icon(Some(Image::from(include_image!("icons/tray.png"))))
                .unwrap();
        } else {
            println!("Listening disabled");
            toggle.set_text(self.label_toggle()).unwrap();
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

#[derive(Debug, Deserialize)]
struct PreferencesStore {
    pub state: PreferencesState,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PreferencesState {
    pub language: String,
}

fn normalize_language_code(language: &str) -> &'static str {
    match language {
        "zh-CN" => "zh-CN",
        _ => "en",
    }
}
