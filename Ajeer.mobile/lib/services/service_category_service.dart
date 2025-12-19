import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_models.dart';
import '../config/app_config.dart';

class ServiceCategoryService {
  static const String apiUrl = AppConfig.apiUrl;
  static const String baseUrl = '$apiUrl/servicecategories';
  static const String servicesUrl = '$apiUrl/services';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => ServiceCategory.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load categories. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error fetching categories: $e');
    }
  }

  Future<List<ServiceItem>> fetchServicesForCategory(int categoryId) async {
    final token = await _getToken();
    final url = Uri.parse('$servicesUrl?categoryId=$categoryId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => ServiceItem.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load services. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error fetching services: $e');
    }
  }
}
