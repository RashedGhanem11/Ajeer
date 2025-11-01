// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// REMOVED: import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ajeer_mobile/main.dart';
import 'package:ajeer_mobile/themes/theme_notifier.dart';

void main() {
  // Create a dummy ThemeNotifier instance to satisfy the required argument
  final ThemeNotifier dummyNotifier = ThemeNotifier();

  testWidgets('App starts at LoginScreen test', (WidgetTester tester) async {
    // Build our app and trigger a frame, passing the required themeNotifier.
    await tester.pumpWidget(MyApp(themeNotifier: dummyNotifier));

    // Verify that the Login screen loads by checking for expected text
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(find.text('Don\'t have an account? '), findsOneWidget);
  });
}
