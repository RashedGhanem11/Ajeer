// lib/services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart'; // For AuthResponse
import '../models/change_password_request.dart'; // The new model

class UserService {
  // Base URL: .../api/Users
  static const String baseUrl = '${AppConfig.apiUrl}/Users';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // 1. Update Profile (Moved from AuthService)
  Future<AuthResponse?> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/profile');
    final request = http.MultipartRequest('PUT', url);

    request.headers.addAll({'Authorization': 'Bearer $token'});

    request.fields['Name'] = name;
    request.fields['Email'] = email;
    request.fields['Phone'] = phone;

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
        final updatedUser = AuthResponse.fromJson(data);

        // Update local storage
        await _updateLocalSession(updatedUser);

        return updatedUser;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 2. Change Password (New Method)
  Future<void> changePassword(ChangePasswordRequest requestModel) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/change-password');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestModel.toJson()),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // Helper: Update SharedPreferences
  Future<void> _updateLocalSession(AuthResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    // We update everything except the token if backend returns a new one,
    // but usually profile update might return same token or new one depending on implementation.
    // If backend refreshes token on update, save it:
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

  // Helper: Error Handler
  Exception _handleError(http.Response response) {
    String errorMsg = 'Request failed (${response.statusCode})';
    try {
      final error = jsonDecode(response.body);
      errorMsg = error['message'] ?? errorMsg;
    } catch (_) {
      if (response.body.isNotEmpty) errorMsg = response.body;
    }
    return Exception(errorMsg);
  }
}
