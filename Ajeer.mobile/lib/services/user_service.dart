import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/change_password_request.dart';

class UserService {
  static const String baseUrl = '${AppConfig.apiUrl}/Users';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

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
        await _updateLocalSession(updatedUser);

        return updatedUser;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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

  Future<void> _updateLocalSession(AuthResponse user) async {
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
