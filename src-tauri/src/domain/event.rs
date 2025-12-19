use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum KeyEventType {
    KeyDown,
    KeyUp,
}

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

impl Modifiers {
    pub fn to_strings(&self) -> Vec<String> {
        let mut result = Vec::new();
        if self.ctrl {
            result.push("Ctrl".to_string());
        }
        if self.alt {
            result.push("Alt".to_string());
        }
        if self.shift {
            result.push("Shift".to_string());
        }
        if self.meta {
            result.push("Win".to_string());
        }
        result
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeyboardEvent {
    pub event_type: KeyEventType,
    pub vk_code: u32,
    pub scan_code: u32,
    pub key_name: String,
    pub modifiers: Modifiers,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MouseEvent {
    pub event_type: MouseEventType,
    pub x: i32,
    pub y: i32,
    pub wheel_delta: i16,
    pub modifiers: Modifiers,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum HidEvent {
    Keyboard {
        event_type: String,
        key_name: String,
        vk_code: u32,
        modifiers: Vec<String>,
    },
    Mouse {
        event_type: String,
        x: i32,
        y: i32,
        modifiers: Vec<String>,
    },
}

impl From<KeyboardEvent> for HidEvent {
    fn from(event: KeyboardEvent) -> Self {
        let event_type = match event.event_type {
            KeyEventType::KeyDown => "keydown".to_string(),
            KeyEventType::KeyUp => "keyup".to_string(),
        };
        HidEvent::Keyboard {
            event_type,
            key_name: event.key_name,
            vk_code: event.vk_code,
            modifiers: event.modifiers.to_strings(),
        }
    }
}

impl From<MouseEvent> for HidEvent {
    fn from(event: MouseEvent) -> Self {
        let event_type = match event.event_type {
            MouseEventType::LeftButtonDown => "left-down".to_string(),
            MouseEventType::LeftButtonUp => "left-up".to_string(),
            MouseEventType::RightButtonDown => "right-down".to_string(),
            MouseEventType::RightButtonUp => "right-up".to_string(),
            MouseEventType::MiddleButtonDown => "middle-down".to_string(),
            MouseEventType::MiddleButtonUp => "middle-up".to_string(),
            MouseEventType::XButtonDown => "x-down".to_string(),
            MouseEventType::XButtonUp => "x-up".to_string(),
            MouseEventType::MouseMove => "move".to_string(),
            MouseEventType::MouseWheel => "wheel".to_string(),
        };
        HidEvent::Mouse {
            event_type,
            x: event.x,
            y: event.y,
            modifiers: event.modifiers.to_strings(),
        }
    }
}
