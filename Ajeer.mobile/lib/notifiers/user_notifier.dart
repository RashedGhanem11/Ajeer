import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_data.dart';
import '../services/provider_service.dart';

enum UserMode { customer, provider }

class UserNotifier extends ChangeNotifier {
  UserMode _userMode = UserMode.customer;
  bool _isProviderSetupComplete = false;
  ProviderData? _providerData;

  static const String _userModeKey = 'last_user_mode';
  final ProviderService _apiService = ProviderService();

  UserNotifier() {
    loadUserData();
  }

  UserMode get userMode => _userMode;
  bool get isProviderSetupComplete => _isProviderSetupComplete;
  ProviderData? get providerData => _providerData;
  bool get isProvider => _userMode == UserMode.provider;

  Future<void> loadUserData() async {
    try {
      final data = await _apiService.getProviderProfile();
      final prefs = await SharedPreferences.getInstance();

      if (data != null) {
        _providerData = data;
        _isProviderSetupComplete = true;

        final int lastModeIndex = prefs.getInt(_userModeKey) ?? 0;
        _userMode = lastModeIndex == 1 ? UserMode.provider : UserMode.customer;
      } else {
        _providerData = null;
        _isProviderSetupComplete = false;
        _userMode = UserMode.customer;
      }
    } catch (e) {
      if (kDebugMode) print("Error loading profile: $e");
    }
    notifyListeners();
  }

  Future<void> completeProviderSetup(ProviderData data) async {
    await _saveToBackend(data);
  }

  Future<void> updateProviderData(ProviderData data) async {
    await _saveToBackend(data);
  }

  Future<void> _saveToBackend(ProviderData data) async {
    try {
      await _apiService.updateProviderProfile(data);
      final prefs = await SharedPreferences.getInstance();

      _providerData = data;
      _isProviderSetupComplete = true;
      _userMode = UserMode.provider;

      await prefs.setInt(_userModeKey, UserMode.provider.index);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserMode() async {
    if (_isProviderSetupComplete) {
      _userMode = _userMode == UserMode.customer
          ? UserMode.provider
          : UserMode.customer;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userModeKey, _userMode.index);

      notifyListeners();
    }
  }
}
