import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/review_models.dart';

class ReviewResult {
  final bool success;
  final String message;

  ReviewResult({required this.success, required this.message});
}

class ReviewService {
  Future<ReviewResult> submitReview(CreateReviewRequest request) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/Reviews');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Unknown error occurred';

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewResult(success: true, message: message);
      } else {
        return ReviewResult(success: false, message: message);
      }
    } catch (e) {
      return ReviewResult(success: false, message: 'Connection error');
    }
  }
}
