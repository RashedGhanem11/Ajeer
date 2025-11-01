import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF1976D2),
  scaffoldBackgroundColor: Colors.grey[50],
  cardColor: Colors.white,
  textTheme: const TextTheme(
    headlineSmall: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1976D2),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    // FIX: Replaced MaterialStateProperty with WidgetStateProperty
    thumbColor: WidgetStateProperty.all(const Color(0xFF1976D2)),
    trackColor: WidgetStateProperty.all(const Color(0xFF8CCBFF)),
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  ).copyWith(secondary: const Color(0xFF8CCBFF)),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF8CCBFF),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    // FIX: Replaced MaterialStateProperty with WidgetStateProperty
    thumbColor: WidgetStateProperty.all(const Color(0xFF8CCBFF)),
    trackColor: WidgetStateProperty.all(const Color(0xFF1976D2)),
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  ).copyWith(secondary: const Color(0xFF1976D2)),
);
