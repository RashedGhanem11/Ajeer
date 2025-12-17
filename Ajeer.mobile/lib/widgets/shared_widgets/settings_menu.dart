import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../themes/theme_notifier.dart';
import '../../notifiers/user_notifier.dart';
import '../../screens/customer_screens/login_screen.dart';

class SettingsMenu extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const SettingsMenu({super.key, required this.themeNotifier});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;

  final Set<int> _selectedNotifications = {};
  bool _isDeleting = false;
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Booking Confirmation',
      'subtitle': 'Your booking #1023 is confirmed.',
      'icon': Icons.calendar_today,
      'color': Colors.green,
    },
    {
      'title': 'Provider Assigned',
      'subtitle': 'John Doe has been assigned.',
      'icon': Icons.people_alt,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Reminder',
      'subtitle': 'Service fee due tomorrow.',
      'icon': Icons.payments,
      'color': Colors.orange,
    },
  ];

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
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
      _notifications.removeWhere(
        (n) => _selectedNotifications.contains(_notifications.indexOf(n)),
      );
      _selectedNotifications.clear();
      _isDeleting = false;
    });
  }

  void _showInfoDialog() {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Ajeer Info',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        content: Text(
          'Ajeer connects customers with professional service providers for a seamless experience.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textColor),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text(
          'Sign Out',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textColor),
            child: const Text('No'),
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
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Drawer(
      backgroundColor: isDarkMode ? Theme.of(context).cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
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
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
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
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            visualDensity: const VisualDensity(vertical: -2),
            title: Text('Enable Dark Mode', style: TextStyle(color: textColor)),
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
            title: Text('Ajeer Info', style: TextStyle(color: textColor)),
            onTap: _showInfoDialog,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 270,
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
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_none, color: textColor),
                        const SizedBox(width: 12),
                        Text(
                          'Notifications',
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
                                'No new notifications.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                ListView.builder(
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
                                        if (_isDeleting) {
                                          _toggleNotificationSelection(index);
                                        }
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                                  notification['color']
                                                      as Color,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                if (_isDeleting)
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: FloatingActionButton(
                                      onPressed: _deleteSelectedNotifications,
                                      backgroundColor: Colors.red,
                                      mini: true,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(
              left: 60.0,
              right: 60.0,
              bottom: 40.0,
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
                onPressed: _showSignOutDialog,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
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
