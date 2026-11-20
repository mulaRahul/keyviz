use std::{
    io::{BufRead, BufReader, Write},
    net::{TcpListener, TcpStream},
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc::{self, Sender},
        Arc, Mutex,
    },
    thread,
    time::Duration,
};

use tauri::AppHandle;

/// A local HTTP server that serves a keycap-only page for OBS Browser Source.
///
/// OBS can capture a browser source without any of the window-capture
/// problems that affect WebView2 windows, so this is the reliable way to get
/// the keycaps into a recording. The page is server-sent-events driven: the
/// app pushes the current visual state and the page only renders it.
pub struct BrowserSource {
    port: Option<u16>,
    running: Arc<AtomicBool>,
    clients: Arc<Mutex<Vec<Sender<String>>>>,
    latest: Arc<Mutex<String>>,
}

impl Default for BrowserSource {
    fn default() -> Self {
        Self {
            port: None,
            running: Arc::new(AtomicBool::new(false)),
            clients: Arc::new(Mutex::new(Vec::new())),
            latest: Arc::new(Mutex::new(String::from("{\"groups\":[]}"))),
        }
    }
}

impl BrowserSource {
    pub fn port(&self) -> Option<u16> {
        self.port
    }

    pub fn is_running(&self) -> bool {
        self.running.load(Ordering::SeqCst)
    }

    /// Binds the requested localhost port and starts accepting connections.
    /// Pass 0 to let the OS pick one. Returns the port the page is served on.
    pub fn start(&mut self, app: AppHandle, port: u16) -> Result<u16, String> {
        if self.port == Some(port) && self.is_running() {
            return Ok(port);
        }
        if self.is_running() {
            self.stop();
        }

        let listener = TcpListener::bind(("127.0.0.1", port)).map_err(|err| err.to_string())?;
        let port = listener.local_addr().map_err(|err| err.to_string())?.port();
        listener
            .set_nonblocking(true)
            .map_err(|err| err.to_string())?;

        self.port = Some(port);
        self.running.store(true, Ordering::SeqCst);

        let running = Arc::clone(&self.running);
        let clients = Arc::clone(&self.clients);
        let latest = Arc::clone(&self.latest);

        thread::spawn(move || {
            while running.load(Ordering::SeqCst) {
                match listener.accept() {
                    Ok((stream, _)) => {
                        let clients = Arc::clone(&clients);
                        let latest = Arc::clone(&latest);
                        let app = app.clone();
                        thread::spawn(move || handle_connection(stream, clients, latest, app));
                    }
                    Err(err) if err.kind() == std::io::ErrorKind::WouldBlock => {
                        thread::sleep(Duration::from_millis(50));
                    }
                    Err(_) => break,
                }
            }
        });

        Ok(port)
    }

    pub fn stop(&mut self) {
        self.running.store(false, Ordering::SeqCst);
        self.port = None;
        if let Ok(mut clients) = self.clients.lock() {
            clients.clear();
        }
    }

    /// Stores and forwards one visual state to every attached page.
    pub fn update(&self, payload: String) {
        if !self.is_running() {
            return;
        }
        if let Ok(mut latest) = self.latest.lock() {
            *latest = payload.clone();
        }
        if let Ok(mut clients) = self.clients.lock() {
            clients.retain(|client| client.send(payload.clone()).is_ok());
        }
    }
}

fn handle_connection(
    mut stream: TcpStream,
    clients: Arc<Mutex<Vec<Sender<String>>>>,
    latest: Arc<Mutex<String>>,
    app: AppHandle,
) {
    let mut reader = BufReader::new(match stream.try_clone() {
        Ok(stream) => stream,
        Err(_) => return,
    });

    let mut request_line = String::new();
    if reader.read_line(&mut request_line).is_err() {
        return;
    }
    // Consume the remaining headers; they are not needed.
    loop {
        let mut line = String::new();
        match reader.read_line(&mut line) {
            Ok(0) => break,
            Ok(_) if line == "\r\n" || line == "\n" => break,
            Ok(_) => {}
            Err(_) => return,
        }
    }

    let path = request_line.split_whitespace().nth(1).unwrap_or("/");
    // The document root is the app's own viewer page; every other path is an
    // asset of the frontend bundle embedded in the binary, so nothing has to be
    // shipped next to the executable.
    let path = if path == "/" || path == "/index.html" {
        "/viewer.html"
    } else {
        path
    };

    match path {
        "/events" => {
            if stream
                .write_all(
                    b"HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\nAccess-Control-Allow-Origin: *\r\n\r\n",
                )
                .is_err()
            {
                return;
            }

            let initial = latest
                .lock()
                .map(|state| state.clone())
                .unwrap_or_else(|_| String::from("{\"groups\":[]}"));
            if write_event(&mut stream, &initial).is_err() {
                return;
            }

            let (sender, receiver) = mpsc::channel::<String>();
            if let Ok(mut clients) = clients.lock() {
                clients.push(sender);
            }

            // Keep the connection open and stream state updates. Writes fail
            // as soon as OBS closes or reloads the browser source, which ends
            // the thread and drops the sender again.
            for payload in receiver {
                if write_event(&mut stream, &payload).is_err() {
                    break;
                }
            }
        }
        _ => serve_asset(&mut stream, &app, path),
    }
}

fn write_event(stream: &mut TcpStream, payload: &str) -> std::io::Result<()> {
    stream.write_all(format!("data: {payload}\n\n").as_bytes())?;
    stream.flush()
}
/// Serves one file from the frontend bundle embedded in the binary.
fn serve_asset(stream: &mut TcpStream, app: &AppHandle, path: &str) {
    let Some(asset) = app.asset_resolver().get(path.trim_start_matches('/').to_string()) else {
        let _ = stream.write_all(b"HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n");
        return;
    };

    let headers = format!(
        "HTTP/1.1 200 OK\r\nContent-Type: {}\r\nContent-Length: {}\r\nCache-Control: no-cache\r\n\r\n",
        asset.mime_type,
        asset.bytes.len()
    );
    let _ = stream.write_all(headers.as_bytes());
    let _ = stream.write_all(&asset.bytes);
}