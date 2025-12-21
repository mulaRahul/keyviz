use rdev::{Event, EventType, Key, UnicodeInfo};
use std::time::SystemTime;

fn main() {
    let event = Event {
        event_type: EventType::KeyPress(Key::KeyS),
        time: SystemTime::now(),
        unicode: Some(UnicodeInfo {
            name: Some(String::from("S")),
            unicode: Vec::new(),
            is_dead: false,
        }),
        platform_code: 0,
        position_code: 0,
        usb_hid: 0,
        extra_data: 0 as _,
    };

    let serialized = serde_json::to_string(&event).unwrap();

    let deserialized: Event = serde_json::from_str(&serialized).unwrap();

    println!("Serialized event {:?}", serialized);
    println!("Deserialized event {:?}", deserialized);
    assert_eq!(event, deserialized);
}
