import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'firstdialog.dart';
import 'console.dart';
import 'websocket_client.dart';
import 'download_manager.dart';

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
  final WebSocketClient _wsClient = WebSocketClient();
  final DownloadManager _downloadManager = DownloadManager();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUserGuideDialog(context);
      _requestInitialPermissions();
    });
    _wsClient.onMessage = _addConsoleMessage;
  }

  Future<void> _requestInitialPermissions() async {
    await _downloadManager.requestPermissions();
  }

  Future<void> _showPermissionDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to download videos. Would you like to grant the permission now?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Grant Permission'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _downloadManager.requestPermissions();
              },
            ),
          ],
        );
      },
    );
  }

  void _addConsoleMessage(String message) {
    setState(() {
      _consoleMessages.add(message);
    });
  }

  void _clearConsole() {
    setState(() {
      _consoleMessages.clear();
    });
  }

  Future<void> _connectToServer() async {
    if (_ipController.text.isEmpty || _urlController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter both IP and URL';
        _addConsoleMessage('Error: IP or URL is empty');
      });
      return;
    }

    final ip = _ipController.text;
    final url = _urlController.text;
    final serverUrl = 'http://$ip:8000';

    _wsClient.connect(ip);

    try {
      setState(() {
        _isDownloading = true;
        _statusMessage = 'Getting download URL...';
        _addConsoleMessage('Getting download URL...');
      });

      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'url': url},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final downloadUrl = data['url'];
        final title = data['title'];
        final ext = data['ext'];

        _addConsoleMessage('Starting download for: $title');

        // Sanitize filename
        final fileName =
            '${title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}.$ext'
                .replaceAll(RegExp(r'\s+'), '_');

        setState(() {
          _statusMessage = 'Downloading: $fileName';
        });

        try {
          final filePath =
              await _downloadManager.downloadVideo(downloadUrl, fileName);
          setState(() {
            _statusMessage = 'Download completed: $fileName';
            _addConsoleMessage('Download completed: $filePath');
          });
        } catch (e) {
          setState(() {
            _statusMessage = 'Download failed: ${e.toString()}';
            _addConsoleMessage('Download error: $e');
          });
          _showPermissionDialog();
        }
      } else {
        setState(() {
          _statusMessage = 'Failed to get download URL';
          _addConsoleMessage('Error: Server returned ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _addConsoleMessage('Error: $e');
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  void dispose() {
    _wsClient.disconnect();
    _ipController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fretch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: _showPermissionDialog,
            tooltip: 'Storage Permissions',
          ),
        ],
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
              onPressed: _isDownloading ? null : _connectToServer,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Start Download'),
            ),
            const SizedBox(height: 8),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('failed')
                        ? Colors.red
                        : Colors.green),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ConsoleOutput(
                messages: _consoleMessages,
                onClear: _clearConsole,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
