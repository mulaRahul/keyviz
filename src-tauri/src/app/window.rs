pub fn config_window(window: &tauri::WebviewWindow) {
    window
        .set_ignore_cursor_events(true)
        .expect("Failed to set ignore cursor events");

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
    }
    #[cfg(target_os = "macos")]
    {
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
