pub fn config_window(window: &tauri::WebviewWindow) {
    window
        .set_ignore_cursor_events(true)
        .expect("Failed to set ignore cursor events");

    let is_mouse_overlay = window.label() == "mouse-overlay";

    #[cfg(target_os = "windows")]
    {
        use windows::Win32::Foundation::{BOOL, HWND, LPARAM};
        use windows::Win32::UI::WindowsAndMessaging::{
            EnumChildWindows, GetWindowLongPtrW, SetWindowLongPtrW, SetWindowPos,
            GWL_EXSTYLE, HWND_TOPMOST, SWP_NOMOVE, SWP_NOSIZE,
            WS_EX_LAYERED, WS_EX_NOACTIVATE, WS_EX_TRANSPARENT,
        };

        let hwnd = HWND(window.hwnd().unwrap().0 as isize);
        unsafe {
            let _ = SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
        }

        if is_mouse_overlay {
            // WebView2 embeds child windows that don't inherit WS_EX_TRANSPARENT from the
            // parent. Window-picker tools (e.g. Cap) hit-test against those children and
            // report "KeyViz" instead of the window underneath. Apply TRANSPARENT +
            // NOACTIVATE to the parent and every child so hit-testing skips us entirely
            // while screen-capture APIs (which use a different path) still see our pixels.
            unsafe extern "system" fn make_child_transparent(child: HWND, _: LPARAM) -> BOOL {
                let style = GetWindowLongPtrW(child, GWL_EXSTYLE);
                SetWindowLongPtrW(
                    child,
                    GWL_EXSTYLE,
                    style | WS_EX_TRANSPARENT.0 as isize | WS_EX_NOACTIVATE.0 as isize,
                );
                BOOL(1)
            }

            unsafe {
                let style = GetWindowLongPtrW(hwnd, GWL_EXSTYLE);
                SetWindowLongPtrW(
                    hwnd,
                    GWL_EXSTYLE,
                    style
                        | WS_EX_TRANSPARENT.0 as isize
                        | WS_EX_LAYERED.0 as isize
                        | WS_EX_NOACTIVATE.0 as isize,
                );
                EnumChildWindows(hwnd, Some(make_child_transparent), LPARAM(0));
            }

            // Start off-screen; event loop moves it to cursor on every mouse-move.
            window
                .set_position(tauri::PhysicalPosition { x: -10000i32, y: -10000i32 })
                .unwrap_or(());
            window
                .set_size(tauri::PhysicalSize { width: 150u32, height: 150u32 })
                .unwrap_or(());
        }
    }
    #[cfg(target_os = "macos")]
    {
        if !is_mouse_overlay {
            // Main key-overlay: cover the primary monitor so JS can shrink it.
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
        } else {
            // Mouse-overlay: small, off-screen until first cursor event.
            window
                .set_position(tauri::PhysicalPosition { x: -10000i32, y: -10000i32 })
                .unwrap_or(());
            window
                .set_size(tauri::PhysicalSize { width: 150u32, height: 150u32 })
                .unwrap_or(());
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
