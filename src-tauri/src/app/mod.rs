use crate::platform::hid_listener::{start_listener, stop_listener, HidListenerHandles};
use crate::platform::window_manager::apply_overlay;
use crate::app::emitter::spawn_emitters;
use std::thread::JoinHandle;
use tauri::AppHandle;

pub mod emitter;
pub mod commands;

pub struct AppState {
    pub listener_thread_id: Option<u32>,
    pub listener_thread: Option<JoinHandle<()>>,
    pub emitter_threads: Vec<JoinHandle<()>>,
    pub listener_running: bool,
    pub click_through: bool,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            listener_thread_id: None,
            listener_thread: None,
            emitter_threads: Vec::new(),
            listener_running: false,
            click_through: true,
        }
    }
}

impl AppState {
    pub fn start_listener(&mut self, app: &AppHandle) -> Result<(), String> {
        if self.listener_running {
            return Ok(());
        }

        let HidListenerHandles {
            kb_rx,
            mouse_rx,
            thread_id,
            thread,
        } = start_listener()?;

        let (kb_handle, mouse_handle) = spawn_emitters(app, kb_rx, mouse_rx);

        self.listener_thread_id = Some(thread_id);
        self.listener_thread = Some(thread);
        self.emitter_threads = vec![kb_handle, mouse_handle];
        self.listener_running = true;

        Ok(())
    }

    pub fn stop_listener(&mut self) -> Result<(), String> {
        if !self.listener_running {
            return Ok(());
        }

        if let Some(thread_id) = self.listener_thread_id.take() {
            let _ = stop_listener(thread_id);
        }

        if let Some(handle) = self.listener_thread.take() {
            let _ = handle.join();
        }

        for handle in self.emitter_threads.drain(..) {
            let _ = handle.join();
        }

        self.listener_running = false;
        Ok(())
    }

    pub fn apply_overlay(&mut self, click_through: bool) -> Result<bool, String> {
        apply_overlay(click_through, true, false)?;
        self.click_through = click_through;
        Ok(click_through)
    }
}
