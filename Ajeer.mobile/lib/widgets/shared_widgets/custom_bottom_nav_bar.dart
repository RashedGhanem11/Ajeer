import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifiers/user_notifier.dart';

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
    // 1. Check User Mode
    final userNotifier = Provider.of<UserNotifier>(context);
    final bool isProvider = userNotifier.isProvider;

    // 2. Check Theme Mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 3. Define Color Palette
    const Color customerDarkBlue = Color(0xFF1976D2);
    const Color customerLightBlue = Color(0xFF8CCBFF);
    const Color providerDarkBlue = Color(0xFF2f6cfa);
    const Color providerLightBlue = Color(0xFFa2bdfc);

    // 4. Determine Selected Color
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

    const double verticalPadding = 6.0;
    const double horizontalPadding = 17.0;
    const double outerBottomMargin = 25.0;
    const double iconSize = 28.0;
    const double labelFontSize = 12.0;
    const double notificationSize = 8.0;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          outerBottomMargin,
        ),
        child: Container(
          height: kBottomNavigationBarHeight + verticalPadding * 2,
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
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return const SizedBox(width: 25);
                }

                final int index = i ~/ 2;
                final Map<String, dynamic> item = items[index];
                final bool isSelected = index == selectedIndex;
                final bool hasNotification =
                    (item['notificationCount'] ?? 0) > 0;

                final Color itemColor = isSelected
                    ? selectedColor
                    : defaultIconTextColor;

                return _BounceableNavItem(
                  onTap: () => onIndexChanged(index),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item['activeIcon'] : item['icon'],
                              size: iconSize,
                              color: itemColor,
                            ),
                            if (hasNotification)
                              Positioned(
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
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: labelFontSize,
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
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
    // I reduced the duration slightly (70ms) to make the nav feel snappy
    // while still showing the bounce.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.65, // Slightly more pronounced shrink (0.90) for better visibility
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // 1. Shrink
    await _controller.forward();
    // 2. Expand (Bounce back)
    await _controller.reverse();
    // 3. ONLY THEN navigate
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
