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

  // GET: Fetch the provider profile
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
        // Returns null if 404 (Not Found) or 403 (Not a Provider)
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: Explicit Register Method (POST)
  // Calls 'api/serviceproviders/register'
  Future<void> registerProvider(ProviderData data) async {
    final token = await _getToken();
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
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response.body));
    }
  }

  // ✅ NEW: Explicit Update Method (PUT)
  // Calls 'api/serviceproviders/profile'
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

  // Helper to read backend errors safely
  String _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      // Check for common error fields
      return decoded['message'] ?? decoded['title'] ?? body;
    } catch (_) {
      return body;
    }
  }
}
