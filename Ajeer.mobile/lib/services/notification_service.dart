import '../../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

class NotificationService {
  HubConnection? _hubConnection;
  final String _hubUrl = AppConfig.notificationHubUrl;


  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  final _bookingUpdateController = StreamController<int>.broadcast();
  Stream<int> get bookingUpdateStream => _bookingUpdateController.stream;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> initSignalR() async {
    print("DEBUG: initSignalR() called. Checking connection state..."); // <--- Add this

    if (_hubConnection?.state == HubConnectionState.connected)
    {
      print("DEBUG: Already connected. Exiting.");
     return;
    }

    final token = await _getToken();
    print("DEBUG: Token retrieved: ${token != null ? 'Yes (Length: ${token.length})' : 'NULL'}"); // <--- Add this
    if (token == null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    // --- FIX STARTS HERE ---
    _hubConnection!.on('ReceiveNotification', (arguments) {
      // 1. Debug Print: See exactly what the server sent
      print("SIGNALR DEBUG: ReceiveNotification fired. Data: $arguments");

      try {
        if (arguments != null && arguments.isNotEmpty) {
          // 2. Safe Casting: Convert whatever map we get to Map<String, dynamic>
          // SignalR often sends Map<dynamic, dynamic>, which crashes if you cast directly to Map<String, dynamic>
          final rawData = arguments[0] as Map;
          final safeData = Map<String, dynamic>.from(rawData);

          // 3. Pass to Stream
          _notificationController.add(safeData);
        }
      } catch (e) {
        print("SIGNALR ERROR: Failed to parse notification data: $e");
      }
    });
    // --- FIX ENDS HERE ---

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