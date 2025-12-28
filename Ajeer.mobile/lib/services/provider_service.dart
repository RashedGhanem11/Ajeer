import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/provider_data.dart';
import 'dart:io';

class ProviderService {
  final String _baseUrl = AppConfig.apiUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<ProviderData?> getProviderProfile() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/serviceproviders/my-profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProviderData.fromApi(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> registerProvider(ProviderData data) async {
    final oldToken = await _getToken();
    final url = Uri.parse('$_baseUrl/serviceproviders/register');

    // 1. Use MultipartRequest (Matches BookingService)
    var request = http.MultipartRequest('POST', url);

    // 2. Add Headers (Matches BookingService: ONLY Authorization)
    // CRITICAL: Do NOT add 'Content-Type'. The http package handles the boundary automatically.
    if (oldToken != null) {
      request.headers.addAll({'Authorization': 'Bearer $oldToken'});
    }

    // 3. Add Simple Text Fields
    request.fields['Bio'] = "Professional Service Provider";

    // 4. Add File (Matches BookingService Logic)
    // 'fromPath' automatically detects the file type (jpg, png, etc.)
    if (data.idCardImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'IdCardImage',
          data.idCardImage!.path,
        ),
      );
    }

    // 5. Add Lists using BookingService Logic (MultipartFile.fromString)
    // BookingService uses this trick to send list items with the same key
    final serviceIds = data.getAllServiceIds();
    for (var id in serviceIds) {
      request.files.add(
        http.MultipartFile.fromString('ServiceIds', id.toString()),
      );
    }

    final areaIds = data.getAllAreaIds();
    for (var id in areaIds) {
      request.files.add(
        http.MultipartFile.fromString('ServiceAreaIds', id.toString()),
      );
    }

    // 6. Add Schedules (Complex Objects)
    // Complex objects must be flattened using indexed notation for ASP.NET Binding
    final schedules = data.finalSchedule.expand((s) => s.toApiDto()).toList();
    for (int i = 0; i < schedules.length; i++) {
      request.fields['Schedules[$i].DayOfWeek'] = schedules[i]['dayOfWeek']
          .toString();
      request.fields['Schedules[$i].StartTime'] = schedules[i]['startTime'];
      request.fields['Schedules[$i].EndTime'] = schedules[i]['endTime'];
    }

    // 7. Send Request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response.body));
    } else {
      // ✅ SUCCESS
      final responseData = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // 1. SAVE NEW TOKEN (If provided)
      final newToken = responseData['token'] ?? responseData['Token'];
      if (newToken != null) {
        await prefs.setString('authToken', newToken);
      }

      // 2. UPDATE STORED USER DATA
      final String? userJson = prefs.getString('currentUser');
      if (userJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userJson);

        // ✅ A. MARK APPLICATION AS SUBMITTED
        // This ensures the Profile Screen knows we are in "Pending" state
        userMap['hasProviderApplication'] = true;

        // ✅ B. UPDATE ROLE ONLY IF SERVER SAYS SO
        // We REMOVED the fallback that forced 'ServiceProvider'.
        // Now, if the server returns 'Customer' (pending) or nothing,
        // the app will stay in Customer mode.
        if (responseData['role'] != null) {
          userMap['role'] = responseData['role'];
        } else if (responseData['Role'] != null) {
          userMap['role'] = responseData['Role'];
        }

        // Write the updated user back to storage
        await prefs.setString('currentUser', jsonEncode(userMap));
        print("✅ Provider Application Submitted. Local data updated.");
      }
    }
  }

  Future<void> updateProviderProfile(ProviderData data) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/serviceproviders/profile');

    final bodyMap = {
      "bio": "Professional Service Provider",
      "serviceIds": data.getAllServiceIds(),
      "serviceAreaIds": data.getAllAreaIds(),
      "schedules": data.finalSchedule.expand((s) => s.toApiDto()).toList(),
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response.body));
    }
  }

  String _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded['message'] ?? decoded['title'] ?? body;
    } catch (_) {
      return body;
    }
  }
}
