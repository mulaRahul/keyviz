#[derive(Default)]
pub struct AppState {
    pub listening: bool,
    pub pressed_keys: Vec<String>,
    pub toggle_shortcut: Vec<String>,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            listening: true,
            pressed_keys: vec![],
            toggle_shortcut: vec!["Shift".to_string(), "F10".to_string()],
        }
    }
}
