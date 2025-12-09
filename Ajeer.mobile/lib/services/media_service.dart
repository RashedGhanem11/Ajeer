import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/attachment_models.dart';
import '../config/app_config.dart'; // FIX: Adjust this path to where your AppConfig file is located

class MediaService {
  // Removed the hardcoded baseUrl variable

  Future<AttachmentResponse?> uploadMedia(File file, String endpoint) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiUrl}/$endpoint'),
      );

      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AttachmentResponse.fromJson(data);
      } else {
        print("Upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading media: $e");
      return null;
    }
  }
}
