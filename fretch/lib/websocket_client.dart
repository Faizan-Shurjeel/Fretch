import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  Function(String)? onMessage;

  void connect(String ip) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$ip:8001'),
      );

      _channel!.stream.listen(
        (message) {
          final decoded = jsonDecode(message);
          if (decoded['message_type'] == 'console' && onMessage != null) {
            onMessage!(decoded['content']);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
