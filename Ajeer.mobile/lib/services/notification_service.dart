import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import '../../config/app_config.dart';
import '../../models/notification_model.dart';

class NotificationService {
  HubConnection? _hubConnection;
  final String _hubUrl = AppConfig.notificationHubUrl;
  final String _apiUrl = AppConfig.apiUrl;

  final _notificationController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  final _bookingUpdateController = StreamController<int>.broadcast();
  Stream<int> get bookingUpdateStream => _bookingUpdateController.stream;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getToken();

    try {
      final uri = Uri.parse('$_apiUrl/notifications');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('NOTIFICATIONS JSON: ${response.body}');

        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        print(
          'Failed to load notifications: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> initSignalR() async {
    if (_hubConnection?.state == HubConnectionState.connected) {
      return;
    }

    final token = await _getToken();
    if (token == null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('ReceiveNotification', (arguments) {
      try {
        if (arguments != null && arguments.isNotEmpty) {
          final rawData = arguments[0] as Map<String, dynamic>;
          final safeMap = Map<String, dynamic>.from(rawData);
          final notification = NotificationModel.fromJson(safeMap);
          _notificationController.add(notification);
        }
      } catch (e) {
        print("SignalR Parsing Error: $e");
      }
    });

    _hubConnection!.on('BookingUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final bookingId = arguments[0] as int;
        _bookingUpdateController.add(bookingId);
      }
    });

    try {
      await _hubConnection!.start();
      print("SignalR Connected");
    } catch (e) {
      print("SignalR Connection Error: $e");
    }
  }

  void disconnectSignalR() {
    _hubConnection?.stop();
  }

  void dispose() {
    _notificationController.close();
    _bookingUpdateController.close();
  }
}
