// Required for widget test setup
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // Required for MultiProvider setup

import 'package:ajeer_mobile/main.dart';
import 'package:ajeer_mobile/themes/theme_notifier.dart';
import 'package:ajeer_mobile/notifiers/user_notifier.dart'; // Required to mock UserNotifier

void main() {
  // Create dummy Notifier instances to satisfy the required Providers
  final ThemeNotifier dummyThemeNotifier = ThemeNotifier();
  final UserNotifier dummyUserNotifier = UserNotifier();

  testWidgets('App starts at LoginScreen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // FIX: Wrap MyApp in a MultiProvider to mock all dependencies.
    // FIX: Remove the non-existent 'themeNotifier' named parameter from MyApp().
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Use .value constructor to inject the dummy instances
          ChangeNotifierProvider<ThemeNotifier>.value(
            value: dummyThemeNotifier,
          ),
          ChangeNotifierProvider<UserNotifier>.value(value: dummyUserNotifier),
        ],
        // MyApp is now called without any parameters.
        child: const MyApp(),
      ),
    );

    // Verify that the Login screen loads by checking for expected text
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(find.text('Don\'t have an account? '), findsOneWidget);
  });
}
