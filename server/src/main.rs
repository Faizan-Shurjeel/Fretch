use std::io::{BufRead, BufReader, Read};
use std::net::{Ipv4Addr, UdpSocket};
use std::process::{Command, Stdio};
use tiny_http::{Method, Response, Server};
use urlencoding::decode;

fn main() {
    // Find the local IP address
    let local_ip = get_local_ip().unwrap_or_else(|| "Unknown IP".to_string());
    //Clear the screen
    print!("\x1B[2J\x1B[1;1H");
    println!("\nLocal IP address of server: {}\n", local_ip);

    // Start the server
    let server = Server::http("0.0.0.0:8000").unwrap();
    println!("Server started on http://0.0.0.0:8000");

    for mut request in server.incoming_requests() {
        if request.method() == &Method::Post {
            let mut content = String::new();
            request.as_reader().read_to_string(&mut content).unwrap();

            // Parse the URL from the POST request body
            let url_encoded = content.split('=').nth(1).unwrap_or("").trim();
            let url = decode(url_encoded).unwrap_or_else(|_| "".into());

            if !url.is_empty() {
                // Spawn yt-dlp command
                let mut child = Command::new("yt-dlp")
                    .arg(url.to_string())
                    .stdout(Stdio::piped())
                    .spawn()
                    .expect("Failed to execute yt-dlp");

                // Read the output line by line
                if let Some(stdout) = child.stdout.take() {
                    let reader = BufReader::new(stdout);
                    for line in reader.lines() {
                        match line {
                            Ok(line) => println!("{}", line),
                            Err(e) => eprintln!("Error reading line: {}", e),
                        }
                    }
                }

                // Wait for the command to finish
                let _ = child.wait();

                // Send a response to the client
                let response = Response::from_string(
                    "Download started. Check the server console for progress.",
                );
                request.respond(response).unwrap();
            } else {
                let response = Response::from_string("Invalid URL").with_status_code(400);
                request.respond(response).unwrap();
            }
        } else {
            let response =
                Response::from_string("Only POST method is supported").with_status_code(405);
            request.respond(response).unwrap();
        }
    }
}

// Function to get the local IP address of the machine
fn get_local_ip() -> Option<String> {
    let socket = UdpSocket::bind("0.0.0.0:0").ok()?; // Bind to any available port
    socket.connect("8.8.8.8:80").ok()?; // Connect to a known external server (Google's DNS)
    let local_addr = socket.local_addr().ok()?;
    let ip = match local_addr {
        std::net::SocketAddr::V4(addr) => addr.ip().clone(),
        _ => return None,
    };
    Some(ip.to_string())
}
