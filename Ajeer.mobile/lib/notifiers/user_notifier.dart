import 'package:flutter/foundation.dart';
import '../models/provider_data.dart';

enum UserMode { customer, provider }

class UserNotifier extends ChangeNotifier {
  UserMode _userMode = UserMode.customer;
  bool _isProviderSetupComplete = false;
  ProviderData? _providerData;

  UserMode get userMode => _userMode;
  bool get isProviderSetupComplete => _isProviderSetupComplete;
  ProviderData? get providerData => _providerData;

  bool get isProvider => _userMode == UserMode.provider;

  void toggleUserMode() {
    if (_isProviderSetupComplete) {
      _userMode = _userMode == UserMode.customer
          ? UserMode.provider
          : UserMode.customer;
      notifyListeners();
    }
  }

  void completeProviderSetup(ProviderData data) {
    _providerData = data;
    _isProviderSetupComplete = true;
    _userMode = UserMode.provider;
    notifyListeners();
  }
}
