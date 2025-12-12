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
      } else if (response.statusCode == 404) {
        // User not found in ServiceProviders table
        return null;
      } else if (response.statusCode == 403) {
        // User missing 'ServiceProvider' Role
        return null;
      } else {
        // Handle server errors silently or log to a crashlytics service
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // POST/PUT: Register as new provider or Update existing profile
  Future<void> updateProviderProfile(ProviderData data) async {
    final token = await _getToken();

    bool isUpdate = data.getAllServiceIds().isNotEmpty;
    final String endpoint = isUpdate ? 'profile' : 'register';

    final url = Uri.parse('$_baseUrl/serviceproviders/$endpoint');

    final bodyMap = {
      "bio": "Professional Service Provider",
      "serviceIds": data.getAllServiceIds(),
      "serviceAreaIds": data.getAllAreaIds(),
      "schedules": data.finalSchedule.expand((s) => s.toApiDto()).toList(),
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;
    if (isUpdate) {
      response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(bodyMap),
      );
    } else {
      response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodyMap),
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed: ${response.body}');
    }
  }
}
