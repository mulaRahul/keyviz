use std::ffi::OsStr;
use std::os::windows::ffi::OsStrExt;
use windows_sys::Win32::Foundation::HWND;
use windows_sys::Win32::UI::WindowsAndMessaging::{
    FindWindowW, GetWindowLongPtrW, SetLayeredWindowAttributes, SetWindowLongPtrW, SetWindowPos,
    GWL_EXSTYLE, HWND_TOPMOST, LWA_ALPHA, SWP_NOMOVE, SWP_NOSIZE, WS_EX_LAYERED, WS_EX_NOACTIVATE,
    WS_EX_TOOLWINDOW, WS_EX_TRANSPARENT,
};

pub fn apply_overlay(click_through: bool, hide_from_alt_tab: bool, focusable: bool) -> Result<(), String> {
    let title = OsStr::new("keyviz")
        .encode_wide()
        .chain(std::iter::once(0))
        .collect::<Vec<u16>>();

    let hwnd: HWND = unsafe { FindWindowW(std::ptr::null::<u16>(), title.as_ptr()) };
    if hwnd.is_null() {
        return Err("unable to find window handle".into());
    }

    unsafe {
        let mut ex = GetWindowLongPtrW(hwnd, GWL_EXSTYLE) as u32;
        ex |= WS_EX_LAYERED;

        if click_through {
            ex |= WS_EX_TRANSPARENT;
        } else {
            ex &= !WS_EX_TRANSPARENT;
        }

        if hide_from_alt_tab {
            ex |= WS_EX_TOOLWINDOW;
        } else {
            ex &= !WS_EX_TOOLWINDOW;
        }

        if !focusable {
            ex |= WS_EX_NOACTIVATE;
        } else {
            ex &= !WS_EX_NOACTIVATE;
        }

        SetWindowLongPtrW(hwnd, GWL_EXSTYLE, ex as isize);
        SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA);
        SetWindowPos(
            hwnd,
            HWND_TOPMOST,
            0,
            0,
            0,
            0,
            SWP_NOMOVE | SWP_NOSIZE,
        );
    }

    Ok(())
}
