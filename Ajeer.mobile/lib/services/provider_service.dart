import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/provider_data.dart';

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
    // 1. Get the OLD token (Customer token) to authorize the registration request
    final oldToken = await _getToken();
    final url = Uri.parse('$_baseUrl/serviceproviders/register');

    final bodyMap = {
      "bio": "Professional Service Provider",
      "serviceIds": data.getAllServiceIds(),
      "serviceAreaIds": data.getAllAreaIds(),
      "schedules": data.finalSchedule.expand((s) => s.toApiDto()).toList(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $oldToken',
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response.body));
    } else {
      // ✅ SUCCESS: Now we must update the local data to reflect the new Status

      final responseData = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // 1. SAVE NEW TOKEN (Critical for 403 fix)
      // The backend sends a NEW token with 'ServiceProvider' role. We must use this one now.
      final newToken = responseData['token'] ?? responseData['Token'];
      if (newToken != null) {
        await prefs.setString('authToken', newToken);
        print("✅ New Provider Token Saved!");
      }

      // 2. UPDATE STORED USER ROLE (Critical for Profile Screen update)
      // We load the existing user JSON, change the role, and save it back.
      final String? userJson = prefs.getString('currentUser');
      if (userJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userJson);

        // Update the role to what the server returned, or fallback to "ServiceProvider"
        // (This matches your C# AuthResponse which returns the updated User object)
        if (responseData['role'] != null) {
          userMap['role'] = responseData['role'];
        } else if (responseData['Role'] != null) {
          userMap['role'] = responseData['Role'];
        } else {
          // Fallback if backend didn't send role explicitly, but we know it succeeded
          userMap['role'] = 'ServiceProvider';
        }

        // Write the updated user back to storage
        await prefs.setString('currentUser', jsonEncode(userMap));
        print("✅ Local User Role updated to ServiceProvider");
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
