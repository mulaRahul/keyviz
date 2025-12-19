use crate::domain::event::{HidEvent, KeyboardEvent, MouseEvent};
use std::sync::mpsc::Receiver;
use std::thread::{self, JoinHandle};
use tauri::{AppHandle, Emitter};

pub fn spawn_emitters(
    app: &AppHandle,
    kb_rx: Receiver<KeyboardEvent>,
    mouse_rx: Receiver<MouseEvent>,
) -> (JoinHandle<()>, JoinHandle<()>) {
    let app_kb = app.clone();
    let kb_handle = thread::spawn(move || {
        while let Ok(event) = kb_rx.recv() {
            let hid_event: HidEvent = event.into();
            let _ = app_kb.emit("hid-event", hid_event);
        }
    });

    let app_mouse = app.clone();
    let mouse_handle = thread::spawn(move || {
        while let Ok(event) = mouse_rx.recv() {
            let hid_event: HidEvent = event.into();
            let _ = app_mouse.emit("hid-event", hid_event);
        }
    });

    (kb_handle, mouse_handle)
}
