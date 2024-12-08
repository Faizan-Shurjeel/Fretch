use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};
use ws::{Handler, Handshake, Message, Result, Sender};

#[derive(Serialize, Deserialize)]
pub struct ConsoleMessage {
    message_type: String,
    content: String,
}

pub struct WebSocketHandler {
    pub out: Sender,
    pub clients: Arc<Mutex<Vec<Sender>>>,
}

impl Handler for WebSocketHandler {
    fn on_open(&mut self, _: Handshake) -> Result<()> {
        let mut clients = self.clients.lock().unwrap();
        clients.push(self.out.clone());
        Ok(())
    }

    fn on_message(&mut self, msg: Message) -> Result<()> {
        // Echo message back for testing
        self.out.send(msg)
    }

    fn on_close(&mut self, _code: ws::CloseCode, _reason: &str) {
        let mut clients = self.clients.lock().unwrap();
        clients.retain(|client| client != &self.out);
    }
}

pub fn broadcast_message(clients: Arc<Mutex<Vec<Sender>>>, message: &str) {
    let console_msg = ConsoleMessage {
        message_type: "console".to_string(),
        content: message.to_string(),
    };

    let msg = serde_json::to_string(&console_msg).unwrap();

    let clients = clients.lock().unwrap();
    for client in clients.iter() {
        let _ = client.send(msg.clone());
    }
}
