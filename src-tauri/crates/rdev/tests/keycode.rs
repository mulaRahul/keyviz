use rdev::Key as RdevKey;

#[test]
fn test_convet_keycode() {
    let key = RdevKey::KeyQ;
    let (keycode, scancode) = (81, 16);

    assert_eq!(key, rdev::get_win_key(keycode, scancode));
    assert_eq!((81, 16), rdev::get_win_codes(key).unwrap());

    assert_eq!(16, rdev::win_scancode_from_key(key).unwrap()); // Windows
    assert_eq!(24, rdev::linux_keycode_from_key(key).unwrap()); // Linux
    assert_eq!(12, rdev::macos_keycode_from_key(key).unwrap()); // Mac OS
}
