import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_data.dart';

enum UserMode { customer, provider }

class UserNotifier extends ChangeNotifier {
  UserMode _userMode = UserMode.customer;
  bool _isProviderSetupComplete = false;
  ProviderData? _providerData;
  static const String _modeKey = 'userModeIndex';

  UserNotifier() {
    _loadUserMode();
  }

  UserMode get userMode => _userMode;
  bool get isProviderSetupComplete => _isProviderSetupComplete;
  ProviderData? get providerData => _providerData;

  bool get isProvider => _userMode == UserMode.provider;

  Future<void> _loadUserMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_modeKey) ?? 0;
    _userMode = UserMode.values[modeIndex];
    notifyListeners();
  }

  Future<void> _saveUserMode(UserMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
  }

  void toggleUserMode() {
    if (_isProviderSetupComplete) {
      _userMode = _userMode == UserMode.customer
          ? UserMode.provider
          : UserMode.customer;

      _saveUserMode(_userMode);
      notifyListeners();
    }
  }

  void completeProviderSetup(ProviderData data) {
    _providerData = data;
    _isProviderSetupComplete = true;
    _userMode = UserMode.provider;

    _saveUserMode(_userMode);
    notifyListeners();
  }

  void updateProviderData(ProviderData data) {
    _providerData = data;
    notifyListeners();
  }
}
