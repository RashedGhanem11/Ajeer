import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'unit_type_screen.dart';
import 'bookings_screen.dart';
import '../../services/services.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import '../../themes/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 3;
  String _searchQuery = '';

  final List<Service> services = kAvailableServices;

  final List<Map<String, dynamic>> navItems = const [
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfileScreen(themeNotifier: widget.themeNotifier),
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
            builder: (context) =>
                HomeScreen(themeNotifier: widget.themeNotifier),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

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

    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    const double navBarHeight = 56.0 + 20.0;
    const double outerBottomMargin = 10.0;
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop, isDarkMode),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
          ),
          SearchHeader(onChanged: _onSearchChanged),
          _buildHomeImage(logoTopPosition, logoHeight, isDarkMode),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBackgroundGradient(double containerTop, bool isDarkMode) {
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

  Widget _buildHomeImage(
    double logoTopPosition,
    double logoHeight,
    bool isDarkMode,
  ) {
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
          height: logoHeight,
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
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Select a service',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ServiceGridView(
                services: services,
                searchQuery: _searchQuery,
                bottomPadding: bottomNavClearance,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchHeader extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchHeader({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF8CCBFF), Color(0xFF1976D2)];

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0, // Set to 0
      right: 0, // Set to 0
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
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
          ),
          // Search bar is now centered and has a limited width
          Center(
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.85, // Adjust width as needed
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.white, width: 1.5),
                  gradient: const LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: 'Search for a service',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceGridView extends StatelessWidget {
  final List<Service> services;
  final String searchQuery;
  final double bottomPadding;
  final bool isDarkMode;

  const ServiceGridView({
    super.key,
    required this.services,
    required this.searchQuery,
    required this.bottomPadding,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    String normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredServices = services.where((service) {
      return service.name.toLowerCase().contains(normalizedQuery);
    }).toList();

    bool shouldHighlight(String serviceName) {
      return normalizedQuery.isNotEmpty &&
          serviceName.toLowerCase().contains(normalizedQuery);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          final serviceName = service.name;
          final serviceIcon = service.icon;

          return ServiceGridItem(
            icon: serviceIcon,
            name: serviceName,
            isHighlighted: shouldHighlight(serviceName),
            isDarkMode: isDarkMode,
            onTap: () {
              if (service.unitTypes.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitTypeScreen(service: service),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$serviceName service is not fully set up yet.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class ServiceGridItem extends StatelessWidget {
  final IconData? icon;
  final String name;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ServiceGridItem({
    super.key,
    required this.icon,
    required this.name,
    this.isHighlighted = false,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isHighlighted
        ? Colors.green
        : (isDarkMode ? Theme.of(context).primaryColor : Colors.blue);
    final Color backgroundColor = primaryColor.withOpacity(0.08);
    final Color borderColor = primaryColor.withOpacity(0.1);

    const double iconContainerSize = 80.0;
    const double iconSize = 40.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: iconSize, color: primaryColor),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isHighlighted
                    ? primaryColor
                    : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
