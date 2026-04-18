pub fn config_window(window: &tauri::WebviewWindow) {
    window
        .set_ignore_cursor_events(true)
        .expect("Failed to set ignore cursor events");

    let is_mouse_overlay = window.label() == "mouse-overlay";

    #[cfg(target_os = "windows")]
    {
        use windows::Win32::Foundation::HWND;
        use windows::Win32::UI::WindowsAndMessaging::{
            SetWindowPos, HWND_TOPMOST, SWP_NOMOVE, SWP_NOSIZE,
        };

        let hwnd = HWND(window.hwnd().unwrap().0 as isize);
        unsafe {
            let _ = SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
        }

        if is_mouse_overlay {
            // Start the mouse-overlay off-screen at its content size.
            // The event loop moves it to the cursor on every mouse-move event.
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
