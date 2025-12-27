import 'package:flutter/material.dart';

class AppNotificationNotifier extends ChangeNotifier {
  int _unreadChatCount = 0;
  int _activeBookingsCount = 0;

  int get unreadChatCount => _unreadChatCount;
  int get activeBookingsCount => _activeBookingsCount;

  void updateUnreadChats(int count) {
    _unreadChatCount = count;
    notifyListeners();
  }

  void updateActiveBookings(int count) {
    _activeBookingsCount = count;
    notifyListeners();
  }
}
