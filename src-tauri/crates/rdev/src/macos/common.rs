#![allow(clippy::upper_case_acronyms)]
use crate::keycodes::macos::virtual_keycodes::*;
use crate::macos::keyboard::Keyboard;
use crate::rdev::{Button, Event, EventType, Key};
use cocoa::base::id;
use core_graphics::{
    event::{CGEvent, CGEventFlags, CGEventTapLocation, CGEventType, CGKeyCode, EventField},
    event_source::CGEventSourceStateID,
};
use lazy_static::lazy_static;
use std::convert::TryInto;
use std::os::raw::c_void;
use std::sync::Mutex;
use std::time::{Duration, Instant, SystemTime};

use crate::keycodes::macos::key_from_code;

pub type CFMachPortRef = *const c_void;
pub type CFIndex = u64;
pub type CFAllocatorRef = id;
pub type CFRunLoopSourceRef = id;
pub type CFRunLoopRef = id;
pub type CFRunLoopMode = id;
pub type CGEventTapProxy = id;
pub type CGEventRef = CGEvent;
pub type FourCharCode = ::std::os::raw::c_uint;
pub type OSType = FourCharCode;
pub type PhysicalKeyboardLayoutType = OSType;
pub type SInt16 = ::std::os::raw::c_short;

#[allow(non_upper_case_globals, dead_code)]
pub const kUnknownType: FourCharCode = 1061109567;
#[allow(non_upper_case_globals, dead_code)]
pub const kKeyboardJIS: PhysicalKeyboardLayoutType = 1246319392;
#[allow(non_upper_case_globals, dead_code)]
pub const kKeyboardANSI: PhysicalKeyboardLayoutType = 1095652169;
#[allow(non_upper_case_globals, dead_code)]
pub const kKeyboardISO: PhysicalKeyboardLayoutType = 1230196512;
#[allow(non_upper_case_globals, dead_code)]
pub const kKeyboardUnknown: PhysicalKeyboardLayoutType = 1061109567;

// https://developer.apple.com/documentation/coregraphics/cgeventtapplacement?language=objc
pub type CGEventTapPlacement = u32;
#[allow(non_upper_case_globals)]
pub const kCGHeadInsertEventTap: u32 = 0;

// https://developer.apple.com/documentation/coregraphics/cgeventtapoptions?language=objc
#[allow(non_upper_case_globals)]
#[repr(u32)]
pub enum CGEventTapOption {
    Default = 0,
    ListenOnly = 1,
}

pub static mut LAST_FLAGS: CGEventFlags = CGEventFlags::CGEventFlagNull;

/// macOS reports a single physical Caps Lock press as a burst of
/// `FlagsChanged` events (the keycode can be 57 or 255, and the Alpha Shift
/// flag flips back and forth in between, see [QA1519]). Toggles that arrive
/// closer together than this belong to the same physical press and are
/// coalesced into one.
///
/// [QA1519]: https://developer.apple.com/library/archive/qa/qa1519/_index.html
const CAPS_LOCK_TOGGLE_WINDOW: Duration = Duration::from_millis(150);

/// Caps Lock events are not guaranteed to carry `kVK_CapsLock`: some macOS
/// versions report them with keycode 255 instead.
#[allow(non_upper_case_globals)]
const kVK_CapsLockAlternate: CGKeyCode = 255;

lazy_static! {
    pub static ref KEYBOARD_STATE: Mutex<Option<Keyboard>> = Mutex::new(Keyboard::new());
}

// https://developer.apple.com/documentation/coregraphics/cgeventmask?language=objc
pub type CGEventMask = u64;
#[allow(non_upper_case_globals)]
pub const kCGEventMaskForAllEvents: u64 = (1 << CGEventType::LeftMouseDown as u64)
    + (1 << CGEventType::LeftMouseUp as u64)
    + (1 << CGEventType::RightMouseDown as u64)
    + (1 << CGEventType::RightMouseUp as u64)
    + (1 << CGEventType::OtherMouseDown as u64)
    + (1 << CGEventType::OtherMouseUp as u64)
    + (1 << CGEventType::MouseMoved as u64)
    + (1 << CGEventType::LeftMouseDragged as u64)
    + (1 << CGEventType::RightMouseDragged as u64)
    + (1 << CGEventType::KeyDown as u64)
    + (1 << CGEventType::KeyUp as u64)
    + (1 << CGEventType::FlagsChanged as u64)
    + (1 << CGEventType::ScrollWheel as u64);

#[cfg(target_os = "macos")]
#[link(name = "Cocoa", kind = "framework")]
extern "C" {
    #[allow(improper_ctypes)]
    pub fn CGEventTapCreate(
        tap: CGEventTapLocation,
        place: CGEventTapPlacement,
        options: CGEventTapOption,
        eventsOfInterest: CGEventMask,
        callback: QCallback,
        user_info: id,
    ) -> CFMachPortRef;
    pub fn CGEventSourceKeyState(state_id: CGEventSourceStateID, key: CGKeyCode) -> bool;
    pub fn CFMachPortCreateRunLoopSource(
        allocator: CFAllocatorRef,
        tap: CFMachPortRef,
        order: CFIndex,
    ) -> CFRunLoopSourceRef;
    pub fn CFRunLoopGetCurrent() -> CFRunLoopRef;
    pub fn CFRunLoopAddSource(rl: CFRunLoopRef, source: CFRunLoopSourceRef, mode: CFRunLoopMode);
    pub fn CFRunLoopGetMain() -> CFRunLoopRef;
    pub fn CGEventTapEnable(tap: CFMachPortRef, enable: bool);
    pub fn CFRunLoopRun();
    pub fn CFRunLoopStop(rl: CFRunLoopRef);

    pub static kCFRunLoopCommonModes: CFRunLoopMode;
}

#[allow(improper_ctypes)]
#[allow(non_snake_case)]
#[link(name = "Carbon", kind = "framework")]
extern "C" {
    pub fn LMGetKbdType() -> u8;
    pub fn KBGetLayoutType(iKeyboardType: SInt16) -> PhysicalKeyboardLayoutType;
}

pub type QCallback = unsafe extern "C" fn(
    proxy: CGEventTapProxy,
    _type: CGEventType,
    cg_event: CGEventRef,
    user_info: *mut c_void,
) -> CGEventRef;

#[cfg(target_os = "macos")]
#[inline]
fn kb_get_layout_type() -> PhysicalKeyboardLayoutType {
    unsafe { KBGetLayoutType(LMGetKbdType() as _) }
}

#[cfg(target_os = "macos")]
#[allow(non_upper_case_globals)]
pub fn map_keycode(code: CGKeyCode) -> CGKeyCode {
    match code {
        kVK_ISO_Section => {
            if kb_get_layout_type() == kKeyboardISO {
                kVK_ANSI_Grave
            } else {
                kVK_ISO_Section
            }
        }
        kVK_ANSI_Grave => {
            if kb_get_layout_type() == kKeyboardISO {
                kVK_ISO_Section
            } else {
                kVK_ANSI_Grave
            }
        }
        _ => code,
    }
}

pub fn set_is_main_thread(b: bool) {
    if let Some(keyboard_state) = KEYBOARD_STATE.lock().unwrap().as_mut() {
        keyboard_state.set_is_main_thread(b);
    }
}

#[inline]
unsafe fn get_code(cg_event: &CGEvent) -> Option<CGKeyCode> {
    cg_event
        .get_integer_value_field(EventField::KEYBOARD_EVENT_KEYCODE)
        .try_into()
        .ok()
}

/// Turns a raw CoreGraphics event into the events to report.
///
/// Most raw events map to a single event, but Caps Lock (see the
/// `FlagsChanged` handling below) maps to a press *and* a release.
pub unsafe fn convert(
    _type: CGEventType,
    cg_event: &CGEvent,
    keyboard_state: &mut Keyboard,
) -> Option<Vec<Event>> {
    let mut code = 0;
    let option_type = match _type {
        CGEventType::LeftMouseDown => Some(EventType::ButtonPress(Button::Left)),
        CGEventType::LeftMouseUp => Some(EventType::ButtonRelease(Button::Left)),
        CGEventType::RightMouseDown => Some(EventType::ButtonPress(Button::Right)),
        CGEventType::RightMouseUp => Some(EventType::ButtonRelease(Button::Right)),
        CGEventType::OtherMouseDown => {
            match cg_event.get_integer_value_field(EventField::MOUSE_EVENT_BUTTON_NUMBER) {
                2 => Some(EventType::ButtonPress(Button::Middle)),
                event => Some(EventType::ButtonPress(Button::Unknown(event as u8))),
            }
        }
        CGEventType::OtherMouseUp => {
            match cg_event.get_integer_value_field(EventField::MOUSE_EVENT_BUTTON_NUMBER) {
                2 => Some(EventType::ButtonRelease(Button::Middle)),
                event => Some(EventType::ButtonRelease(Button::Unknown(event as u8))),
            }
        }
        CGEventType::MouseMoved => {
            let point = cg_event.location();
            Some(EventType::MouseMove {
                x: point.x,
                y: point.y,
            })
        }
        CGEventType::LeftMouseDragged | CGEventType::RightMouseDragged => {
            let point = cg_event.location();
            Some(EventType::MouseMove {
                x: point.x,
                y: point.y,
            })
        }
        CGEventType::KeyDown => {
            code = get_code(cg_event)?;
            Some(EventType::KeyPress(key_from_code(code)))
        }
        CGEventType::KeyUp => {
            code = get_code(cg_event)?;
            Some(EventType::KeyRelease(key_from_code(code)))
        }
        CGEventType::FlagsChanged => {
            code = get_code(cg_event)?;
            let flags = cg_event.get_flags();
            let previous_flags = LAST_FLAGS;
            LAST_FLAGS = flags;

            let caps_lock_mask = CGEventFlags::CGEventFlagAlphaShift;
            let caps_lock_changed =
                flags.contains(caps_lock_mask) != previous_flags.contains(caps_lock_mask);
            // Caps Lock is a lock, not a regular modifier: macOS only reports
            // that the lock state changed, and it never reports the key-up of
            // the physical key. A single press can produce several events
            // (whose keycode is 57 and/or 255), so they are coalesced into one
            // press here.
            let is_caps_lock_event =
                code == kVK_CapsLock || code == kVK_CapsLockAlternate || caps_lock_changed;

            if is_caps_lock_event {
                if !caps_lock_changed {
                    // Extra event of a burst, nothing changed for the lock.
                    None
                } else {
                    let now = Instant::now();
                    let in_same_burst = keyboard_state
                        .last_caps_lock_toggle
                        .is_some_and(|last| now.duration_since(last) < CAPS_LOCK_TOGGLE_WINDOW);
                    keyboard_state.last_caps_lock_toggle = Some(now);
                    if in_same_burst {
                        None
                    } else {
                        // Whether the lock is turned on or off, the user did
                        // press the key: report it as a press. The matching
                        // release is added at the end of this function.
                        Some(EventType::KeyPress(Key::CapsLock))
                    }
                }
            } else if flags < previous_flags {
                Some(EventType::KeyRelease(key_from_code(code)))
            } else {
                Some(EventType::KeyPress(key_from_code(code)))
            }
        }
        CGEventType::ScrollWheel => {
            let delta_y =
                cg_event.get_integer_value_field(EventField::SCROLL_WHEEL_EVENT_POINT_DELTA_AXIS_1);
            let delta_x =
                cg_event.get_integer_value_field(EventField::SCROLL_WHEEL_EVENT_POINT_DELTA_AXIS_2);
            Some(EventType::Wheel { delta_x, delta_y })
        }
        _ => None,
    };
    let event_type = option_type?;

    let unicode = match event_type {
        EventType::KeyPress(..) => {
            let code = cg_event.get_integer_value_field(EventField::KEYBOARD_EVENT_KEYCODE) as u32;
            #[allow(non_upper_case_globals)]
            let skip_unicode = match code as CGKeyCode {
                kVK_Shift | kVK_RightShift | kVK_CapsLock | kVK_ForwardDelete => true,
                _ => false,
            };
            if skip_unicode {
                None
            } else {
                let flags = cg_event.get_flags();
                let s = keyboard_state.create_unicode_for_key(code, flags);
                // if s.is_none() {
                //     s = Some(key_to_name(_k).to_owned())
                // }
                s
            }
        }
        EventType::KeyRelease(..) => None,
        _ => None,
    };

    let event = Event {
        event_type,
        time: SystemTime::now(),
        unicode,
        platform_code: code as _,
        position_code: 0 as _,
        usb_hid: 0,
        extra_data: cg_event.get_integer_value_field(EventField::EVENT_SOURCE_USER_DATA),
    };

    // macOS never reports the key-up of Caps Lock, so pair the press with a
    // release: the key is shown as pressed and then lingers exactly like any
    // other key tap instead of staying pressed forever.
    if let EventType::KeyPress(Key::CapsLock) = event.event_type {
        let release = Event {
            event_type: EventType::KeyRelease(Key::CapsLock),
            unicode: None,
            ..event.clone()
        };
        return Some(vec![event, release]);
    }

    Some(vec![event])
}

#[allow(dead_code)]
#[inline]
fn key_to_name(key: Key) -> &'static str {
    use Key::*;
    match key {
        KeyA => "a",
        KeyB => "b",
        KeyC => "c",
        KeyD => "d",
        KeyE => "e",
        KeyF => "f",
        KeyG => "g",
        KeyH => "h",
        KeyI => "i",
        KeyJ => "j",
        KeyK => "k",
        KeyL => "l",
        KeyM => "m",
        KeyN => "n",
        KeyO => "o",
        KeyP => "p",
        KeyQ => "q",
        KeyR => "r",
        KeyS => "s",
        KeyT => "t",
        KeyU => "u",
        KeyV => "v",
        KeyW => "w",
        KeyX => "x",
        KeyY => "y",
        KeyZ => "z",
        Num0 => "0",
        Num1 => "1",
        Num2 => "2",
        Num3 => "3",
        Num4 => "4",
        Num5 => "5",
        Num6 => "6",
        Num7 => "7",
        Num8 => "8",
        Num9 => "9",
        Minus => "-",
        Equal => "=",
        LeftBracket => "[",
        RightBracket => "]",
        BackSlash => "\\",
        SemiColon => ";",
        Quote => "\"",
        Comma => ",",
        Dot => ".",
        Slash => "/",
        BackQuote => "`",
        _ => "",
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use core_graphics::event_source::{CGEventSource, CGEventSourceStateID};
    use std::sync::Mutex;

    /// `LAST_FLAGS` is global state, keep the tests using `convert` sequential.
    static CONVERT_TEST_LOCK: Mutex<()> = Mutex::new(());

    fn flags_changed_event(code: CGKeyCode, flags: CGEventFlags) -> CGEvent {
        let source = CGEventSource::new(CGEventSourceStateID::HIDSystemState).unwrap();
        let event = CGEvent::new_keyboard_event(source, code, true).unwrap();
        event.set_type(CGEventType::FlagsChanged);
        event.set_flags(flags);
        event
    }

    /// Runs a flags-changed event through `convert`, like the event tap does.
    fn convert_flags_changed(
        code: CGKeyCode,
        flags: CGEventFlags,
        keyboard: &mut Keyboard,
    ) -> Vec<EventType> {
        unsafe {
            convert(
                CGEventType::FlagsChanged,
                &flags_changed_event(code, flags),
                keyboard,
            )
        }
        .map(|events| events.into_iter().map(|event| event.event_type).collect())
        .unwrap_or_default()
    }

    fn alpha_shift(on: bool) -> CGEventFlags {
        if on {
            CGEventFlags::CGEventFlagAlphaShift
        } else {
            CGEventFlags::CGEventFlagNull
        }
    }

    #[test]
    fn caps_lock_toggle_emits_a_press_and_a_release() {
        let _guard = CONVERT_TEST_LOCK.lock().unwrap();
        let mut keyboard = Keyboard::new().unwrap();
        unsafe { LAST_FLAGS = alpha_shift(false) };

        let events = convert_flags_changed(kVK_CapsLock, alpha_shift(true), &mut keyboard);

        assert_eq!(
            events,
            vec![
                EventType::KeyPress(Key::CapsLock),
                EventType::KeyRelease(Key::CapsLock),
            ]
        );
    }

    #[test]
    fn caps_lock_turning_off_is_also_a_press() {
        let _guard = CONVERT_TEST_LOCK.lock().unwrap();
        let mut keyboard = Keyboard::new().unwrap();
        unsafe { LAST_FLAGS = alpha_shift(true) };

        let events = convert_flags_changed(kVK_CapsLock, alpha_shift(false), &mut keyboard);

        assert_eq!(
            events,
            vec![
                EventType::KeyPress(Key::CapsLock),
                EventType::KeyRelease(Key::CapsLock),
            ]
        );
    }

    #[test]
    fn caps_lock_burst_is_coalesced_into_a_single_press() {
        let _guard = CONVERT_TEST_LOCK.lock().unwrap();
        let mut keyboard = Keyboard::new().unwrap();
        unsafe { LAST_FLAGS = alpha_shift(false) };

        // macOS 26 reports one physical press as e.g.
        // (57, alpha shift on), (255, alpha shift off), (57, alpha shift off).
        let on = convert_flags_changed(kVK_CapsLock, alpha_shift(true), &mut keyboard);
        let off = convert_flags_changed(kVK_CapsLockAlternate, alpha_shift(false), &mut keyboard);
        let echo = convert_flags_changed(kVK_CapsLock, alpha_shift(false), &mut keyboard);

        assert_eq!(on.len(), 2);
        assert!(off.is_empty());
        assert!(echo.is_empty());
    }

    #[test]
    fn caps_lock_press_after_the_coalescing_window_is_reported() {
        let _guard = CONVERT_TEST_LOCK.lock().unwrap();
        let mut keyboard = Keyboard::new().unwrap();
        unsafe { LAST_FLAGS = alpha_shift(false) };
        convert_flags_changed(kVK_CapsLock, alpha_shift(true), &mut keyboard);

        // Pretend the previous toggle happened long ago.
        keyboard.last_caps_lock_toggle = Some(Instant::now() - CAPS_LOCK_TOGGLE_WINDOW * 2);

        let events =
            convert_flags_changed(kVK_CapsLockAlternate, alpha_shift(false), &mut keyboard);

        assert_eq!(
            events,
            vec![
                EventType::KeyPress(Key::CapsLock),
                EventType::KeyRelease(Key::CapsLock),
            ]
        );
    }

    #[test]
    fn other_modifiers_still_report_press_then_release() {
        let _guard = CONVERT_TEST_LOCK.lock().unwrap();
        let mut keyboard = Keyboard::new().unwrap();
        unsafe { LAST_FLAGS = CGEventFlags::CGEventFlagNull };

        let pressed =
            convert_flags_changed(kVK_Shift, CGEventFlags::CGEventFlagShift, &mut keyboard);
        let released =
            convert_flags_changed(kVK_Shift, CGEventFlags::CGEventFlagNull, &mut keyboard);

        assert_eq!(pressed, vec![EventType::KeyPress(Key::ShiftLeft)]);
        assert_eq!(released, vec![EventType::KeyRelease(Key::ShiftLeft)]);
    }

    #[test]
    #[allow(non_snake_case)]
    fn test_KBGetLayoutType() {
        unsafe {
            let t1 = LMGetKbdType();
            let t2 = KBGetLayoutType(t1 as _);
            println!("LMGetKbdType: {}, KBGetLayoutType: {}", t1, t2);
        }
    }
}
