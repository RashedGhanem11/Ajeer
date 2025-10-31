// lib/screens/customer_screens/unit_type_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'date_time_screen.dart';
import 'bookings_screen.dart';
import '../../services/services.dart'; // Import corrected path

class UnitTypeScreen extends StatefulWidget {
  // Now takes the full Service object
  final Service service;

  const UnitTypeScreen({super.key, required this.service});

  @override
  State<UnitTypeScreen> createState() => _UnitTypeScreenState();
}

class _UnitTypeScreenState extends State<UnitTypeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  final Set<String> _selectedUnitTypes = {};

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;

  final List<Map<String, dynamic>> _navItems = const [
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

  void _onNavItemTapped(int index) {
    if (index == 3) {
      // Pop to the first route (ServiceScreen/HomeScreen)
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onUnitTypeTapped(String unitType) {
    setState(() {
      if (_selectedUnitTypes.contains(unitType)) {
        _selectedUnitTypes.remove(unitType);
      } else {
        _selectedUnitTypes.add(unitType);
      }
    });
  }

  void _onNextTap() {
    if (_selectedUnitTypes.isNotEmpty) {
      double totalCost = 0.0;
      int totalMinutes = 0;

      final unitData = widget.service.unitTypes;

      for (var unitTypeKey in _selectedUnitTypes) {
        final data = unitData[unitTypeKey];
        if (data != null) {
          totalCost += data.priceJOD;
          totalMinutes += data.estimatedTimeMinutes;
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DateTimeScreen(
            serviceName: widget.service.name,
            unitType: _selectedUnitTypes.join(', '),
            totalTimeMinutes: totalMinutes,
            totalPrice: totalCost,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one unit type first.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - _logoHeight + _overlapAdjustment;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    // Use the keys from the service's unit types to build the list in order
    final unitTypeKeys = widget.service.unitTypes.keys.toList();

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildServiceIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            unitTypeKeys: unitTypeKeys, // Pass the keys
          ),
          _buildHomeImage(logoTopPosition),
          _UnitTypeNavigationHeader(
            onBackTap: () {
              Navigator.pop(context);
            },
            onNextTap: _onNextTap,
            isNextEnabled: _selectedUnitTypes.isNotEmpty,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBackgroundGradient(double containerTop) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightBlue, _primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(double containerTop, double statusBarHeight) {
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
        child: Icon(widget.service.icon, size: 60.0, color: Colors.white),
      ),
    );
  }

  Widget _buildHomeImage(double logoTopPosition) {
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/image/home.png',
          width: 140,
          height: _logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required double bottomNavClearance,
    required List<String> unitTypeKeys,
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
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                'Select unit type(s)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _UnitTypeListView(
                unitTypes: unitTypeKeys,
                unitData: widget.service.unitTypes, // Pass the UnitType map
                selectedUnitTypes: _selectedUnitTypes,
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

class _UnitTypeNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _UnitTypeNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
  });

  Widget _buildAjeerTitle() {
    return const Text(
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
    );
  }

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
          _buildAjeerTitle(),
          IconButton(
            iconSize: 28.0,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(isNextEnabled ? 1.0 : 0.5),
            ),
            onPressed: isNextEnabled ? onNextTap : null,
          ),
        ],
      ),
    );
  }
}

class _UnitTypeListView extends StatelessWidget {
  // Use UnitType model for the data map
  final Map<String, UnitType> unitData;
  final List<String> unitTypes;
  final Set<String> selectedUnitTypes;
  final ValueChanged<String> onUnitTypeTap;
  final double bottomPadding;

  const _UnitTypeListView({
    required this.unitTypes,
    required this.selectedUnitTypes,
    required this.onUnitTypeTap,
    required this.bottomPadding,
    required this.unitData,
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
        final bool isSelected = selectedUnitTypes.contains(unitName);
        final data = unitData[unitName];

        return _SelectableUnitItem(
          name: unitName,
          // Safely access data using the UnitType model properties
          estimatedTime: data?.estimatedTimeMinutes ?? 0,
          price: data?.priceJOD ?? 0.0,
          isSelected: isSelected,
          onTap: () {
            onUnitTypeTap(unitName);
          },
        );
      },
    );
  }
}

class _SelectableUnitItem extends StatelessWidget {
  final String name;
  final int estimatedTime;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableUnitItem({
    required this.name,
    required this.estimatedTime,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _primaryBlue = Color(0xFF1976D2);
  static final Color _fillColor = Colors.grey[100]!;
  static const double _borderRadius = 15.0;
  static const double _borderWidth = 2.0;

  String get _formattedTime {
    if (estimatedTime < 60) return '$estimatedTime mins';
    final hours = estimatedTime ~/ 60;
    final minutes = estimatedTime % 60;
    if (minutes == 0) return '$hours hrs';
    return '$hours hrs $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: _fillColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: isSelected ? _primaryBlue : Colors.grey[400]!,
            width: _borderWidth,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? _primaryBlue : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Est. Time: $_formattedTime',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'JOD ${price.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
