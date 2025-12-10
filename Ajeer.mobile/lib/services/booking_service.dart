import 'dart:io';
import 'dart:convert'; // Added for JSON decoding
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingResult {
  final bool success;
  final String message;

  BookingResult({required this.success, required this.message});
}

class BookingService {
  Future<BookingResult> createBooking({
    required List<int> serviceIds,
    required int serviceAreaId,
    required DateTime scheduledDate,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
    List<File>? attachments,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings');

    var request = http.MultipartRequest('POST', uri);

    // 1. Add Simple Fields
    request.fields['ServiceAreaId'] = serviceAreaId.toString();
    request.fields['Address'] = address;
    request.fields['Latitude'] = latitude.toString();
    request.fields['Longitude'] = longitude.toString();
    request.fields['ScheduledDate'] = scheduledDate.toIso8601String();
    if (notes != null) {
      request.fields['Notes'] = notes;
    }

    // 2. Add ServiceIds
    for (var id in serviceIds) {
      request.fields['ServiceIds'] = id.toString();
    }

    // 3. Add Attachments
    if (attachments != null) {
      for (var file in attachments) {
        request.files.add(
          await http.MultipartFile.fromPath('Attachments', file.path),
        );
      }
    }

    // 4. Send Request
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token != null) {
        request.headers.addAll({'Authorization': 'Bearer $token'});
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingResult(
          success: true,
          message: 'Booking confirmed successfully!',
        );
      } else {
        // --- ERROR PARSING LOGIC ---
        String errorMsg = 'Failed to create booking.';

        try {
          if (response.body.isNotEmpty) {
            final decoded = jsonDecode(response.body);

            // Check if it's the standard ASP.NET validation error format
            if (decoded is Map<String, dynamic> &&
                decoded.containsKey('errors')) {
              final errors = decoded['errors'] as Map<String, dynamic>;

              // Extract all error messages into a single list
              List<String> messages = [];
              errors.forEach((key, value) {
                if (value is List) {
                  messages.addAll(value.map((e) => e.toString()));
                }
              });

              if (messages.isNotEmpty) {
                // Join them with newlines so the user sees all issues
                errorMsg = messages.join('\n');
              }
            } else if (decoded is Map<String, dynamic> &&
                decoded.containsKey('title')) {
              // Sometimes it's just a general error with a 'title' but no 'errors'
              errorMsg = decoded['title'];
            } else {
              // Fallback if structure is different
              errorMsg = response.body;
            }
          }
        } catch (e) {
          // If JSON parsing fails, just use the raw body or default text
          print("Error parsing error response: $e");
          if (response.body.isNotEmpty) errorMsg = response.body;
        }

        return BookingResult(success: false, message: errorMsg);
      }
    } catch (e) {
      print('Exception creating booking: $e');
      return BookingResult(
        success: false,
        message: 'Connection error: Please check your internet.',
      );
    }
  }
}
