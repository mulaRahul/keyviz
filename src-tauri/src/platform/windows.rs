//! Windows-specific keyboard and mouse listener using low-level hooks.
//! Uses LowLevelKeyboardProc and LowLevelMouseProc via SetWindowsHookExW.

use serde::{Deserialize, Serialize};
use std::sync::mpsc::{self, Sender};
use std::sync::OnceLock;
use std::thread;

use windows_sys::Win32::Foundation::{LPARAM, LRESULT, WPARAM};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{
    GetKeyState, VIRTUAL_KEY, VK_CAPITAL, VK_CONTROL, VK_LCONTROL, VK_LMENU, VK_LSHIFT, VK_LWIN,
    VK_MENU, VK_NUMLOCK, VK_RCONTROL, VK_RMENU, VK_RSHIFT, VK_RWIN, VK_SCROLL, VK_SHIFT,
};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    CallNextHookEx, DispatchMessageW, GetMessageW, SetWindowsHookExW, TranslateMessage,
    UnhookWindowsHookEx, HC_ACTION, HHOOK, KBDLLHOOKSTRUCT, MSLLHOOKSTRUCT, MSG, WH_KEYBOARD_LL,
    WH_MOUSE_LL, WM_KEYDOWN, WM_KEYUP, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_MBUTTONDOWN, WM_MBUTTONUP,
    WM_MOUSEMOVE, WM_MOUSEWHEEL, WM_RBUTTONDOWN, WM_RBUTTONUP, WM_SYSKEYDOWN, WM_SYSKEYUP,
    WM_XBUTTONDOWN, WM_XBUTTONUP,
};

// Global sender for keyboard events
static KEYBOARD_SENDER: OnceLock<Sender<KeyboardEvent>> = OnceLock::new();
// Global sender for mouse events
static MOUSE_SENDER: OnceLock<Sender<MouseEvent>> = OnceLock::new();
// Store hook handles for cleanup
static mut KEYBOARD_HOOK: HHOOK = std::ptr::null_mut();
static mut MOUSE_HOOK: HHOOK = std::ptr::null_mut();

/// Keyboard event types
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum KeyEventType {
    KeyDown,
    KeyUp,
}

/// Mouse event types
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum MouseEventType {
    LeftButtonDown,
    LeftButtonUp,
    RightButtonDown,
    RightButtonUp,
    MiddleButtonDown,
    MiddleButtonUp,
    XButtonDown,
    XButtonUp,
    MouseMove,
    MouseWheel,
}

/// Modifier key states
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct Modifiers {
    pub ctrl: bool,
    pub shift: bool,
    pub alt: bool,
    pub meta: bool,
    pub caps_lock: bool,
    pub num_lock: bool,
    pub scroll_lock: bool,
}

/// Keyboard event data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeyboardEvent {
    pub event_type: KeyEventType,
    pub vk_code: u32,
    pub scan_code: u32,
    pub key_name: String,
    pub modifiers: Modifiers,
}

/// Mouse event data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MouseEvent {
    pub event_type: MouseEventType,
    pub x: i32,
    pub y: i32,
    pub wheel_delta: i16,
    pub modifiers: Modifiers,
}

/// Get current modifier key states
fn get_modifiers() -> Modifiers {
    unsafe {
        Modifiers {
            ctrl: (GetKeyState(VK_CONTROL as i32) as u16 & 0x8000) != 0,
            shift: (GetKeyState(VK_SHIFT as i32) as u16 & 0x8000) != 0,
            alt: (GetKeyState(VK_MENU as i32) as u16 & 0x8000) != 0,
            meta: (GetKeyState(VK_LWIN as i32) as u16 & 0x8000) != 0
                || (GetKeyState(VK_RWIN as i32) as u16 & 0x8000) != 0,
            caps_lock: (GetKeyState(VK_CAPITAL as i32) as u16 & 0x0001) != 0,
            num_lock: (GetKeyState(VK_NUMLOCK as i32) as u16 & 0x0001) != 0,
            scroll_lock: (GetKeyState(VK_SCROLL as i32) as u16 & 0x0001) != 0,
        }
    }
}

/// Convert virtual key code to readable key name
fn vk_to_key_name(vk_code: u32) -> String {
    match vk_code as VIRTUAL_KEY {
        0x08 => "Backspace".to_string(),
        0x09 => "Tab".to_string(),
        0x0D => "Enter".to_string(),
        0x10 => "Shift".to_string(),
        0x11 => "Ctrl".to_string(),
        0x12 => "Alt".to_string(),
        0x13 => "Pause".to_string(),
        0x14 => "CapsLock".to_string(),
        0x1B => "Esc".to_string(),
        0x20 => "Space".to_string(),
        0x21 => "PgUp".to_string(),
        0x22 => "PgDn".to_string(),
        0x23 => "End".to_string(),
        0x24 => "Home".to_string(),
        0x25 => "←".to_string(),
        0x26 => "↑".to_string(),
        0x27 => "→".to_string(),
        0x28 => "↓".to_string(),
        0x2C => "PrtSc".to_string(),
        0x2D => "Insert".to_string(),
        0x2E => "Delete".to_string(),
        // Numbers 0-9 (use chars so we don't emit decimal values like "48")
        0x30..=0x39 => char::from((vk_code - 0x30) as u8 + b'0').to_string(),
        // Letters A-Z
        0x41..=0x5A => char::from((vk_code - 0x41) as u8 + b'A').to_string(),
        // Left/Right Win keys
        0x5B => "Win".to_string(),
        0x5C => "Win".to_string(),
        // Numpad 0-9
        0x60..=0x69 => format!("Num{}", vk_code - 0x60),
        0x6A => "*".to_string(),
        0x6B => "+".to_string(),
        0x6D => "-".to_string(),
        0x6E => ".".to_string(),
        0x6F => "/".to_string(),
        // Function keys F1-F12
        0x70..=0x7B => format!("F{}", vk_code - 0x70 + 1),
        0x90 => "NumLock".to_string(),
        0x91 => "ScrollLock".to_string(),
        // Shift, Ctrl, Alt variants
        VK_LSHIFT => "LShift".to_string(),
        VK_RSHIFT => "RShift".to_string(),
        VK_LCONTROL => "LCtrl".to_string(),
        VK_RCONTROL => "RCtrl".to_string(),
        VK_LMENU => "LAlt".to_string(),
        VK_RMENU => "RAlt".to_string(),
        // OEM keys
        0xBA => ";".to_string(),
        0xBB => "=".to_string(),
        0xBC => ",".to_string(),
        0xBD => "-".to_string(),
        0xBE => ".".to_string(),
        0xBF => "/".to_string(),
        0xC0 => "`".to_string(),
        0xDB => "[".to_string(),
        0xDC => "\\".to_string(),
        0xDD => "]".to_string(),
        0xDE => "'".to_string(),
        _ => format!("VK_{:#04X}", vk_code),
    }
}

/// Low-level keyboard hook callback
unsafe extern "system" fn keyboard_proc(n_code: i32, w_param: WPARAM, l_param: LPARAM) -> LRESULT {
    if n_code == HC_ACTION as i32 {
        let kb_struct = &*(l_param as *const KBDLLHOOKSTRUCT);

        let event_type = match w_param as u32 {
            WM_KEYDOWN | WM_SYSKEYDOWN => KeyEventType::KeyDown,
            WM_KEYUP | WM_SYSKEYUP => KeyEventType::KeyUp,
            _ => KeyEventType::KeyDown,
        };

        let event = KeyboardEvent {
            event_type,
            vk_code: kb_struct.vkCode,
            scan_code: kb_struct.scanCode,
            key_name: vk_to_key_name(kb_struct.vkCode),
            modifiers: get_modifiers(),
        };

        if let Some(sender) = KEYBOARD_SENDER.get() {
            let _ = sender.send(event);
        }
    }

    CallNextHookEx(KEYBOARD_HOOK, n_code, w_param, l_param)
}

/// Low-level mouse hook callback
unsafe extern "system" fn mouse_proc(n_code: i32, w_param: WPARAM, l_param: LPARAM) -> LRESULT {
    if n_code == HC_ACTION as i32 {
        let mouse_struct = &*(l_param as *const MSLLHOOKSTRUCT);

        let event_type = match w_param as u32 {
            WM_LBUTTONDOWN => MouseEventType::LeftButtonDown,
            WM_LBUTTONUP => MouseEventType::LeftButtonUp,
            WM_RBUTTONDOWN => MouseEventType::RightButtonDown,
            WM_RBUTTONUP => MouseEventType::RightButtonUp,
            WM_MBUTTONDOWN => MouseEventType::MiddleButtonDown,
            WM_MBUTTONUP => MouseEventType::MiddleButtonUp,
            WM_XBUTTONDOWN => MouseEventType::XButtonDown,
            WM_XBUTTONUP => MouseEventType::XButtonUp,
            WM_MOUSEMOVE => MouseEventType::MouseMove,
            WM_MOUSEWHEEL => MouseEventType::MouseWheel,
            _ => return CallNextHookEx(MOUSE_HOOK, n_code, w_param, l_param),
        };

        let wheel_delta = if event_type == MouseEventType::MouseWheel {
            (mouse_struct.mouseData >> 16) as i16
        } else {
            0
        };

        let event = MouseEvent {
            event_type,
            x: mouse_struct.pt.x,
            y: mouse_struct.pt.y,
            wheel_delta,
            modifiers: get_modifiers(),
        };

        if let Some(sender) = MOUSE_SENDER.get() {
            let _ = sender.send(event);
        }
    }

    CallNextHookEx(MOUSE_HOOK, n_code, w_param, l_param)
}

/// Start the keyboard and mouse listener
/// Returns receivers for keyboard and mouse events
pub fn start_listener() -> (mpsc::Receiver<KeyboardEvent>, mpsc::Receiver<MouseEvent>) {
    let (kb_tx, kb_rx) = mpsc::channel::<KeyboardEvent>();
    let (mouse_tx, mouse_rx) = mpsc::channel::<MouseEvent>();

    let _ = KEYBOARD_SENDER.set(kb_tx);
    let _ = MOUSE_SENDER.set(mouse_tx);

    // Start the message loop in a separate thread
    thread::spawn(|| unsafe {
        // Install keyboard hook
        KEYBOARD_HOOK = SetWindowsHookExW(WH_KEYBOARD_LL, Some(keyboard_proc), std::ptr::null_mut(), 0);
        if KEYBOARD_HOOK.is_null() {
            eprintln!("Failed to install keyboard hook");
        }

        // Install mouse hook
        MOUSE_HOOK = SetWindowsHookExW(WH_MOUSE_LL, Some(mouse_proc), std::ptr::null_mut(), 0);
        if MOUSE_HOOK.is_null() {
            eprintln!("Failed to install mouse hook");
        }

        // Message loop - required for hooks to work
        let mut msg: MSG = std::mem::zeroed();
        while GetMessageW(&mut msg, std::ptr::null_mut(), 0, 0) > 0 {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        // Cleanup hooks when message loop ends
        if !KEYBOARD_HOOK.is_null() {
            UnhookWindowsHookEx(KEYBOARD_HOOK);
        }
        if !MOUSE_HOOK.is_null() {
            UnhookWindowsHookEx(MOUSE_HOOK);
        }
    });

    (kb_rx, mouse_rx)
}
