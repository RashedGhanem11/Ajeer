import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/customer_screens/home_screen.dart';

// 1. Make the main function asynchronous
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('currentUser');
  final bool isLoggedIn = userJson != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),
      ],
      // 👇 Pass whether the user is logged in to MyApp
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // 👈 Add this line

  const MyApp({super.key, required this.isLoggedIn}); // 👈 Update constructor

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ajeer App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          // 👇 If user is logged in, skip LoginScreen
          home: isLoggedIn
              ? HomeScreen(themeNotifier: themeNotifier)
              : const LoginScreen(),
        );
      },
    );
  }
}
