import 'package:flutter/material.dart';
import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart'; // Make sure this file exists!
import 'themes/theme_notifier.dart'; // Make sure this file exists!

// FIX 1: Initialize themeNotifier globally so login_screen can access it.
final ThemeNotifier themeNotifier = ThemeNotifier();

void main() {
  // FIX 2: Pass themeNotifier to MyApp.
  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    // FIX 3: Use AnimatedBuilder to rebuild the app when the theme changes.
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ajeer App',
          theme: lightTheme, // Defined in app_themes.dart
          darkTheme: darkTheme, // Defined in app_themes.dart
          themeMode:
              themeNotifier.themeMode, // Set theme mode based on notifier
          home: const LoginScreen(),
        );
      },
    );
  }
}
