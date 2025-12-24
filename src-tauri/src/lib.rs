use std::thread;
use tauri::Emitter;
use rdev::listen;

mod event;
use event::convert_event;


#[tauri::command]
fn log(message: String) {
    println!("[LOG] {}", message);
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let app_handle = app.handle().clone();

            thread::spawn(move || {
                println!("Starting global input listener...");

                if let Err(err) = listen(move |event| {
                    if let Some(input_event) = convert_event(event) {
                        app_handle.emit("input-event", input_event).unwrap();
                    }
                }) {
                    eprintln!("rdev listen failed: {:?}", err);
                }
            });

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![log])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
