import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'date_time_screen.dart';
import 'bookings_screen.dart'; // <-- ADDED: Import BookingsScreen

// =========================================================================
// WIDGET 1: THE UNIT TYPE SCREEN (STATEFUL)
// =========================================================================

class UnitTypeScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;

  const UnitTypeScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
  });

  @override
  State<UnitTypeScreen> createState() => _UnitTypeScreenState();
}

class _UnitTypeScreenState extends State<UnitTypeScreen> {
  // =========================================================================
  // 1. STATE VARIABLES AND DATA
  // =========================================================================

  int _selectedIndex = 3;
  final List<Map<String, dynamic>> navItems = [
    {
      'label': 'Profile',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
    {
      'label': 'Chat',
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
    },
    {
      'label': 'Bookings',
      'icon': Icons.book_outlined,
      'activeIcon': Icons.book,
      'notificationCount': 3,
    },
    {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
  ];

  String? _selectedUnitType;

  final List<String> _unitTypes = [
    'Deep Cleaning',
    'House Keeping',
    'Office Cleaning',
    'move in/ out cleaning',
    'carpet cleaning',
  ];

  // =========================================================================
  // 2. STATE-CHANGING METHODS (NAVIGATION FIXED)
  // =========================================================================

  void _onNavItemTapped(int index) {
    if (index == 3) {
      // Navigate to Home
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      // FIXED: Navigate to Bookings Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
      debugPrint('Tapped index $index');
    }
  }

  void _onUnitTypeTapped(String unitType) {
    setState(() {
      if (_selectedUnitType == unitType) {
        _selectedUnitType = null; // Allow deselection
      } else {
        _selectedUnitType = unitType; // Select new one
      }
    });
  }

  // =========================================================================
  // 3. MAIN BUILD METHOD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Layout Variables
    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    // Bottom Nav Bar clearance
    final double navBarHeight = 56.0 + 20.0;
    final double outerBottomMargin = 10.0;
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),

          _buildServiceIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
            screenWidth,
          ),

          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
          ),

          _buildHomeImage(logoTopPosition, logoHeight),

          UnitTypeNavigationHeader(
            onBackTap: () {
              Navigator.pop(context);
            },
            onNextTap: () {
              if (_selectedUnitType != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DateTimeScreen(
                      serviceName: widget.serviceName,
                      unitType: _selectedUnitType!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a unit type first.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  // =========================================================================
  // 4. PRIVATE BUILD HELPERS
  // =========================================================================

  Widget _buildBackgroundGradient(double containerTop) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(
    double containerTop,
    double statusBarHeight,
    double screenWidth,
  ) {
    final double headerHeight = statusBarHeight + 60;
    final double availableHeight = containerTop - headerHeight;
    final double iconTopPosition = headerHeight + (availableHeight / 2) - 70;

    return Positioned(
      top: iconTopPosition,
      right: 25.0,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFc2e3ff), Color(0xFF57b2ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5.0,
              color: Colors.black38,
              offset: Offset(2.0, 2.0),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(widget.serviceIcon, size: 60.0, color: Colors.white),
      ),
    );
  }

  Widget _buildHomeImage(double logoTopPosition, double logoHeight) {
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/image/home.png',
          width: 140,
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required double bottomNavClearance,
  }) {
    return Positioned(
      top: containerTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                widget.serviceName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0, top: 4.0, bottom: 10.0),
              child: Text(
                'Select unit type(s)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: UnitTypeListView(
                unitTypes: _unitTypes,
                selectedUnitType: _selectedUnitType,
                onUnitTypeTap: _onUnitTypeTapped,
                bottomPadding: bottomNavClearance,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET 2: NAVIGATION HEADER (STATELESS)
// =========================================================================
class UnitTypeNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;

  const UnitTypeNavigationHeader({
    super.key,
    required this.onBackTap,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBackTap,
          ),
          const Text(
            'Ajeer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
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
          IconButton(
            iconSize: 28.0,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
            ),
            onPressed: onNextTap,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET 3: UNIT TYPE LIST VIEW (STATELESS)
// =========================================================================
class UnitTypeListView extends StatelessWidget {
  final List<String> unitTypes;
  final String? selectedUnitType;
  final ValueChanged<String> onUnitTypeTap;
  final double bottomPadding;

  const UnitTypeListView({
    super.key,
    required this.unitTypes,
    required this.selectedUnitType,
    required this.onUnitTypeTap,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: bottomPadding,
      ),
      itemCount: unitTypes.length,
      itemBuilder: (context, index) {
        final unitName = unitTypes[index];
        final bool isSelected = (selectedUnitType == unitName);

        return SelectableUnitItem(
          name: unitName,
          isSelected: isSelected,
          onTap: () {
            onUnitTypeTap(unitName);
          },
        );
      },
    );
  }
}

// =========================================================================
// WIDGET 4: SELECTABLE UNIT ITEM (STATELESS)
// =========================================================================
class SelectableUnitItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableUnitItem({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(15.0),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[400]!, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.greenAccent : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET 5: CUSTOM BOTTOM NAV BAR (LOCAL)
// =========================================================================
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
    const double verticalPadding = 6.0;
    const double horizontalPadding = 17.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        25.0,
      ),
      child: Container(
        height: kBottomNavigationBarHeight + verticalPadding * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
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
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            bool isSelected = index == selectedIndex;

            bool hasNotification = (item['notificationCount'] ?? 0) > 0;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onIndexChanged(index); // Use the callback
                },
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
                            size: 28.0,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          if (hasNotification)
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                width: 8,
                                height: 8,
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
                          fontSize: 12,
                          color: isSelected ? Colors.blue : Colors.grey,
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
