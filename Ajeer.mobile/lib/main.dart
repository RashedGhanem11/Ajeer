import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

// ✅ IMPORT PROFILE SCREEN
import 'screens/shared_screens/profile_screen.dart';

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
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserService()),
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
          // ✅ CHANGE THIS LINE: Use ProfileScreen as the home
          home: isLoggedIn
              ? ProfileScreen(themeNotifier: themeNotifier)
              : const LoginScreen(),
        );
      },
    );
  }
}
