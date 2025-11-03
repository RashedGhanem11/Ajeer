import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          home: const LoginScreen(),
        );
      },
    );
  }
}
