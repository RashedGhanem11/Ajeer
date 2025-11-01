import 'package:flutter/material.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // A very subtle dark grey, slightly lighter than the previous shade (0xFF1F1F1F)
    const Color subtleLighterDarkGrey = const Color(0xFF40403f);

    final Color backgroundColor = isDarkMode
        ? subtleLighterDarkGrey
        : Colors.white;
    final Color defaultIconTextColor = isDarkMode
        ? Colors.grey[400]!
        : Colors.grey;
    final Color selectedColor = isDarkMode
        ? Theme.of(context).primaryColor
        : Colors.blue;
    final Color shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.25);

    const double verticalPadding = 6.0;
    const double horizontalPadding = 17.0;
    const double outerBottomMargin = 25.0;
    const double iconSize = 28.0;
    const double labelFontSize = 12.0;
    const double notificationSize = 8.0;

    return Padding(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> item = entry.value;
            final bool isSelected = index == selectedIndex;
            final bool hasNotification = (item['notificationCount'] ?? 0) > 0;
            final Color itemColor = isSelected
                ? selectedColor
                : defaultIconTextColor;

            return Expanded(
              child: GestureDetector(
                onTap: () => onIndexChanged(index),
                behavior: HitTestBehavior.translucent,
                child: Container(
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
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
