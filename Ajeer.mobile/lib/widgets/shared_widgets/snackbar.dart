import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifiers/language_notifier.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String messageKey,
    required Color backgroundColor,
    String? dynamicText,
  }) {
    final lang = Provider.of<LanguageNotifier>(context, listen: false);
    String translated = lang.translate(messageKey);
    if (translated == messageKey) {
      debugPrint(
        '⚠️ MISSING TRANSLATION: The key "$messageKey" was not found in LanguageNotifier.',
      );
    }

    final fullMessage = dynamicText != null
        ? '$translated $dynamicText'
        : translated;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fullMessage,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: lang.currentFontFamily,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
