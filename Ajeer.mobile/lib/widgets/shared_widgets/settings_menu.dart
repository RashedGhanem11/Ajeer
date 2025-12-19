import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/user_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../screens/customer_screens/login_screen.dart';

class SettingsMenu extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const SettingsMenu({super.key, required this.themeNotifier});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bellController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bellAnimation;
  OverlayEntry? _overlayEntry;

  final List<Map<String, dynamic>> _notifications = [];
  final Set<int> _selectedNotifications = {};
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bellAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.04, end: -0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.04, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _bellController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    _bellController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleNotificationSelection(int index) {
    setState(() {
      _selectedNotifications.contains(index)
          ? _selectedNotifications.remove(index)
          : _selectedNotifications.add(index);
      _isDeleting = _selectedNotifications.isNotEmpty;
    });
  }

  void _deleteSelectedNotifications() {
    setState(() {
      final sortedIndices = _selectedNotifications.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final index in sortedIndices) {
        if (index >= 0 && index < _notifications.length) {
          _notifications.removeAt(index);
        }
      }
      _selectedNotifications.clear();
      _isDeleting = false;
    });
  }

  void _showLanguageOverlay() {
    final overlayState = Overlay.of(context);
    final isDarkMode = widget.themeNotifier.isDarkMode;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 60, color: Colors.blue),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    overlayState.insert(_overlayEntry!);
  }

  Future<void> _handleLanguageToggle(LanguageNotifier lang) async {
    _showLanguageOverlay();
    await _controller.forward();
    if (!mounted) return;
    lang.toggleLanguage();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(bool willBeDark) {
    final overlayState = Overlay.of(context);
    final isDarkMode = willBeDark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF40403f) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    size: 40,
                    color: isDarkMode ? Colors.orange : Colors.orangeAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlayState.insert(_overlayEntry!);
  }

  Future<void> _handleThemeToggle() async {
    final bool willBeDark = !widget.themeNotifier.isDarkMode;
    _showOverlay(willBeDark);
    widget.themeNotifier.toggleTheme();
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showInfoDialog(LanguageNotifier lang) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            lang.translate('infoTitle'),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Text(
            lang.translate('infoMsg'),
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: textColor),
              child: Text(lang.translate('close')),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(LanguageNotifier lang) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            lang.translate('signOutTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            lang.translate('signOutMsg'),
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: textColor),
              child: Text(lang.translate('no')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Provider.of<UserNotifier>(context, listen: false).clearData();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('currentUser');
                await prefs.remove('authToken');
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                }
              },
              child: Text(
                lang.translate('signOut'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageNotifier>(context);
    final userNotifier = Provider.of<UserNotifier>(context);
    final bool isProvider = userNotifier.isProvider;
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

    final Color primaryBlue = isProvider
        ? const Color(0xFF2f6cfa)
        : const Color(0xFF1976D2);
    final Color lightBlue = isProvider
        ? const Color(0xFFa2bdfc)
        : const Color(0xFF8CCBFF);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color containerColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    final BorderRadius drawerRadius = lang.isArabic
        ? const BorderRadius.only(
            topLeft: Radius.circular(50),
            bottomLeft: Radius.circular(50),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          );

    return Drawer(
      backgroundColor: isDarkMode ? Theme.of(context).cardColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: drawerRadius),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue, primaryBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(top: 80.0, bottom: 40.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    lang.translate('settings'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black26,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 2.0,
            ),
            visualDensity: const VisualDensity(vertical: -2),
            leading: Icon(
              Icons.language,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            title: Text(
              lang.translate('language'),
              style: TextStyle(color: textColor),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang.isArabic ? 'العربية' : 'English',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _handleLanguageToggle(lang),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            visualDensity: const VisualDensity(vertical: -2),
            title: Text(
              lang.translate('darkMode'),
              style: TextStyle(color: textColor),
            ),
            secondary: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            value: isDarkMode,
            onChanged: (bool value) => _handleThemeToggle(),
            activeColor: primaryBlue,
            activeTrackColor: primaryBlue.withOpacity(0.5),
            inactiveThumbColor: Colors.grey.shade50,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 2.0,
            ),
            visualDensity: const VisualDensity(vertical: -4),
            leading: Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            title: Text(
              lang.translate('ajeerInfo'),
              style: TextStyle(color: textColor),
            ),
            onTap: () => _showInfoDialog(lang),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RotationTransition(
                            turns: _bellAnimation,
                            child: Icon(
                              Icons.notifications_none,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            lang.translate('notifications'),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_notifications.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_notifications.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Expanded(
                        child: _notifications.isEmpty
                            ? Center(
                                child: Text(
                                  lang.translate('noNotifications'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = _notifications[index];
                                  final isSelected = _selectedNotifications
                                      .contains(index);
                                  return GestureDetector(
                                    onLongPress: () =>
                                        _toggleNotificationSelection(index),
                                    onTap: () {
                                      if (_isDeleting)
                                        _toggleNotificationSelection(index);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_isDeleting)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                                top: 4.0,
                                              ),
                                              child: Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color: isSelected
                                                    ? Colors.red
                                                    : textColor.withOpacity(
                                                        0.5,
                                                      ),
                                                size: 20,
                                              ),
                                            ),
                                          Icon(
                                            notification['icon'] as IconData,
                                            color:
                                                notification['color'] as Color,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification['title']
                                                      as String,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: textColor,
                                                  ),
                                                ),
                                                Text(
                                                  notification['subtitle']
                                                      as String,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 60.0,
              right: 60.0,
              bottom: 40.0,
              top: 10.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                onPressed: () => _showSignOutDialog(lang),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      lang.translate('signOut'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
