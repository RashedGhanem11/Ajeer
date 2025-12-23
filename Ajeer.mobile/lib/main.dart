import 'package:ajeer_mobile/notifiers/app_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/shared_screens/app_launcher_screen.dart';
import 'themes/app_themes.dart';
import 'themes/theme_notifier.dart';
import 'notifiers/user_notifier.dart';
import 'notifiers/language_notifier.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/subscription_service.dart';
import 'services/notification_service.dart'; // Import the new service

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),

        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserService()),
        Provider(create: (_) => SubscriptionService()),
        Provider(create: (_) => NotificationService()), 
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
          navigatorKey: navigatorKey,
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
          builder: (context, child) {
            return GlobalNotificationWrapper(child: child!);
          },
          home: AppLauncherScreen(
            isLoggedIn: isLoggedIn,
            themeNotifier: themeNotifier,
          ),
        );
      },
    );
  }
}

class GlobalNotificationWrapper extends StatefulWidget {
  final Widget child;
  const GlobalNotificationWrapper({super.key, required this.child});

  @override
  State<GlobalNotificationWrapper> createState() => _GlobalNotificationWrapperState();
}

class _GlobalNotificationWrapperState extends State<GlobalNotificationWrapper> {
  @override
  void initState() {
    super.initState();
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    notificationService.initSignalR();

    notificationService.notificationStream.listen((data) {
      _showToast(data);
    });
  }

  void _showToast(Map<String, dynamic> data) {
    // This safety check is still good, but now 'mounted' should usually be true!
    if (!mounted) return; 

    print("TOAST DEBUG: Logic started.");

    // 1. Check Traffic Light
    final isBookingActive = Provider.of<AppStateNotifier>(context, listen: false).isBookingScreenActive;
    print("TOAST DEBUG: isBookingScreenActive = $isBookingActive");

    if (isBookingActive) {
      print("TOAST DEBUG: Blocked because user is on booking screen.");
      return; 
    }

    final String title = data['title'] ?? 'Notification';
    final String message = data['message'] ?? '';

    print("TOAST DEBUG: Showing SnackBar now: $title");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}