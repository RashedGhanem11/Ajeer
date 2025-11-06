import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // 💡 FIX 1: Import Provider
import '../../themes/theme_notifier.dart'; // 💡 FIX 2: Import ThemeNotifier definition
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'media_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
// Removed: import '../../main.dart';

class LocationScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final int totalTimeMinutes;
  final double totalPrice;

  const LocationScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    required this.totalTimeMinutes,
    required this.totalPrice,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int _selectedIndex = 3;

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleLighterDark = Color(
    0xFF2C2C2C,
  ); // Added for map container background
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _mapBorderRadius = 25.0;
  static const double _horizontalPadding = 20.0;

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
    if (index == _selectedIndex) return;

    // 💡 FIX 3: Retrieve ThemeNotifier via Provider for navigation
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // Correctly pass the retrieved themeNotifier
            builder: (context) => ProfileScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookingsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
    }
  }

  void _onBackTap() {
    Navigator.pop(context);
  }

  void _onNextTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaScreen(
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectionMode: widget.selectionMode,
          totalTimeMinutes: widget.totalTimeMinutes,
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  void _showMaximizedMap(BuildContext context, bool isDarkMode) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Map',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) {
        return _MaximizedMapDialog(
          mapBorderRadius: _mapBorderRadius,
          primaryColor: _primaryBlue,
          isDarkMode: isDarkMode,
        );
      },
      transitionBuilder: (context, a1, a2, child) {
        return FadeTransition(opacity: a1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 FIX 4: Retrieve ThemeNotifier via Provider for build
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bool isDarkMode = themeNotifier.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
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

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildLocationIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(onBackTap: _onBackTap, onNextTap: _onNextTap),
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

  Widget _buildLocationIcon(double containerTop, double statusBarHeight) {
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
            colors: [_secondaryLightBlue, _secondaryBlue],
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
        child: const Icon(
          Icons.location_on_outlined,
          size: 55.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHomeImage(double logoTopPosition, bool isDarkMode) {
    final String imagePath = isDarkMode
        ? 'assets/image/home_dark.png'
        : 'assets/image/home.png';
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          imagePath,
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
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(
                left: _horizontalPadding,
                top: 20.0,
              ),
              child: Text(
                'Pick a location',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _buildMapPlaceholder(bottomNavClearance, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(double bottomNavClearance, bool isDarkMode) {
    // UPDATED: Use Colors.grey[100] in light mode and _subtleLighterDark in dark mode
    final Color mapBgColor = isDarkMode
        ? _subtleLighterDark
        : Colors.grey[100]!;
    final Color mapBorderColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[400]!;
    final Color mapIconColor = isDarkMode
        ? Colors.red.shade300
        : Colors.red.shade100;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalPadding,
        10.0,
        _horizontalPadding,
        bottomNavClearance - _horizontalPadding,
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: mapBgColor,
            borderRadius: BorderRadius.circular(_mapBorderRadius),
            border: Border.all(color: mapBorderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1 / 1.5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.location_on, size: 150, color: mapIconColor),
                Positioned(
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: _primaryBlue,
                    onPressed: () => _showMaximizedMap(context, isDarkMode),
                    child: const Icon(Icons.open_in_full, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaximizedMapDialog extends StatelessWidget {
  final double mapBorderRadius;
  final Color primaryColor;
  final bool isDarkMode;

  const _MaximizedMapDialog({
    required this.mapBorderRadius,
    required this.primaryColor,
    required this.isDarkMode,
  });

  static const Color _subtleDark = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? _subtleDark : Colors.white;
    final Color mapIconColor = isDarkMode
        ? Colors.red.shade300
        : Colors.red.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Center(
              child: Icon(Icons.location_on, size: 200, color: mapIconColor),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: primaryColor,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close_fullscreen, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;

  const _NavigationHeader({required this.onBackTap, required this.onNextTap});

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
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: onNextTap,
          ),
        ],
      ),
    );
  }
}
