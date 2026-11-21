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
    #[cfg(target_os = "macos")]
    {
        if let Ok(Some(monitor)) = window.primary_monitor() {
            let position = monitor.position();
            let size = monitor.size();

            window
                .set_position(tauri::PhysicalPosition {
                    x: position.x,
                    y: position.y,
                })
                .unwrap();
            window
                .set_size(tauri::PhysicalSize {
                    width: size.width,
                    height: size.height,
                })
                .unwrap();
        }

        use cocoa::appkit::{NSWindow, NSWindowCollectionBehavior};
        use cocoa::base::id;

        unsafe {
            let ns_window = window.ns_window().unwrap() as id;
            ns_window.setLevel_(1000);

            ns_window.setCollectionBehavior_(
                NSWindowCollectionBehavior::NSWindowCollectionBehaviorCanJoinAllSpaces,
            );
        }
    }

    window.show().expect("Failed to show window");
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
