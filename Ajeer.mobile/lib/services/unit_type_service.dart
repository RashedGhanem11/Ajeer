import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_models.dart';
import '../config/app_config.dart';

class UnitTypeService {
  static const String apiUrl = AppConfig.apiUrl;
  static const String _baseUrl = '$apiUrl/services';

  Future<List<ServiceItem>> fetchServicesByCategory(int categoryId) async {
    final url = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'categoryId': categoryId.toString()});

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((json) => ServiceItem.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load services. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }
}
