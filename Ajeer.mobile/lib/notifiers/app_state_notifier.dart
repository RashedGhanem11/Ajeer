import 'package:flutter/material.dart';

class AppStateNotifier extends ChangeNotifier {
  bool _isBookingScreenActive = false;

  bool get isBookingScreenActive => _isBookingScreenActive;

  void setBookingScreenActive(bool isActive) {
    _isBookingScreenActive = isActive;
    notifyListeners();
  }
}