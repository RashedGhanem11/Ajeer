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

  void clearData() {
    _providerData = null;
    _isProviderSetupComplete = false;
    _userMode = UserMode.customer;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    try {
      final data = await _apiService.getProviderProfile();
      final prefs = await SharedPreferences.getInstance();

      if (data != null) {
        _providerData = data;
        _isProviderSetupComplete = true;

        final int lastModeIndex = prefs.getInt(_userModeKey) ?? 0;
        _userMode = lastModeIndex == 1 ? UserMode.provider : UserMode.customer;
      }
      // ✅ CHANGE: Don't wipe data immediately if data is null (could be network error)
      // Only wipe if you specifically get a 404/403 which we can't easily distinguish here
      // without changing the service return type.
      // For now, removing the 'else' block or being more selective is safer,
      // but the ProfileScreen fix above is the most critical one.
    } catch (e) {
      if (kDebugMode) print("Error loading profile: $e");
    }
    notifyListeners();
  }

  // ✅ REGISTER: Called when becoming a provider for the first time
  // Update this method in UserNotifier.dart

  Future<void> completeProviderSetup(ProviderData data) async {
    try {
      // Try to register
      await _apiService.registerProvider(data);
      await _updateLocalState(data, isNewProvider: true);
    } catch (e) {
      // ✅ NEW: Handle "Already registered" error
      if (e.toString().contains("already registered") ||
          e.toString().contains("already a service provider")) {
        // If backend says we exist, just fetch the existing profile!
        await loadUserData();

        // If we successfully loaded data, switch mode and return success
        if (_isProviderSetupComplete) {
          final prefs = await SharedPreferences.getInstance();
          _userMode = UserMode.provider;
          await prefs.setInt(_userModeKey, UserMode.provider.index);
          notifyListeners();
          return; // Exit successfully
        }
      }

      // If it wasn't that error, or fetching failed, rethrow the error
      rethrow;
    }
  }

  // ✅ UPDATE: Called when editing existing provider details
  Future<void> updateProviderData(ProviderData data) async {
    try {
      // 1. Call the explicit UPDATE method
      await _apiService.updateProviderProfile(data);

      // 2. Update Local State (isNewProvider = false)
      await _updateLocalState(data, isNewProvider: false);
    } catch (e) {
      rethrow;
    }
  }

  // Helper to update state and SharedPreferences
  Future<void> _updateLocalState(
    ProviderData data, {
    required bool isNewProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _providerData = data;
    _isProviderSetupComplete = true;

    // If new provider, auto-switch to provider mode
    if (isNewProvider) {
      _userMode = UserMode.provider;
      await prefs.setInt(_userModeKey, UserMode.provider.index);
    }

    notifyListeners();
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
