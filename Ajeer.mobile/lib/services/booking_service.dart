import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/booking_models.dart';

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

    request.fields['ServiceAreaId'] = serviceAreaId.toString();
    request.fields['Address'] = address;
    request.fields['Latitude'] = latitude.toString();
    request.fields['Longitude'] = longitude.toString();
    request.fields['ScheduledDate'] = scheduledDate.toIso8601String();
    if (notes != null) request.fields['Notes'] = notes;

    for (var id in serviceIds) {
      request.files.add(
        http.MultipartFile.fromString('ServiceIds', id.toString()),
      );
    }

    if (attachments != null) {
      for (var file in attachments) {
        request.files.add(
          await http.MultipartFile.fromPath('Attachments', file.path),
        );
      }
    }

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
        String errorMessage = response.body;
        try {
          final Map<String, dynamic> decoded = jsonDecode(response.body);
          if (decoded.containsKey('message')) {
            errorMessage = decoded['message'];
          }
        } catch (_) {}

        return BookingResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return BookingResult(success: false, message: 'Connection error.');
    }
  }

  Future<List<BookingListItem>> getBookings({String role = 'customer'}) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings?role=$role');

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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingListItem.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<BookingDetail?> getBookingDetails(int id) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings/$id');

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

      if (response.statusCode == 200) {
        return BookingDetail.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  Future<bool> cancelBooking(int id) async {
    return _sendRequest('$id/cancel');
  }

  Future<bool> acceptBooking(int id) async {
    return _sendRequest('$id/accept');
  }

  Future<bool> rejectBooking(int id) async {
    return _sendRequest('$id/reject');
  }

  Future<bool> completeBooking(int id) async {
    return _sendRequest('$id/complete');
  }

  Future<bool> _sendRequest(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings/$endpoint');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.put(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
