import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';

class UploadService {
  static Future<void> uploadToServer() async {
    final data = await DBHelper.getLocations();

    if (data.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('https://yourserver.com/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'locations': data}),
      );

      if (response.statusCode == 200) {
        await DBHelper.clearLocations();
      }
    } catch (e) {
      print("Upload failed: $e");
    }
  }
}
