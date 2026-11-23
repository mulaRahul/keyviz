use std::sync::Mutex;

use tauri::{
    Manager, PhysicalPosition, PhysicalSize, WebviewUrl, WebviewWindow, WebviewWindowBuilder,
};

use crate::app::{monitors::MonitorRect, state::AppState};

/// Label prefix of the windows that draw mouse visuals on each monitor, e.g.
/// `overlay-0`. The index is the monitor's position in `available_monitors()`.
const OVERLAY_PREFIX: &str = "overlay-";
/// Label prefix of the windows that render keycaps on an additional display.
const KEYS_PREFIX: &str = "keys-";

pub fn config_window(window: &tauri::WebviewWindow) {
    window
        .set_always_on_top(true)
        .expect("Failed to set always on top");

    window
        .set_ignore_cursor_events(true)
        .expect("Failed to set ignore cursor events");

    #[cfg(target_os = "windows")]
    {
        windows_topmost::start(
            window
                .hwnd()
                .expect("Failed to get visualization window handle")
                .0 as isize,
        );
    }

    // macOS: a window that has never been sized cannot be positioned later on,
    // so start it on the primary monitor covering the whole screen.
    #[cfg(target_os = "macos")]
    if let Ok(Some(monitor)) = window.primary_monitor() {
        let position = monitor.position();
        let size = monitor.size();

        if let Err(err) = window.set_position(PhysicalPosition::new(position.x, position.y)) {
            eprintln!("failed to size the main window: {err}");
        }
        if let Err(err) = window.set_size(PhysicalSize::new(size.width, size.height)) {
            eprintln!("failed to size the main window: {err}");
        }
    }

    if let Err(err) = make_click_through(window) {
        eprintln!("failed to configure the main window: {err}");
    }

    window.show().expect("Failed to show window");
}

/// Creates, moves and closes the per-monitor overlay windows: one window per
/// monitor while mouse visuals are enabled, none while they are not.
///
/// Returns `false` when an overlay could not be created or placed, in which
/// case the caller falls back to drawing inside the main window.
pub fn sync_overlay_windows(app: &tauri::AppHandle) -> bool {
    let Some(state) = app.try_state::<Mutex<AppState>>() else {
        return false;
    };
    let (monitors, mouse_overlays, mouse_enabled, mouse_displays, key_displays, key_enabled) = {
        let state = state.lock().unwrap();
        (
            state.monitors.clone(),
            state.mouse_overlays,
            state.mouse_enabled,
            state.mouse_displays.clone(),
            state.key_displays.clone(),
            state.key_enabled,
        )
    };

    // The master switch wins over the per-display selection: when it is off,
    // no stage window is created at all.
    let mouse_enabled = mouse_overlays && mouse_enabled;

    // A display is selected when its name is in the list. `None` is "never
    // configured": mouse visuals then cover every display while the keycaps
    // stay on the main window. `Some(empty)` means the user cleared the list,
    // which must draw nothing at all.
    let selected = |rect: &MonitorRect, wanted: &Option<Vec<String>>| match wanted {
        Some(displays) => displays
            .iter()
            .any(|wanted| rect.name.as_ref() == Some(wanted)),
        None => true,
    };

    let mouse_selected: Vec<bool> = monitors
        .iter()
        .map(|rect| selected(rect, &mouse_displays))
        .collect();

    // The main window draws the keycaps of the first selected display, so that
    // one never needs a stage window of its own. With `None` the main window is
    // the only keycap surface, which is the default.
    let key_selected: Vec<bool> = monitors
        .iter()
        .enumerate()
        .map(|(index, rect)| {
            let Some(displays) = &key_displays else {
                return false;
            };
            if !key_enabled || displays.is_empty() {
                return false;
            }

            let is_main = displays
                .first()
                .map_or(index == 0, |name| rect.name.as_ref() == Some(name));

            !is_main
                && displays
                    .iter()
                    .any(|wanted| rect.name.as_ref() == Some(wanted))
        })
        .collect();

    // Close stages whose monitor is gone or no longer selected.
    for (label, window) in app.webview_windows() {
        if let Some(index) = overlay_index(&label) {
            if !mouse_enabled || index >= monitors.len() || !mouse_selected[index] {
                let _ = window.close();
            }
        } else if let Some(index) = keys_index(&label) {
            if index >= monitors.len() || !key_selected[index] {
                let _ = window.close();
            }
        }
    }

    let mut all_placed = true;

    if mouse_enabled {
        for (index, rect) in monitors.iter().enumerate() {
            if !mouse_selected[index] {
                continue;
            }

            let label = format!("{OVERLAY_PREFIX}{index}");
            if !ensure_stage_window(app, &label, "index.html#/overlay", rect) {
                all_placed = false;
            }
        }
    }

    let mut key_stages = Vec::new();

    for (index, rect) in monitors.iter().enumerate() {
        if !key_selected[index] {
            continue;
        }

        let label = format!("{KEYS_PREFIX}{index}");
        if ensure_stage_window(app, &label, "index.html#/keys", rect) {
            key_stages.push(index);
        } else {
            all_placed = false;
        }
    }

    {
        let mut state = state.lock().unwrap();
        state.key_stages = key_stages;
    }

    all_placed
}

/// Creates the window if needed, then moves it onto the monitor it belongs to.
fn ensure_stage_window(
    app: &tauri::AppHandle,
    label: &str,
    route: &str,
    rect: &MonitorRect,
) -> bool {
    let window = match app.get_webview_window(label) {
        Some(window) => window,
        None => match create_stage_window(app, label, route) {
            Ok(window) => window,
            Err(err) => {
                eprintln!("failed to create stage window {label}: {err}");
                return false;
            }
        },
    };

    if let Err(err) = place_overlay_window(&window, rect) {
        eprintln!("failed to place stage window {label}: {err}");
        return false;
    }

    true
}
/// Turns a window into part of the overlay: click-through, above every other
/// window, and following the user across macOS spaces.
fn make_click_through(window: &tauri::WebviewWindow) -> tauri::Result<()> {
    window.set_ignore_cursor_events(true)?;

    #[cfg(target_os = "windows")]
    {
        use windows::Win32::Foundation::HWND;
        use windows::Win32::UI::WindowsAndMessaging::{
            SetWindowPos, HWND_TOPMOST, SWP_NOMOVE, SWP_NOSIZE,
        };

        match window.hwnd() {
            Ok(handle) => {
                let hwnd = HWND(handle.0 as isize);
                unsafe {
                    let _ =
                        SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
                }
            }
            Err(err) => eprintln!("no HWND for {}: {err}", window.label()),
        }
    }
    #[cfg(target_os = "macos")]
    {
        use cocoa::appkit::{NSWindow, NSWindowCollectionBehavior};
        use cocoa::base::id;

        match window.ns_window() {
            Ok(ns_window) => unsafe {
                let ns_window = ns_window as id;
                ns_window.setLevel_(1000);

                ns_window.setCollectionBehavior_(
                    NSWindowCollectionBehavior::NSWindowCollectionBehaviorCanJoinAllSpaces,
                );
            },
            Err(err) => eprintln!("no NSWindow for {}: {err}", window.label()),
        }
    }

    Ok(())
}

fn create_stage_window(
    app: &tauri::AppHandle,
    label: &str,
    route: &str,
) -> tauri::Result<WebviewWindow> {
    let window = WebviewWindowBuilder::new(app, label, WebviewUrl::App(route.into()))
    .title("Keyviz Overlay")
    .decorations(false)
    .transparent(true)
    .always_on_top(true)
    .resizable(false)
    .focused(false)
    .focusable(false)
    .skip_taskbar(true)
    .shadow(false)
    .visible(false)
    .build()?;

    make_click_through(&window)?;

    Ok(window)
}

fn place_overlay_window(window: &WebviewWindow, rect: &MonitorRect) -> tauri::Result<()> {
    window.set_position(PhysicalPosition::new(rect.x, rect.y))?;
    window.set_size(PhysicalSize::new(rect.width, rect.height))?;
    window.show()?;

    Ok(())
}

/// Returns the index of an `overlay-{index}` window label, `None` for every
/// other window.
pub(crate) fn overlay_index(label: &str) -> Option<usize> {
    label.strip_prefix(OVERLAY_PREFIX)?.parse().ok()
}

/// Returns the index of a `keys-{index}` window label.
fn keys_index(label: &str) -> Option<usize> {
    label.strip_prefix(KEYS_PREFIX)?.parse().ok()
}

#[cfg(test)]
mod tests {
    use super::overlay_index;

    #[test]
    fn only_overlay_labels_are_recognised() {
        assert_eq!(overlay_index("overlay-0"), Some(0));
        assert_eq!(overlay_index("overlay-12"), Some(12));

        assert_eq!(overlay_index("main"), None);
        assert_eq!(overlay_index("settings"), None);
        assert_eq!(overlay_index("overlay-"), None);
        assert_eq!(overlay_index("overlay-abc"), None);
        assert_eq!(overlay_index("overlay-0-extra"), None);
    }
}
#[cfg(target_os = "windows")]
pub fn stop_keeping_on_top() {
    windows_topmost::stop();
}

#[cfg(target_os = "windows")]
mod windows_topmost {
    use std::cell::Cell;

    use windows::Win32::{
        Foundation::{HMODULE, HWND},
        UI::{
            Accessibility::{SetWinEventHook, UnhookWinEvent, HWINEVENTHOOK},
            WindowsAndMessaging::{
                SetWindowPos, EVENT_SYSTEM_FOREGROUND, HWND_TOPMOST, SWP_NOACTIVATE, SWP_NOMOVE,
                SWP_NOOWNERZORDER, SWP_NOSIZE, WINEVENT_OUTOFCONTEXT,
            },
        },
    };

    thread_local! {
        static OVERLAY: Cell<HWND> = Cell::new(HWND(0));
        static HOOK: Cell<HWINEVENTHOOK> = Cell::new(HWINEVENTHOOK(0));
    }

    fn raise_overlay(hwnd: HWND) -> windows::core::Result<()> {
        unsafe {
            SetWindowPos(
                hwnd,
                HWND_TOPMOST,
                0,
                0,
                0,
                0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOOWNERZORDER,
            )
            .ok()
        }
    }

    unsafe extern "system" fn on_foreground_changed(
        _hook: HWINEVENTHOOK,
        _event: u32,
        _hwnd: HWND,
        _object: i32,
        _child: i32,
        _thread: u32,
        _time: u32,
    ) {
        OVERLAY.with(|overlay| {
            let hwnd = overlay.get();
            if hwnd.0 != 0 {
                if let Err(error) = raise_overlay(hwnd) {
                    eprintln!("Failed to restore visualization window on top: {error}");
                }
            }
        });
    }

    pub fn start(hwnd: isize) {
        let hwnd = HWND(hwnd);
        raise_overlay(hwnd).expect("Failed to put visualization window on top");
        OVERLAY.with(|overlay| overlay.set(hwnd));

        // Out-of-context events are delivered on this thread's existing Tauri message loop.
        let hook = unsafe {
            SetWinEventHook(
                EVENT_SYSTEM_FOREGROUND,
                EVENT_SYSTEM_FOREGROUND,
                HMODULE(0),
                Some(on_foreground_changed),
                0,
                0,
                WINEVENT_OUTOFCONTEXT,
            )
        };
        assert_ne!(
            hook.0,
            0,
            "Failed to monitor foreground windows: {}",
            std::io::Error::last_os_error()
        );
        HOOK.with(|stored| stored.set(hook));
    }

    pub fn stop() {
        OVERLAY.with(|overlay| overlay.set(HWND(0)));
        HOOK.with(|stored| {
            let hook = stored.replace(HWINEVENTHOOK(0));
            if hook.0 != 0 && !unsafe { UnhookWinEvent(hook) }.as_bool() {
                eprintln!(
                    "Failed to stop monitoring foreground windows: {}",
                    std::io::Error::last_os_error()
                );
            }
        });
    }

    // #[cfg(test)]
    // mod tests {
    //     use super::*;
    //     use windows::{
    //         core::w,
    //         Win32::UI::WindowsAndMessaging::{
    //             CreateWindowExW, DestroyWindow, GetForegroundWindow, GetWindow, GW_HWNDNEXT,
    //             WINDOW_EX_STYLE, WS_POPUP,
    //         },
    //     };

    //     struct TestWindow(HWND);

    //     impl TestWindow {
    //         fn new() -> Self {
    //             let hwnd = unsafe {
    //                 CreateWindowExW(
    //                     WINDOW_EX_STYLE(0),
    //                     w!("STATIC"),
    //                     w!(""),
    //                     WS_POPUP,
    //                     0,
    //                     0,
    //                     1,
    //                     1,
    //                     HWND(0),
    //                     None,
    //                     HMODULE(0),
    //                     None,
    //                 )
    //             };
    //             assert_ne!(hwnd.0, 0, "Failed to create test window");
    //             Self(hwnd)
    //         }
    //     }

    //     impl Drop for TestWindow {
    //         fn drop(&mut self) {
    //             unsafe { DestroyWindow(self.0) }.ok().unwrap();
    //         }
    //     }

    //     fn is_above(first: HWND, second: HWND) -> bool {
    //         let mut current = first;
    //         while current.0 != 0 {
    //             if current == second {
    //                 return true;
    //             }
    //             current = unsafe { GetWindow(current, GW_HWNDNEXT) };
    //         }
    //         false
    //     }

    //     #[test]
    //     fn foreground_change_restores_topmost_without_activation() {
    //         let overlay = TestWindow::new();
    //         let other = TestWindow::new();
    //         let overlay_hwnd = overlay.0;
    //         start(overlay_hwnd.0);
    //         raise_overlay(other.0).unwrap();
    //         assert!(is_above(other.0, overlay.0));

    //         unsafe {
    //             on_foreground_changed(
    //                 HWINEVENTHOOK(0),
    //                 EVENT_SYSTEM_FOREGROUND,
    //                 other.0,
    //                 0,
    //                 0,
    //                 0,
    //                 0,
    //             );
    //         }
    //         assert!(is_above(overlay.0, other.0));
    //         assert_ne!(unsafe { GetForegroundWindow() }, overlay.0);

    //         stop();
    //         HOOK.with(|hook| assert_eq!(hook.get().0, 0));
    //         OVERLAY.with(|window| assert_eq!(window.get(), HWND(0)));

    //         raise_overlay(other.0).unwrap();
    //         unsafe {
    //             on_foreground_changed(
    //                 HWINEVENTHOOK(0),
    //                 EVENT_SYSTEM_FOREGROUND,
    //                 other.0,
    //                 0,
    //                 0,
    //                 0,
    //                 0,
    //             );
    //         }
    //         assert!(is_above(other.0, overlay.0));
    //     }
    // }
}
