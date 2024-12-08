import 'package:flutter/material.dart';

void showUserGuideDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('User Guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.paste),
              title:
                  Text('Click "Paste" to get video link from your clipboard.'),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title:
                  Text('Then click "Download" after adjusting its settings.'),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text(
                  'Check and manage in-app downloads, including videos and audio files.'),
            ),
            ListTile(
              leading: Icon(Icons.battery_alert),
              title: Text(
                  'Set battery usage of this app to "Unrestricted" in system settings.'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ensure you have the latest version of yt-dlp.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
