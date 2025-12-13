import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/customer_screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('currentUser');
  final bool isLoggedIn = userJson != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),

        // ✅ ADD THIS MISSING LINE:
        Provider(create: (_) => AuthService()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
          home: isLoggedIn
              ? HomeScreen(themeNotifier: themeNotifier)
              : const LoginScreen(),
        );
      },
    );
  }
}
