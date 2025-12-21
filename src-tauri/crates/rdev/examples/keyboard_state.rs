use rdev::{EventType, Key, Keyboard, KeyboardState};

fn main() {
    #[cfg(target_os = "windows")]
    let mut keyboard = Keyboard::new();
    #[cfg(not(target_os = "windows"))]
    let mut keyboard = Keyboard::new().unwrap();
    let char_s = keyboard
        .add(&EventType::KeyPress(Key::KeyS))
        .unwrap()
        .name
        .unwrap();
    assert_eq!(char_s, "s".to_string());
    println!("Pressing S gives: {:?}", char_s);
    let n = keyboard.add(&EventType::KeyRelease(Key::KeyS));
    assert_eq!(n, None);

    keyboard.add(&EventType::KeyPress(Key::ShiftLeft));
    let char_s = keyboard
        .add(&EventType::KeyPress(Key::KeyS))
        .unwrap()
        .name
        .unwrap();
    println!("Pressing Shift+S gives: {:?}", char_s);
    assert_eq!(char_s, "S".to_string());
    let n = keyboard.add(&EventType::KeyRelease(Key::KeyS));
    assert_eq!(n, None);
    keyboard.add(&EventType::KeyRelease(Key::ShiftLeft));
}
