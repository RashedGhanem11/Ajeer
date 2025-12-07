// lib/screens/login/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'unit_type_screen.dart';
import 'bookings_screen.dart';
import '../../services/services.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import '../../themes/theme_notifier.dart';

// NEW IMPORTS
import '../../models/service_models.dart';
import '../../services/service_category_service.dart';

// NOTE: Since your UnitTypeScreen takes a 'service' object, we are now passing
// the ServiceCategory object. If UnitTypeScreen was tightly coupled to the old
// mock 'Service' class, you will need to update it as well.

class HomeScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 3;
  String _searchQuery = '';

  // UPDATED STATE: Store real categories and loading status
  List<ServiceCategory> _categories = [];
  bool _isFetching = true;

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

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Start fetching data immediately
  }

  // NEW LOGIC: API call
  Future<void> _fetchCategories() async {
    try {
      final service = ServiceCategoryService();
      final fetchedCategories = await service.fetchCategories();

      if (!mounted) return;

      setState(() {
        _categories = fetchedCategories;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching services: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          // Show spinner over everything if loading
          if (_isFetching)
            Container(
              color: isDarkMode ? Colors.black54 : Colors.white70,
              child: const Center(child: CircularProgressIndicator()),
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
            // UPDATED: Pass the fetched categories to the GridView
            Expanded(
              child: ServiceGridView(
                services: _categories,
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
      left: 0,
      right: 0,
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

// UPDATED: ServiceGridView now accepts List<ServiceCategory>
class ServiceGridView extends StatelessWidget {
  final List<ServiceCategory> services;
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
          final serviceIconUrl = service.iconUrl;

          return ServiceGridItem(
            iconUrl: serviceIconUrl, // Pass the URL string
            name: serviceName,
            isHighlighted: shouldHighlight(serviceName),
            isDarkMode: isDarkMode,
            onTap: () {
              // The fake object instance
              final fakeService = Service(
                name: "Fake Plumbing Service",
                icon: Icons.plumbing,
                unitTypes: {
                  "Regular_Repair": const UnitType(
                    priceJOD: 15.0,
                    estimatedTimeMinutes: 60,
                  ),
                  "Emergency_Call": const UnitType(
                    priceJOD: 30.0,
                    estimatedTimeMinutes: 90,
                  ),
                  "Pipe_Installation": const UnitType(
                    priceJOD: 50.0,
                    estimatedTimeMinutes: 120,
                  ),
                },
              );
              // The logic to check for unitTypes is removed because the DTO
              // does not provide this information. We navigate directly now.
              Navigator.push(
                context,
                MaterialPageRoute(
                  // We pass the new ServiceCategory object
                  builder: (context) => UnitTypeScreen(service: fakeService),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// UPDATED: ServiceGridItem now expects String iconUrl
class ServiceGridItem extends StatelessWidget {
  final String iconUrl;
  final String name;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isDarkMode;

  // Use 10.0.2.2 for Android, 127.0.0.1 for iOS Simulator
  final String BASE_API_URL = 'http://127.0.0.1:5289';

  const ServiceGridItem({
    super.key,
    required this.iconUrl,
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

    // 1. The Circle Size
    const double iconContainerSize = 80.0;
    // 2. The Icon Size (Make this smaller if needed, e.g., 30.0 or 35.0)
    const double iconSize = 50.0;

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
            // FIX: Use Center here. This stops the image from stretching to 80x80.
            child: Center(
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/image/placeholder.png',
                  // Ensure URL doesn't have double wwwroot or missing slash
                  image: '$BASE_API_URL/${iconUrl.replaceAll("wwwroot/", "")}',
                  fit: BoxFit.contain,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: iconSize,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ),
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
