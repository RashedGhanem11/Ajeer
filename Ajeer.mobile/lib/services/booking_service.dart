import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BookingService {
  Future<bool> createBooking({
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

    // 2. Add List<int> ServiceIds
    // ASP.NET Core default model binding handles multiple fields with the same name as a List
    for (var id in serviceIds) {
      request.fields['ServiceIds'] = id.toString();
      // Note: If backend expects indexed keys, use: request.fields['ServiceIds[$i]'] = id.toString();
    }

    // 3. Add Attachments
    if (attachments != null) {
      for (var file in attachments) {
        // You might need to adjust the field name 'Attachments' based on your exact controller signature,
        // but typically it matches the property name in the DTO.
        request.files.add(
          await http.MultipartFile.fromPath('Attachments', file.path),
        );
      }
    }

    // 4. Send Request (Add Authorization header here if needed later)
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error creating booking: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception creating booking: $e');
      return false;
    }
  }
}
