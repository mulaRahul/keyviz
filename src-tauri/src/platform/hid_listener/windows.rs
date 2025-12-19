//! Windows-specific keyboard and mouse listener using low-level hooks.
//! Provides start/stop control via posting WM_QUIT to the hook thread.

use crate::domain::event::{KeyEventType, KeyboardEvent, Modifiers, MouseEvent, MouseEventType};
use std::sync::mpsc::{self, Sender};
use std::sync::{OnceLock, RwLock};
use std::thread::{self, JoinHandle};
use windows_sys::Win32::Foundation::{LPARAM, LRESULT, WPARAM};
use windows_sys::Win32::System::Threading::GetCurrentThreadId;
use windows_sys::Win32::UI::Input::KeyboardAndMouse::{
    GetKeyState, VIRTUAL_KEY, VK_CAPITAL, VK_CONTROL, VK_LCONTROL, VK_LMENU, VK_LSHIFT, VK_LWIN,
    VK_MENU, VK_NUMLOCK, VK_RCONTROL, VK_RMENU, VK_RSHIFT, VK_RWIN, VK_SCROLL, VK_SHIFT,
};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    CallNextHookEx, DispatchMessageW, GetMessageW, PostThreadMessageW, SetWindowsHookExW,
    TranslateMessage, UnhookWindowsHookEx, HC_ACTION, HHOOK, KBDLLHOOKSTRUCT, MSLLHOOKSTRUCT, MSG,
    WH_KEYBOARD_LL, WH_MOUSE_LL, WM_KEYDOWN, WM_KEYUP, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_MBUTTONDOWN,
    WM_MBUTTONUP, WM_MOUSEMOVE, WM_MOUSEWHEEL, WM_QUIT, WM_RBUTTONDOWN, WM_RBUTTONUP, WM_SYSKEYDOWN,
    WM_SYSKEYUP, WM_XBUTTONDOWN, WM_XBUTTONUP,
};

static KEYBOARD_SENDER: OnceLock<RwLock<Option<Sender<KeyboardEvent>>>> = OnceLock::new();
static MOUSE_SENDER: OnceLock<RwLock<Option<Sender<MouseEvent>>>> = OnceLock::new();
static mut KEYBOARD_HOOK: HHOOK = std::ptr::null_mut();
static mut MOUSE_HOOK: HHOOK = std::ptr::null_mut();

pub struct HidListenerHandles {
    pub kb_rx: mpsc::Receiver<KeyboardEvent>,
    pub mouse_rx: mpsc::Receiver<MouseEvent>,
    pub thread_id: u32,
    pub thread: JoinHandle<()>,
}

fn set_senders(kb_tx: Sender<KeyboardEvent>, mouse_tx: Sender<MouseEvent>) {
    KEYBOARD_SENDER
        .get_or_init(|| RwLock::new(None))
        .write()
        .expect("lock poisoned")
        .replace(kb_tx);
    MOUSE_SENDER
        .get_or_init(|| RwLock::new(None))
        .write()
        .expect("lock poisoned")
        .replace(mouse_tx);
}

fn clear_senders() {
    if let Some(lock) = KEYBOARD_SENDER.get() {
        let _ = lock.write().map(|mut guard| guard.take());
    }
    if let Some(lock) = MOUSE_SENDER.get() {
        let _ = lock.write().map(|mut guard| guard.take());
    }
}

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
        0x30..=0x39 => char::from((vk_code - 0x30) as u8 + b'0').to_string(),
        0x41..=0x5A => char::from((vk_code - 0x41) as u8 + b'A').to_string(),
        0x5B => "Win".to_string(),
        0x5C => "Win".to_string(),
        0x60..=0x69 => format!("Num{}", vk_code - 0x60),
        0x6A => "*".to_string(),
        0x6B => "+".to_string(),
        0x6D => "-".to_string(),
        0x6E => ".".to_string(),
        0x6F => "/".to_string(),
        0x70..=0x7B => format!("F{}", vk_code - 0x70 + 1),
        0x90 => "NumLock".to_string(),
        0x91 => "ScrollLock".to_string(),
        VK_LSHIFT => "LShift".to_string(),
        VK_RSHIFT => "RShift".to_string(),
        VK_LCONTROL => "LCtrl".to_string(),
        VK_RCONTROL => "RCtrl".to_string(),
        VK_LMENU => "LAlt".to_string(),
        VK_RMENU => "RAlt".to_string(),
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

        if let Some(lock) = KEYBOARD_SENDER.get() {
            if let Ok(guard) = lock.read() {
                if let Some(tx) = guard.as_ref() {
                    let _ = tx.send(event);
                }
            }
        }
    }

    CallNextHookEx(KEYBOARD_HOOK, n_code, w_param, l_param)
}

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

        if let Some(lock) = MOUSE_SENDER.get() {
            if let Ok(guard) = lock.read() {
                if let Some(tx) = guard.as_ref() {
                    let _ = tx.send(event);
                }
            }
        }
    }

    CallNextHookEx(MOUSE_HOOK, n_code, w_param, l_param)
}

pub fn start_listener() -> Result<HidListenerHandles, String> {
    let (kb_tx, kb_rx) = mpsc::channel::<KeyboardEvent>();
    let (mouse_tx, mouse_rx) = mpsc::channel::<MouseEvent>();
    let (tid_tx, tid_rx) = mpsc::channel::<u32>();

    set_senders(kb_tx, mouse_tx);

    let thread = thread::spawn(move || unsafe {
        let thread_id = GetCurrentThreadId();
        let _ = tid_tx.send(thread_id);

        KEYBOARD_HOOK = SetWindowsHookExW(WH_KEYBOARD_LL, Some(keyboard_proc), std::ptr::null_mut(), 0);
        if KEYBOARD_HOOK.is_null() {
            eprintln!("Failed to install keyboard hook");
        }

        MOUSE_HOOK = SetWindowsHookExW(WH_MOUSE_LL, Some(mouse_proc), std::ptr::null_mut(), 0);
        if MOUSE_HOOK.is_null() {
            eprintln!("Failed to install mouse hook");
        }

        let mut msg: MSG = std::mem::zeroed();
        while GetMessageW(&mut msg, std::ptr::null_mut(), 0, 0) > 0 {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        if !KEYBOARD_HOOK.is_null() {
            UnhookWindowsHookEx(KEYBOARD_HOOK);
            KEYBOARD_HOOK = std::ptr::null_mut();
        }
        if !MOUSE_HOOK.is_null() {
            UnhookWindowsHookEx(MOUSE_HOOK);
            MOUSE_HOOK = std::ptr::null_mut();
        }

        clear_senders();
    });

    let thread_id = tid_rx.recv().unwrap_or(0);
    if thread_id == 0 {
        return Err("failed to start listener thread".into());
    }

    Ok(HidListenerHandles {
        kb_rx,
        mouse_rx,
        thread_id,
        thread,
    })
}

pub fn stop_listener(thread_id: u32) -> Result<(), String> {
    if thread_id == 0 {
        return Ok(());
    }
    let posted = unsafe { PostThreadMessageW(thread_id, WM_QUIT, 0, 0) };
    if posted == 0 {
        return Err("failed to stop listener thread".into());
    }
    Ok(())
}
