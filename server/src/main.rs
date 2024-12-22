mod websocket;

use serde_json::json;
use std::io::{BufRead, BufReader};
use std::net::{Ipv4Addr, UdpSocket};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::thread;
use tiny_http::{Method, Response, Server};
use urlencoding::decode;
use websocket::{broadcast_message, WebSocketHandler};

fn create_response(status_code: u16, body: &str) -> Response<std::io::Cursor<Vec<u8>>> {
    Response::from_string(body).with_status_code(status_code)
}

fn main() {
    let clients = Arc::new(Mutex::new(Vec::new()));
    let clients_clone = clients.clone();

    // Start WebSocket server
    thread::spawn(move || {
        ws::listen("0.0.0.0:8001", |out| WebSocketHandler {
            out,
            clients: clients_clone.clone(),
        })
        .unwrap()
    });

    let local_ip = get_local_ip().unwrap_or_else(|| "Unknown IP".to_string());
    print!("\x1B[2J\x1B[1;1H");
    println!("\nLocal IP address of server: {}\n", local_ip);

    let server = Server::http("0.0.0.0:8000").unwrap();
    println!("Server started on http://0.0.0.0:8000");

    for mut request in server.incoming_requests() {
        if request.method() == &Method::Post {
            let mut content = String::new();
            request.as_reader().read_to_string(&mut content).unwrap();

            let url_encoded = content.split('=').nth(1).unwrap_or("").trim();
            let url = decode(url_encoded).unwrap_or_else(|_| "".into());

            if !url.is_empty() {
                // Get video URL using yt-dlp
                let output = Command::new("yt-dlp")
                    .args(&["-f", "best", "-g", &url])
                    .output()
                    .expect("Failed to execute yt-dlp");

                let download_url = String::from_utf8_lossy(&output.stdout).trim().to_string();
                let video_info = Command::new("yt-dlp")
                    .args(&["-j", &url])
                    .output()
                    .expect("Failed to get video info");

                let video_info_str = String::from_utf8_lossy(&video_info.stdout);
                let video_info_json: serde_json::Value =
                    serde_json::from_str(&video_info_str).unwrap_or_else(|_| json!({}));

                let title = video_info_json["title"].as_str().unwrap_or("video");
                let ext = video_info_json["ext"].as_str().unwrap_or("mp4");

                let response_json = json!({
                    "url": download_url,
                    "title": title,
                    "ext": ext
                });

                broadcast_message(clients.clone(), &format!("Got download URL for: {}", title));

                let response = Response::from_string(response_json.to_string()).with_header(
                    tiny_http::Header::from_bytes("Content-Type", "application/json").unwrap(),
                );
                request.respond(response).unwrap();
            } else {
                let response = create_response(400, "Invalid URL");
                request.respond(response).unwrap();
            }
        } else {
            let response = create_response(405, "Only POST method is supported");
            request.respond(response).unwrap();
        }
    }
}

fn get_local_ip() -> Option<String> {
    let socket = UdpSocket::bind("0.0.0.0:0").ok()?;
    socket.connect("8.8.8.8:80").ok()?;
    let local_addr = socket.local_addr().ok()?;
    let ip = match local_addr {
        std::net::SocketAddr::V4(addr) => addr.ip().clone(),
        _ => return None,
    };
    Some(ip.to_string())
}
