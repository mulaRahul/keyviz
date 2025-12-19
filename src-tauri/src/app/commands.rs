use crate::app::AppState;
use std::sync::Mutex;
use tauri::{AppHandle, State};

#[tauri::command]
pub fn start_listener_command(app: AppHandle, state: State<'_, Mutex<AppState>>) -> Result<(), String> {
    let mut state = state.lock().map_err(|_| "state poisoned".to_string())?;
    state.start_listener(&app)
}

#[tauri::command]
pub fn stop_listener_command(state: State<'_, Mutex<AppState>>) -> Result<(), String> {
    let mut state = state.lock().map_err(|_| "state poisoned".to_string())?;
    state.stop_listener()
}

#[tauri::command]
pub fn set_click_through_command(
    _app: AppHandle,
    state: State<'_, Mutex<AppState>>,
    enabled: bool,
) -> Result<bool, String> {
    let mut state = state.lock().map_err(|_| "state poisoned".to_string())?;
    state.apply_overlay(enabled)
}