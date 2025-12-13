import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/review_models.dart';

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

  // Added method to fetch review details
  Future<ReviewResponse?> getReview(int bookingId) async {
    // Endpoint based on ReviewsController [HttpGet("booking/{bookingId}")]
    final uri = Uri.parse('${AppConfig.apiUrl}/Reviews/booking/$bookingId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Handle 204 No Content (No review exists)
      if (response.statusCode == 204) {
        return null;
      }
      // Handle 200 OK (Review exists)
      else if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewResponse.fromJson(data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
