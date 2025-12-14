import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Added
import '../../themes/theme_notifier.dart';
import '../../notifiers/user_notifier.dart'; // ✅ Added

class SettingsMenu extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final VoidCallback onInfoTap;
  final VoidCallback onSignOutTap;
  final List<Map<String, dynamic>> notifications;
  final Set<int> selectedNotifications;
  final bool isDeleting;
  final ValueChanged<int> onToggleNotificationSelection;
  final VoidCallback onDeleteSelectedNotifications;

  const SettingsMenu({
    super.key,
    required this.themeNotifier,
    required this.onInfoTap,
    required this.onSignOutTap,
    required this.notifications,
    required this.selectedNotifications,
    required this.isDeleting,
    required this.onToggleNotificationSelection,
    required this.onDeleteSelectedNotifications,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Access UserNotifier to check mode
    final userNotifier = Provider.of<UserNotifier>(context);
    final bool isProvider = userNotifier.isProvider;

    final bool isDarkMode = themeNotifier.isDarkMode;

    final Color primaryBlue = isProvider
        ? const Color(0xFF2f6cfa) // Provider Darker Blue
        : const Color(0xFF1976D2); // Customer Darker Blue

    final Color lightBlue = isProvider
        ? const Color(0xFFa2bdfc) // Provider Lighter Blue
        : const Color(0xFF8CCBFF); // Customer Lighter Blue

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
                // ✅ 3. Use the dynamic colors here
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
              themeNotifier.isDarkMode
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
              color: themeNotifier.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            value: themeNotifier.isDarkMode,
            onChanged: (bool value) {
              themeNotifier.toggleTheme();
            },
            // Update active color to match the current mode's primary
            activeColor: primaryBlue,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 2.0,
            ),
            visualDensity: const VisualDensity(vertical: -4),
            leading: Icon(
              Icons.info_outline,
              color: themeNotifier.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            title: Text('Ajeer Info', style: TextStyle(color: textColor)),
            onTap: onInfoTap,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 0,
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
                          if (notifications.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${notifications.length}',
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
                        child: notifications.isEmpty
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
                                    itemCount: notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      final isSelected = selectedNotifications
                                          .contains(index);

                                      return GestureDetector(
                                        onLongPress: () =>
                                            onToggleNotificationSelection(
                                              index,
                                            ),
                                        onTap: () {
                                          if (isDeleting) {
                                            onToggleNotificationSelection(
                                              index,
                                            );
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
                                              if (isDeleting)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                notification['icon']
                                                    as IconData,
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
                                  if (isDeleting)
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: FloatingActionButton(
                                        onPressed:
                                            onDeleteSelectedNotifications,
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
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 60.0,
              right: 60.0,
              top: 15.0,
              bottom: 10.0,
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
                onPressed: onSignOutTap,
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
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 10),
        ],
      ),
    );
  }
}
