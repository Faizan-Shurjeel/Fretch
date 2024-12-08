// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'firstdialog.dart';

// class ConnectPage extends StatefulWidget {
//   const ConnectPage({super.key});

//   @override
//   ConnectPageState createState() => ConnectPageState();
// }

// class ConnectPageState extends State<ConnectPage> {
//   final TextEditingController _ipController = TextEditingController();
//   final TextEditingController _urlController = TextEditingController();
//   String _statusMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showUserGuideDialog(context);
//     });
//   }

//   void _connectToServer() async {
//     final ip = _ipController.text;
//     final url = _urlController.text;
//     final serverUrl = 'http://$ip:8000';

//     try {
//       final response = await http.post(
//         Uri.parse(serverUrl),
//         body: {'url': url},
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _statusMessage =
//               'Download started. Check the server console for progress.';
//         });
//       } else {
//         setState(() {
//           _statusMessage = 'Failed to connect to the server.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fretch'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _ipController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter server IP',
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _urlController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter video URL',
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _connectToServer,
//               child: const Text('Connect'),
//             ),
//             const SizedBox(height: 20),
//             Text(_statusMessage),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'firstdialog.dart';
import 'console.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  ConnectPageState createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _statusMessage = '';
  final List<String> _consoleMessages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUserGuideDialog(context);
    });
  }

  void _addConsoleMessage(String message) {
    setState(() {
      _consoleMessages.add(message);
    });
  }

  void _connectToServer() async {
    final ip = _ipController.text;
    final url = _urlController.text;
    final serverUrl = 'http://$ip:8000';

    try {
      _addConsoleMessage('Connecting to server at $serverUrl...');

      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'url': url},
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = 'Download started';
          _addConsoleMessage('Download started for: $url');
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to connect to the server.';
          _addConsoleMessage('Error: Server returned ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _addConsoleMessage('Connection error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fretch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Enter server IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter video URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _connectToServer,
              icon: const Icon(Icons.download),
              label: const Text('Start Download'),
            ),
            const SizedBox(height: 8),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.green),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ConsoleOutput(messages: _consoleMessages),
            ),
          ],
        ),
      ),
    );
  }
}
