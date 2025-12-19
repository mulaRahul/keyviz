#[cfg(target_os = "windows")]
pub mod windows;

#[cfg(target_os = "windows")]
pub use windows::*;

#[cfg(not(target_os = "windows"))]
pub fn apply_overlay(_click_through: bool, _hide_from_alt_tab: bool, _focusable: bool) -> Result<(), String> {
    Err("Window manager overlay is only supported on Windows right now".into())
}
