import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  static Future<String?> saveImageToAppDir(String tempPath) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String fileName =
          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(dir.path, fileName);

      await File(tempPath).copy(newPath);

      // Attempt to delete temp file, but don't fail if it doesn't work
      try {
        await File(tempPath).delete();
      } catch (_) {}

      return newPath;
    } catch (e) {
      return null;
    }
  }
}
