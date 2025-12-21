#[cfg(target_os = "windows")]
use rdev::get_win_key;
use rdev::{Event, EventType::*, Key as RdevKey, Keyboard as RdevKeyboard, KeyboardState};
use std::collections::HashMap;
use std::sync::Arc;
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref MUTEX_SPECIAL_KEYS: Mutex<HashMap<RdevKey, bool>> = {
        let mut m = HashMap::new();
        // m.insert(RdevKey::PrintScreen, false); // 无反应
        m.insert(RdevKey::ShiftLeft, false);
        m.insert(RdevKey::ShiftRight, false);

        m.insert(RdevKey::ControlLeft, false);
        m.insert(RdevKey::ControlRight, false);

        m.insert(RdevKey::Alt, false);
        m.insert(RdevKey::AltGr, false);

        Mutex::new(m)


    };
}

#[cfg(target_os = "windows")]
lazy_static::lazy_static! {
    static ref KEYBOARD: Arc<Mutex<RdevKeyboard>> = Arc::new(Mutex::new(RdevKeyboard::new()));
}

#[cfg(not(target_os = "windows"))]
lazy_static::lazy_static! {
    static ref KEYBOARD: Arc<Mutex<RdevKeyboard>> = Arc::new(Mutex::new(RdevKeyboard::new().unwrap()));
}

fn main() {
    // This will block.
    std::env::set_var("KEYBOARD_ONLY", "y");

    let mut keyboard = KEYBOARD.lock().unwrap();
    let func = move |evt: Event| {
        let (_key, _down) = match evt.event_type {
            KeyPress(k) => {
                if MUTEX_SPECIAL_KEYS.lock().unwrap().contains_key(&k) {
                    if *MUTEX_SPECIAL_KEYS.lock().unwrap().get(&k).unwrap() {
                        return;
                    }
                    MUTEX_SPECIAL_KEYS.lock().unwrap().insert(k, true);
                }
                println!(
                    "keydown {:?} {:?} {:?}",
                    k, evt.platform_code, evt.position_code
                );

                (k, 1)
            }
            KeyRelease(k) => {
                if MUTEX_SPECIAL_KEYS.lock().unwrap().contains_key(&k) {
                    MUTEX_SPECIAL_KEYS.lock().unwrap().insert(k, false);
                }
                println!(
                    "keyup {:?} {:?} {:?}",
                    k, evt.platform_code, evt.position_code
                );
                (k, 0)
            }
            _ => return,
        };

        let char_s = keyboard.add(&evt.event_type).unwrap_or_default();
        dbg!(char_s);
        let is_dead = keyboard.is_dead();
        dbg!(is_dead);

        #[cfg(target_os = "windows")]
        let _key = get_win_key(evt.platform_code, evt.position_code);
        #[cfg(target_os = "windows")]
        println!("{:?}", _key);

        let linux_keycode = rdev::linux_keycode_from_key(_key).unwrap();
        // Mac/Linux Numpad -> Windows ArrawKey
        // https://github.com/asur4s/rustdesk/blob/fe9923109092827f543560a7af42dff6c3135117/src/ui/remote.rs#L968
        let win_scancode = rdev::win_scancode_from_key(_key).unwrap();
        let macos_keycode = rdev::macos_keycode_from_key(_key).unwrap();
        println!("Linux keycode {:?}", linux_keycode);
        println!("Windows scancode {:?}", win_scancode);
        println!("Mac OS keycode {:?}", macos_keycode);

        println!("--------------");
    };
    if let Err(error) = rdev::listen(func) {
        // rdev::listen
        dbg!("{:?}", error);
    }
}
