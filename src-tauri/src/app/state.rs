use serde::Deserialize;
use tauri::{image::Image, include_image, menu::MenuItem, AppHandle, Emitter, Wry};
use tauri_plugin_store::StoreExt;

use crate::app::monitors::MonitorRect;

pub const SUPPORTED_LOCALES: [&str; 4] = ["en-US", "zh-CN", "fr-FR", "es-ES"];

#[derive(Clone)]
pub struct TrayMenuItems {
    pub toggle: MenuItem<Wry>,
    pub settings: MenuItem<Wry>,
    pub quit: MenuItem<Wry>,
}

/// Reserved display name for the OBS browser-source output. The frontend adds
/// it to the keycap display list; it never maps to a real monitor.
pub const BROWSER_DISPLAY: &str = "__browser__";

#[derive(Default)]
pub struct AppState {
    pub listening: bool,
    pub pressed_keys: Vec<String>,
    pub toggle_shortcut: Vec<String>,
    pub locale: String,
    pub tray_menu_items: Option<TrayMenuItems>,

    pub monitor_name: Option<String>,
    pub monitor_scale: f64,
    pub monitor_position: (i32, i32),

    /// Physical rectangle of every monitor, in `available_monitors()` order.
    /// Kept in state so the input listener can route an event to the right
    /// overlay window without querying the window system on every mouse move.
    pub monitors: Vec<MonitorRect>,
    /// Whether mouse visuals are drawn by one click-through window per monitor
    /// (as opposed to the single main window).
    pub mouse_overlays: bool,
    /// Display names the user wants mouse visuals on. `None` means the setting
    /// was never touched (default: every display); `Some` empty means none.
    pub mouse_displays: Option<Vec<String>>,
    /// Display names the user wants keycaps on. `None` means the setting was
    /// never touched (default: the main window on the primary display);
    /// `Some` empty means nothing is drawn.
    pub key_displays: Option<Vec<String>>,
    /// Master switch for the keycaps. When false no window draws them, but the
    /// `key_displays` selection is kept for when it is turned back on.
    pub key_enabled: bool,
    /// Master switch for the mouse visuals, same contract as `key_enabled`.
    pub mouse_enabled: bool,
    /// Monitor indices that currently have their own keycap window, i.e. every
    /// selected key display except the one the main window covers.
    pub key_stages: Vec<usize>,
    /// Last known cursor position in global physical pixels. Button and wheel
    /// events carry no coordinates of their own.
    pub pointer: (f64, f64),
}

impl AppState {
    pub fn new(app: &tauri::AppHandle) -> Self {
        let mut toggle_shortcut = vec!["Shift".to_string(), "F10".to_string()];
        let mut locale = system_locale().unwrap_or_else(|| "en-US".to_string());

        // load saved config from store
        if let Ok(store) = app.store("store.json") {
            if let Some(saved_locale) = store
                .get("language")
                .and_then(|value| value.as_str().map(str::to_owned))
            {
                locale = if SUPPORTED_LOCALES.contains(&saved_locale.as_str()) {
                    saved_locale
                } else {
                    "en-US".to_string()
                };
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
            locale,
            tray_menu_items: None,
            monitor_name: None,
            monitor_scale: 1.0,
            monitor_position: (0, 0),
            monitors: vec![],
            mouse_overlays: false,
            mouse_displays: None,
            key_displays: None,
            key_enabled: true,
            mouse_enabled: true,
            key_stages: vec![],
            pointer: (0.0, 0.0),
        }
    }

    pub fn set_locale(&mut self, app: &tauri::AppHandle, locale: &str) -> Result<(), String> {
        if !SUPPORTED_LOCALES.contains(&locale) {
            return Err(format!("Unsupported locale: {locale}"));
        }

        let store = app
            .store("store.json")
            .map_err(|error| format!("Failed to load settings store: {error}"))?;
        store.set("language", locale);
        store
            .save()
            .map_err(|error| format!("Failed to save language preference: {error}"))?;

        self.locale = locale.to_string();
        if let Some(items) = &self.tray_menu_items {
            let labels = tray_labels(locale);
            items
                .toggle
                .set_text(if self.listening {
                    labels.stop
                } else {
                    labels.start
                })
                .map_err(|error| format!("Failed to update tray toggle label: {error}"))?;
            items
                .settings
                .set_text(labels.settings)
                .map_err(|error| format!("Failed to update tray settings label: {error}"))?;
            items
                .quit
                .set_text(labels.quit)
                .map_err(|error| format!("Failed to update tray quit label: {error}"))?;
        }

        Ok(())
    }

    /// Re-reads the monitor layout, returning `true` when it changed.
    ///
    /// Displays can be plugged in, unplugged, moved or rescaled while the app
    /// runs; the cached rectangles are what mouse events are routed with, so
    /// they have to stay in sync with the window system.
    pub fn refresh_monitors(&mut self, app: &AppHandle) -> bool {
        let monitors: Vec<MonitorRect> = app
            .available_monitors()
            .unwrap_or_default()
            .iter()
            .map(|monitor| {
                let position = monitor.position();
                let size = monitor.size();

                MonitorRect::new(
                    position.x,
                    position.y,
                    size.width,
                    size.height,
                    monitor.scale_factor(),
                )
                .with_name(monitor.name().cloned())
            })
            .collect();

        let changed = monitors != self.monitors;
        self.monitors = monitors;

        changed
    }

    pub fn toggle_listener(&mut self, app: &tauri::AppHandle, toggle: &tauri::menu::MenuItem<Wry>) {
        self.listening = !self.listening;
        let labels = tray_labels(&self.locale);

        if self.listening {
            println!("🟢 Listening enabled");
            toggle.set_text(labels.stop).unwrap();
            app.tray_by_id("keyviz-tray")
                .unwrap()
                .set_icon(Some(Image::from(include_image!("icons/tray.png"))))
                .unwrap();
        } else {
            println!("🔴 Listening disabled");
            toggle.set_text(labels.start).unwrap();
            app.tray_by_id("keyviz-tray")
                .unwrap()
                .set_icon(Some(Image::from(include_image!("icons/tray-disabled.png"))))
                .unwrap();
        }

        app.emit_to("main", "listening-toggle", self.listening)
            .unwrap();
    }
}

fn system_locale() -> Option<String> {
    let locale = tauri_plugin_os::locale()?;
    let language = locale
        .split(|character| character == '-' || character == '_')
        .next()?;

    SUPPORTED_LOCALES
        .iter()
        .find(|supported| {
            supported
                .split('-')
                .next()
                .map(|supported_language| supported_language.eq_ignore_ascii_case(language))
                .unwrap_or(false)
        })
        .map(|supported| (*supported).to_string())
}

pub struct TrayLabels {
    pub start: &'static str,
    pub stop: &'static str,
    pub settings: &'static str,
    pub quit: &'static str,
}

pub fn tray_labels(locale: &str) -> TrayLabels {
    match locale {
        "zh-CN" => TrayLabels {
            start: "开始",
            stop: "停止",
            settings: "设置",
            quit: "退出",
        },
        "fr-FR" => TrayLabels {
            start: "Démarrer",
            stop: "Arrêter",
            settings: "Paramètres",
            quit: "Quitter",
        },
        "es-ES" => TrayLabels {
            start: "Iniciar",
            stop: "Detener",
            settings: "Configuración",
            quit: "Salir",
        },
        _ => TrayLabels {
            start: "Start",
            stop: "Stop",
            settings: "Settings",
            quit: "Quit",
        },
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
