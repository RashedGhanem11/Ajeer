import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/customer_screens/login_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';
import 'notifiers/language_notifier.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
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
        ChangeNotifierProvider(create: (_) => LanguageNotifier()),
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
    return Consumer2<ThemeNotifier, LanguageNotifier>(
      builder: (context, themeNotifier, languageNotifier, child) {
        final String? currentFont = languageNotifier.currentFontFamily;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ajeer App',
          theme: lightTheme.copyWith(
            textTheme: currentFont != null
                ? lightTheme.textTheme.apply(fontFamily: currentFont)
                : lightTheme.textTheme,
            primaryTextTheme: currentFont != null
                ? lightTheme.primaryTextTheme.apply(fontFamily: currentFont)
                : lightTheme.primaryTextTheme,
          ),
          darkTheme: darkTheme.copyWith(
            textTheme: currentFont != null
                ? darkTheme.textTheme.apply(fontFamily: currentFont)
                : darkTheme.textTheme,
            primaryTextTheme: currentFont != null
                ? darkTheme.primaryTextTheme.apply(fontFamily: currentFont)
                : darkTheme.primaryTextTheme,
          ),
          themeMode: themeNotifier.themeMode,
          locale: languageNotifier.appLocale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
            Locale('ar', 'EG'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: isLoggedIn
              ? ProfileScreen(themeNotifier: themeNotifier)
              : const LoginScreen(),
        );
      },
    );
  }
}
