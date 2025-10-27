import 'package:flutter/material.dart';
// This path is new and matches your folder structure:
import 'screens/customer_screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Start the app at the LoginScreen
      home: LoginScreen(),
    );
  }
}
