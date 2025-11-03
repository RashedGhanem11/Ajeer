import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< Import SharedPreferences
import '../models/provider_data.dart';

enum UserMode { customer, provider }

class UserNotifier extends ChangeNotifier {
  UserMode _userMode = UserMode.customer;
  bool _isProviderSetupComplete = false;
  ProviderData? _providerData;
  static const String _modeKey = 'userModeIndex'; // <<< Key for storage

  UserNotifier() {
    _loadUserMode(); // <<< Load mode when the notifier is created
  }

  UserMode get userMode => _userMode;
  bool get isProviderSetupComplete => _isProviderSetupComplete;
  ProviderData? get providerData => _providerData;

  bool get isProvider => _userMode == UserMode.provider;

  // Load user mode from SharedPreferences
  Future<void> _loadUserMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the integer index, default to 0 (UserMode.customer) if not found.
    final modeIndex = prefs.getInt(_modeKey) ?? 0;
    // Map the index back to the UserMode enum value
    _userMode = UserMode.values[modeIndex];
    notifyListeners();
  }

  // Save user mode to SharedPreferences
  Future<void> _saveUserMode(UserMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // Save the enum's index
    await prefs.setInt(_modeKey, mode.index);
  }

  void toggleUserMode() {
    if (_isProviderSetupComplete) {
      _userMode = _userMode == UserMode.customer
          ? UserMode.provider
          : UserMode.customer;

      _saveUserMode(_userMode); // <<< Save the new mode
      notifyListeners();
    }
  }

  void completeProviderSetup(ProviderData data) {
    _providerData = data;
    _isProviderSetupComplete = true;
    _userMode = UserMode.provider;

    _saveUserMode(_userMode); // <<< Save the new mode
    notifyListeners();
  }
}
