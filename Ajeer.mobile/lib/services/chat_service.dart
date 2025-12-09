import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';
import '../config/app_config.dart';

class ChatService {
  final String _apiUrl = AppConfig.apiUrl;
  final String _hubUrl = AppConfig.hubUrl;

  HubConnection? _hubConnection;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<ChatConversation>> getConversations() async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$_apiUrl/chats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatConversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  Future<List<ChatMessage>> getMessages(int bookingId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$_apiUrl/chats/$bookingId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<ChatMessage> sendMessage(int bookingId, String content) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/chats/$bookingId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_apiUrl/chats/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  Future<void> markAsRead(int messageId) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_apiUrl/chats/messages/$messageId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as read');
    }
  }

  Future<void> initSignalR({
    required Function(ChatMessage) onMessageReceived,
    required Function(int) onMessageDeleted,
    required Function(int) onMessageRead,
  }) async {
    final token = await _getToken();
    if (token == null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('ReceiveNewMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageMap = arguments[0] as Map<String, dynamic>;
        onMessageReceived(ChatMessage.fromJson(messageMap));
      }
    });

    _hubConnection!.on('MessageDeleted', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final id = arguments[0] as int;
        onMessageDeleted(id);
      }
    });

    _hubConnection!.on('MessageRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final id = arguments[0] as int;
        onMessageRead(id);
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
}
