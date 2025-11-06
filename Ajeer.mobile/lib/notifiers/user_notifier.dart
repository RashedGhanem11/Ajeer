import 'dart:convert'; // ✅ Add this
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_data.dart';

enum UserMode { customer, provider }

class UserNotifier extends ChangeNotifier {
  UserMode _userMode = UserMode.customer;
  bool _isProviderSetupComplete = false;
  ProviderData? _providerData;

  static const String _modeKey = 'userModeIndex';
  static const String _setupCompleteKey = 'isProviderSetupComplete';
  static const String _providerDataKey = 'providerData';

  UserNotifier() {
    _loadUserData();
  }

  UserMode get userMode => _userMode;
  bool get isProviderSetupComplete => _isProviderSetupComplete;
  ProviderData? get providerData => _providerData;

  bool get isProvider => _userMode == UserMode.provider;

  // ✅ Load user mode, provider data, and setup state
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final modeIndex = prefs.getInt(_modeKey) ?? 0;
    _userMode = UserMode.values[modeIndex];

    _isProviderSetupComplete = prefs.getBool(_setupCompleteKey) ?? false;

    final providerJson = prefs.getString(_providerDataKey);
    if (providerJson != null && providerJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(providerJson);
        _providerData = ProviderData.fromJson(decoded);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error loading provider data: $e');
        }
      }
    }

    notifyListeners();
  }

  // ✅ Save user mode to SharedPreferences
  Future<void> _saveUserMode(UserMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
  }

  // ✅ Save full provider data persistently
  Future<void> _saveProviderData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_providerData != null) {
      await prefs.setString(
        _providerDataKey,
        jsonEncode(_providerData!.toJson()),
      );
    }
    await prefs.setBool(_setupCompleteKey, _isProviderSetupComplete);
  }

  // ✅ Switch between modes only if provider setup is done
  void toggleUserMode() {
    if (_isProviderSetupComplete) {
      _userMode = _userMode == UserMode.customer
          ? UserMode.provider
          : UserMode.customer;

      _saveUserMode(_userMode);
      notifyListeners();
    }
  }

  // ✅ Called after provider completes setup
  Future<void> completeProviderSetup(ProviderData data) async {
    _providerData = data;
    _isProviderSetupComplete = true;
    _userMode = UserMode.provider;

    await _saveUserMode(_userMode);
    await _saveProviderData();

    notifyListeners();
  }

  // ✅ Update existing provider data and re-save it
  Future<void> updateProviderData(ProviderData data) async {
    _providerData = data;
    await _saveProviderData();
    notifyListeners();
  }

  // ✅ Optional: clear provider data completely
  Future<void> clearProviderData() async {
    _providerData = null;
    _isProviderSetupComplete = false;
    _userMode = UserMode.customer;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_providerDataKey);
    await prefs.remove(_setupCompleteKey);
    await prefs.setInt(_modeKey, _userMode.index);

    notifyListeners();
  }
}
