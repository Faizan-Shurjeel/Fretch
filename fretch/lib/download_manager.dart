import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadManager {
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    // Check if any permission is granted
    bool isGranted = statuses.values.any((status) => status.isGranted);

    if (!isGranted) {
      // If permission is permanently denied, open app settings
      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        await openAppSettings();
        return false;
      }
    }

    return isGranted;
  }

  Future<String?> downloadVideo(String url, String fileName) async {
    try {
      // Request permissions first
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permissions not granted');
      }

      // Try to get the download directory
      String downloadPath;
      if (Platform.isAndroid) {
        downloadPath = '/storage/emulated/0/Download';
        // Ensure directory exists
        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        downloadPath = directory.path;
      }

      // Create the file
      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);

      print('Attempting to download to: $filePath');

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('Download completed successfully to: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Download error: $e');
      rethrow; // Rethrow to handle in UI
    }
  }
}
