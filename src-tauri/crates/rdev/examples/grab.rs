#[cfg(target_os = "linux")]
use core::time::Duration;
use rdev::Event;
use rdev::EventType;
#[cfg(target_os = "linux")]
use rdev::{disable_grab, enable_grab, exit_grab_listen, start_grab_listen};
#[cfg(target_os = "linux")]
use std::thread;

fn callback(event: Event) -> Option<Event> {
    match event.event_type {
        EventType::KeyPress(_key) | EventType::KeyRelease(_key) => {
            /*  */
            println!(
                "name: {:?}, type: {:?}, code: {:#04X?}, scan: {:#06X?}",
                &event.unicode, &event.event_type, &event.platform_code, &event.position_code
            );
            Some(event)
        }
        _ => Some(event),
    }
}

#[cfg(target_os = "linux")]
fn main() {
    let delay = Duration::from_secs(5);

    println!("[*] starting grab listen...");
    if let Err(err) = start_grab_listen(callback) {
        eprintln!("start grab listen error: {:?}", err);
        return;
    };

    println!("[*] grab keys(5s), try to press Ctrl+C, won't work on other applications");
    enable_grab();
    thread::sleep(delay);

    println!("[*] ungrab keys(5s), try to press Ctrl+C");
    disable_grab();
    thread::sleep(delay);

    println!("[*] grab keys(5s), try to press Ctrl+C, won't work on other applications");
    enable_grab();
    thread::sleep(delay);

    exit_grab_listen();
}

#[cfg(any(target_os = "windows", target_os = "macos"))]
fn main() {
    // This will block.
    if let Err(error) = rdev::grab(callback) {
        println!("Error: {:?}", error)
    }
}
