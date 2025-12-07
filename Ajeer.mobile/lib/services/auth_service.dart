// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  // Replace with your actual backend URL (use 10.0.2.2 for Android emulator)
  static const String baseUrl = 'http://localhost:5289/api/auth';

  Future<AuthResponse?> login(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          LoginRequest(identifier: identifier, password: password).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        // Save Session Data
        await _saveUserSession(authResponse);

        return authResponse;
      } else {
        // Parse backend error message if available
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Re-throw to be handled by the UI
      throw Exception(e.toString());
    }
  }

  Future<void> _saveUserSession(AuthResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    // Save the Token specifically for future API calls
    await prefs.setString('authToken', user.token);
    // Save user details for the UI
    await prefs.setString(
      'currentUser',
      jsonEncode({
        'id': user.userId,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role,
      }),
    );
  }

  // Add this method to your existing AuthService class
  Future<bool> register(UserRegisterRequest request) async {
    final url = Uri.parse(
      '$baseUrl/register',
    ); // Adjust endpoint path if needed

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Registration successful
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
