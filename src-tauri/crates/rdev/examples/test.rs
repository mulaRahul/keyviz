#[cfg(target_os = "linux")]
use core::time;
#[cfg(target_os = "linux")]
use rdev::{key_from_code, linux_keycode_from_key, simulate};
use rdev::{Event, EventType, GrabError, Key as RdevKey};
#[cfg(target_os = "linux")]
use std::{collections::HashMap, mem::zeroed, os::raw::c_int, ptr, thread, time::SystemTime};
use std::{
    collections::HashSet,
    sync::{mpsc::Sender, Arc, Mutex},
};
#[cfg(target_os = "linux")]
use strum::IntoEnumIterator;
#[cfg(target_os = "linux")]
use x11::xlib::{self, Display, GrabModeAsync, KeyPressMask, XUngrabKey};

#[cfg(target_os = "linux")]
const KEYPRESS_EVENT: i32 = 2;
#[cfg(target_os = "linux")]
const MODIFIERS: i32 = 0;

pub static mut IS_GRAB: bool = false;

static mut GLOBAL_CALLBACK: Option<Box<dyn FnMut(Event) -> Option<Event>>> = None;

lazy_static::lazy_static! {
    pub static ref GRABED: Arc<Mutex<HashSet<RdevKey>>> = Arc::new(Mutex::new(HashSet::<RdevKey>::new()));
    pub static ref BROADCAST_CONNECT: Arc<Mutex<Option<Sender<bool>>>> = Arc::new(Mutex::new(None));
}

#[cfg(target_os = "linux")]
fn convert_event(key: RdevKey, is_press: bool) -> Event {
    Event {
        event_type: if is_press {
            EventType::KeyPress(key)
        } else {
            EventType::KeyRelease(key)
        },
        time: SystemTime::now(),
        unicode: None,
        platform_code: linux_keycode_from_key(key).unwrap_or_default() as _,
        position_code: linux_keycode_from_key(key).unwrap_or_default() as _,
        usb_hid: 0,
    }
}

#[cfg(target_os = "linux")]
fn ungrab_key(display: *mut Display, grab_window: u64, keycode: i32) {
    unsafe {
        XUngrabKey(display, keycode, MODIFIERS as _, grab_window);
    }
}

#[cfg(target_os = "linux")]
fn ungrab_keys(display: *mut Display, grab_window: u64) {
    for key in RdevKey::iter() {
        let keycode: i32 = linux_keycode_from_key(key).unwrap_or_default() as _;
        if is_key_grabed(key) {
            grab_key(display, grab_window, keycode);
            GRABED.lock().unwrap().insert(key);
        }
    }
}

#[cfg(target_os = "linux")]
fn grab_key(display: *mut Display, grab_window: u64, keycode: i32) {
    unsafe {
        xlib::XGrabKey(
            display,
            keycode,
            MODIFIERS as _,
            grab_window,
            c_int::from(true),
            GrabModeAsync,
            GrabModeAsync,
        );
    }
}

#[cfg(target_os = "linux")]
fn is_key_grabed(key: RdevKey) -> bool {
    GRABED.lock().unwrap().get(&key).is_some()
}

#[cfg(target_os = "linux")]
fn grab_keys(display: *mut Display, grab_window: u64) {
    for key in RdevKey::iter() {
        let event = convert_event(key, true);

        unsafe {
            if let Some(callback) = &mut GLOBAL_CALLBACK {
                let grab = callback(event).is_none();
                let keycode: i32 = linux_keycode_from_key(key).unwrap_or_default() as _;

                if grab && !is_key_grabed(key) {
                    println!("{:?} {:?}", key, keycode);
                    grab_key(display, grab_window, keycode);
                    // GRABED.lock().unwrap().insert(key);
                }
            }
        }
    }
}

#[cfg(target_os = "linux")]
fn send_key(key: RdevKey, is_press: bool) {
    let delay = time::Duration::from_millis(20);
    let event_type = if is_press {
        EventType::KeyPress(key)
    } else {
        EventType::KeyRelease(key)
    };
    match simulate(&event_type) {
        Ok(()) => (),
        Err(simulate_error) => {
            println!("We could not send {:?}", simulate_error);
        }
    }
    // Let ths OS catchup (at least MacOS)
    thread::sleep(delay);
}

#[cfg(target_os = "linux")]
fn set_key_hook() {
    unsafe {
        let display = xlib::XOpenDisplay(ptr::null());
        let screen_number = xlib::XDefaultScreen(display);
        let screen = xlib::XScreenOfDisplay(display, screen_number);
        let grab_window = xlib::XRootWindowOfScreen(screen);
        let my_grab_window = grab_window;

        loop {
            if IS_GRAB {
                let handle = std::thread::spawn(move || {
                    let display = xlib::XOpenDisplay(ptr::null());
                    grab_keys(display, my_grab_window);

                    xlib::XSelectInput(display, grab_window, KeyPressMask);
                    let mut x_event: xlib::XEvent = zeroed();
                    loop {
                        if !IS_GRAB {
                            break;
                        }
                        xlib::XNextEvent(display, &mut x_event);

                        let key = key_from_code(x_event.key.keycode);
                        let is_press = x_event.type_ == KEYPRESS_EVENT;
                        let event = convert_event(key, is_press);

                        if let Some(callback) = &mut GLOBAL_CALLBACK {
                            let _grab = callback(event).is_none();
                        }

                        println!("{:?} {:?}", key, is_press);
                    }
                });
                handle.join();
            }
        }
    }
}

pub fn grab<T>(callback: T) -> Result<(), GrabError>
where
    T: FnMut(Event) -> Option<Event> + 'static,
{
    unsafe {
        GLOBAL_CALLBACK = Some(Box::new(callback));
    }
    #[cfg(target_os = "linux")]
    set_key_hook();
    Ok(())
}

fn callback(event: Event) -> Option<Event> {
    match event.event_type {
        EventType::KeyPress(RdevKey::Alt) => None,
        EventType::KeyPress(RdevKey::MetaLeft) => None,
        EventType::KeyPress(RdevKey::ControlLeft) => None,
        _ => Some(event),
    }
}

fn main() {
    println!("Hello");
    if let Err(error) = grab(callback) {
        println!("Error: {:?}", error)
    }
}
