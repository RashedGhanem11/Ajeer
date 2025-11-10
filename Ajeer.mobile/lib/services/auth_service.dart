import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🔧 Later you will replace this URL with your real .NET API endpoint
  static const String baseUrl = 'https://your-api-url.com/api';

  /// Use this one later when backend is ready
  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.statusCode}');
    }
  }

  /// This is a mock version — it fakes the backend for now.
  Future<Map<String, dynamic>> mockSignUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    if (email.endsWith("@demo.com")) {
      return {'success': false, 'message': 'Email already registered'};
    }

    return {'success': true, 'message': 'Sign-up successful! Welcome aboard.'};
  }
}
