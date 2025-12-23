import '../../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

class NotificationService {
  HubConnection? _hubConnection;
  final String _hubUrl = AppConfig.notificationHubUrl;

  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  final _bookingUpdateController = StreamController<int>.broadcast();
  Stream<int> get bookingUpdateStream => _bookingUpdateController.stream;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
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
          final rawData = arguments[0] as Map;
          final safeData = Map<String, dynamic>.from(rawData);
          _notificationController.add(safeData);
        }
      } catch (e) {
        print("SIGNALR ERROR: Failed to parse notification data: $e");
      }
    });

    _hubConnection!.on('BookingUpdated', (arguments) {
      print("SIGNALR DEBUG: BookingUpdated fired for ID: $arguments");
      if (arguments != null && arguments.isNotEmpty) {
        final bookingId = arguments[0] as int;
        _bookingUpdateController.add(bookingId);
      }
    });

    try {
      await _hubConnection!.start();
      print("SignalR Connected!");
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
