fn main() {
    let keycode = rdev::linux_keycode_from_key(rdev::Key::Num1);
    dbg!(keycode);
}
