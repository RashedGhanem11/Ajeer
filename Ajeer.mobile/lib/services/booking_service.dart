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
  // --- CREATE BOOKING (Unchanged) ---
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
      request.fields['ServiceIds'] = id.toString();
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
      if (token != null)
        request.headers.addAll({'Authorization': 'Bearer $token'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingResult(
          success: true,
          message: 'Booking confirmed successfully!',
        );
      } else {
        return BookingResult(success: false, message: response.body);
      }
    } catch (e) {
      return BookingResult(success: false, message: 'Connection error.');
    }
  }

  // --- GET BOOKINGS (Fixed: Added ?role=customer) ---
  Future<List<BookingListItem>> getBookings() async {
    // FIX: Added query parameter 'role=customer'
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings?role=customer');

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
        print(
          'Error fetching bookings: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Exception fetching bookings: $e');
      return [];
    }
  }

  // --- GET DETAILS (Unchanged) ---
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
      print('Exception fetching details: $e');
    }
    return null;
  }

  // --- CANCEL BOOKING (Fixed: Changed POST to PUT) ---
  Future<bool> cancelBooking(int id) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/bookings/$id/cancel');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      // FIX: Changed from http.post to http.put to match Controller
      final response = await http.put(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception cancelling booking: $e');
      return false;
    }
  }
}
