#[cfg(target_os = "windows")]
pub mod windows;

#[cfg(target_os = "windows")]
pub use windows::*;

#[cfg(not(target_os = "windows"))]
pub struct HidListenerHandles;

#[cfg(not(target_os = "windows"))]
pub fn start_listener() -> Result<HidListenerHandles, String> {
    Err("HID listener is only supported on Windows right now".into())
}

#[cfg(not(target_os = "windows"))]
pub fn stop_listener(_thread_id: u32) -> Result<(), String> {
    Err("HID listener is only supported on Windows right now".into())
}
