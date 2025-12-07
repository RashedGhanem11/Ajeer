// lib/services/service_category_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_models.dart';

class ServiceCategoryService {
  static const String baseUrl = 'http://localhost:5289/api/servicecategories';

  Future<List<ServiceCategory>> fetchCategories() async {
    final url = Uri.parse(baseUrl);

    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('authToken')}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => ServiceCategory.fromJson(json)).toList();
      } else {
        // Throw an exception for server errors (4xx, 5xx)
        throw Exception(
          'Failed to load services. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Throw an exception for network errors
      throw Exception('Network error fetching categories: ${e.toString()}');
    }
  }
}
