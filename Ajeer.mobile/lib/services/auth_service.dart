// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../config/app_config.dart';

class AuthService {
  // Base URL for Auth Controller (Login, Register)
  static const String authUrl = '${AppConfig.apiUrl}/auth';

  Future<AuthResponse?> login(String identifier, String password) async {
    final url = Uri.parse('$authUrl/login');

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
        await _saveUserSession(authResponse);
        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ❌ REMOVED: updateProfile (Moved to UserService)

  Future<void> _saveUserSession(AuthResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', user.token);
    await prefs.setString(
      'currentUser',
      jsonEncode({
        'id': user.userId,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role,
        'profilePictureUrl': user.profilePictureUrl,
      }),
    );
  }

  Future<bool> register(UserRegisterRequest request) async {
    final url = Uri.parse('$authUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
