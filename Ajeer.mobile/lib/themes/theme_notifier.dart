import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< New Import

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'isDarkMode'; // <<< Key for storage

  ThemeNotifier() {
    // Load theme when the notifier is created
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Load the theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    // SharedPreferences.getInstance() is asynchronous
    final prefs = await SharedPreferences.getInstance();
    // Get the boolean value, default to false (light mode) if not found
    final isDark = prefs.getBool(_themeKey) ?? false;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners after theme mode is set
  }

  // Save the theme preference to SharedPreferences
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // Save the new theme mode
    _saveTheme(_themeMode == ThemeMode.dark);

    notifyListeners();
  }
}
