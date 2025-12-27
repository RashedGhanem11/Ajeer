import 'dart:async'; // Required for StreamSubscription
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
import 'services/notification_service.dart';
import 'models/notification_model.dart'; // Import the model
import 'widgets/shared_widgets/snackbar.dart';

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
  State<GlobalNotificationWrapper> createState() =>
      _GlobalNotificationWrapperState();
}

class _GlobalNotificationWrapperState extends State<GlobalNotificationWrapper> {
  StreamSubscription? _subscription;
  String? _lastToken;

  @override
  void initState() {
    super.initState();
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
    _subscription = notificationService.notificationStream.listen((data) {
      _showToast(data);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showToast(NotificationModel data) {
    if (!mounted) return;

    final lang = Provider.of<LanguageNotifier>(context, listen: false);
    String translatedTitle = lang.translateNotificationMessage(data.title);
    String translatedMessage = lang.translateNotificationMessage(data.message);
    CustomSnackBar.show(
      context,
      messageKey: translatedTitle,
      dynamicText: translatedMessage,
      backgroundColor: Colors.blueAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final notificationService = Provider.of<NotificationService>(
            context,
            listen: false,
          );

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('authToken');
          if (token == _lastToken) return;
          _lastToken = token;

          if (token != null && token.isNotEmpty) {
            notificationService.initSignalR();
          } else {
            notificationService.disconnectSignalR();
          }
        });

        return widget.child;
      },
    );
  }
}
