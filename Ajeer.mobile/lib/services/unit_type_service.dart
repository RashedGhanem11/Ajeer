// lib/services/unit_type_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_models.dart';

class UnitTypeService {
  // Use /api/services as the base URL
  static const String _baseUrl = 'http://localhost:5289/api/services';

  Future<List<ServiceItem>> fetchServicesByCategory(int categoryId) async {
    // 1. THIS IS WHERE YOU ADD THE PARAMETER:
    // This creates the URL: http://localhost:5289/api/services?categoryId=X
    final url = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'categoryId': categoryId.toString()});

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.get(
        url, // Use the constructed URL with the query string
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        // Ensure ServiceItem model is created in service_models.dart (from previous response)
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
