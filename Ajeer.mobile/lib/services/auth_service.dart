// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
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

  // ✅ CORRECTED: Update Profile Method
  // Hits 'api/Users/profile' instead of 'api/auth/...'
  Future<AuthResponse?> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) throw Exception('No authentication token found');

    // 👇 THIS IS THE FIX: Point to UsersController
    final url = Uri.parse('${AppConfig.apiUrl}/Users/profile');

    final request = http.MultipartRequest('PUT', url);

    request.headers.addAll({'Authorization': 'Bearer $token'});

    // Add fields matching UpdateUserProfileRequest.cs
    request.fields['Name'] = name;
    request.fields['Email'] = email;
    request.fields['Phone'] = phone;

    // Add file if exists
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('ProfileImage', profileImage.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure backend returns the updated AuthResponse format
        final updatedUser = AuthResponse.fromJson(data);

        await _saveUserSession(updatedUser);
        return updatedUser;
      } else {
        // Detailed error handling
        String errorMsg = 'Update failed (${response.statusCode})';
        try {
          final error = jsonDecode(response.body);
          errorMsg = error['message'] ?? errorMsg;
        } catch (_) {
          // If body isn't JSON, use the raw body text
          if (response.body.isNotEmpty) errorMsg = response.body;
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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
    final url = Uri.parse('$authUrl/register'); // Uses authUrl

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
