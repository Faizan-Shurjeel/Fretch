import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadManager {
  Future<bool> requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      bool isGranted = statuses.values.any((status) => status.isGranted);

      if (!isGranted) {
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          print('Permissions permanently denied. Opening settings...');
          await openAppSettings();
          return false;
        }
        print('Permissions denied: $statuses');
        return false;
      }
      return true;
    } catch (e) {
      print('Permission request error: $e');
      throw Exception('Failed to request permissions: $e');
    }
  }

  Future<String?> downloadVideo(String url, String fileName) async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception(
            'Storage permissions denied. Please grant permissions in app settings.');
      }

      String downloadPath;
      if (Platform.isAndroid) {
        downloadPath = '/storage/emulated/0/Download';
        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          try {
            await dir.create(recursive: true);
          } catch (e) {
            throw Exception('Failed to create download directory: $e');
          }
        }
      } else {
        try {
          final directory = await getApplicationDocumentsDirectory();
          downloadPath = directory.path;
        } catch (e) {
          throw Exception('Failed to get application directory: $e');
        }
      }

      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);

      print('Starting download to: $filePath');

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print(
              'Download completed successfully. File size: ${response.bodyBytes.length} bytes');
          return filePath;
        } else {
          throw Exception(
              'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on http.ClientException catch (e) {
        throw Exception('Network error during download: $e');
      } on FileSystemException catch (e) {
        throw Exception('File system error while saving: $e');
      }
    } catch (e, stackTrace) {
      print('Download error: $e\nStack trace: $stackTrace');
      rethrow;
    }
  }
}
