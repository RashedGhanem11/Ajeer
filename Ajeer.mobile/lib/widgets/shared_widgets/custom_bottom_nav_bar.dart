import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifiers/user_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../notifiers/notification_notifier.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    final notificationNotifier = Provider.of<AppNotificationNotifier>(context);
    final bool isProvider = userNotifier.isProvider;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const Color customerDarkBlue = Color(0xFF1976D2);
    const Color customerLightBlue = Color(0xFF8CCBFF);
    const Color providerDarkBlue = Color(0xFF2f6cfa);
    const Color providerLightBlue = Color(0xFFa2bdfc);

    Color selectedColor;
    if (isProvider) {
      selectedColor = isDarkMode ? providerLightBlue : providerDarkBlue;
    } else {
      selectedColor = isDarkMode ? customerLightBlue : customerDarkBlue;
    }

    const Color subtleLighterDarkGrey = Color(0xFF40403f);
    final Color backgroundColor = isDarkMode
        ? subtleLighterDarkGrey
        : Colors.white;
    final Color defaultIconTextColor = isDarkMode
        ? Colors.grey[400]!
        : Colors.grey;
    final Color shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.25);

    const double horizontalPadding = 17.0;
    const double outerBottomMargin = 20.0;
    const double iconSize = 28.0;
    const double labelFontSize = 11.0;
    const double notificationSize = 8.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        outerBottomMargin,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final Map<String, dynamic> item = items[index];
            final bool isSelected = index == selectedIndex;
            final Color itemColor = isSelected
                ? selectedColor
                : defaultIconTextColor;

            return _BounceableNavItem(
              onTap: () => onIndexChanged(index),
              child: SizedBox(
                width: 75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isSelected ? item['activeIcon'] : item['icon'],
                          size: iconSize,
                          color: itemColor,
                        ),
                        Builder(
                          builder: (context) {
                            bool showDot = false;
                            if (index == 1 &&
                                notificationNotifier.unreadChatCount > 0) {
                              showDot = true;
                            } else if (index == 2 &&
                                notificationNotifier.activeBookingsCount > 0) {
                              showDot = true;
                            }

                            if (!showDot) return const SizedBox.shrink();

                            return Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                width: notificationSize,
                                height: notificationSize,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['label'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: itemColor,
                        fontFamily: languageNotifier.currentFontFamily,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BounceableNavItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BounceableNavItem({required this.child, required this.onTap});

  @override
  State<_BounceableNavItem> createState() => _BounceableNavItemState();
}

class _BounceableNavItemState extends State<_BounceableNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
