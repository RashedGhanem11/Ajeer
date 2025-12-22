import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  static const String _baseUrl = '${AppConfig.apiUrl}/Subscriptions';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/plans'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Future<SubscriptionStatus> getStatus() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/my-status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return SubscriptionStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load status');
    }
  }

  Future<PaymentIntentData> createPaymentIntent(int planId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/create-payment-intent/$planId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return PaymentIntentData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to initiate payment');
    }
  }
}
