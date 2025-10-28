import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =========================================================================
// WIDGET 1: THE MAIN SCREEN (STATEFUL)
// This is your "Brain". It holds all the state.
// =========================================================================

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  // =========================================================================
  // 1. STATE VARIABLES AND DATA
  // (All state and data lives here)
  // =========================================================================
  int _selectedIndex = 3;
  String _searchQuery = '';

  final List<Map<String, dynamic>> services = [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Plumbing', 'icon': Icons.plumbing},
    {'name': 'Electrical', 'icon': Icons.electrical_services},
    {'name': 'Gardening', 'icon': Icons.grass},
    {'name': 'Assembly', 'icon': Icons.handyman},
    {'name': 'Painting', 'icon': Icons.format_paint},
    {'name': 'Pest Control', 'icon': Icons.pest_control},
    {'name': 'AC Repair', 'icon': Icons.ac_unit},
    {'name': 'Carpentry', 'icon': Icons.carpenter},
  ];

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
    },
    {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
  ];

  // =========================================================================
  // 2. STATE-CHANGING METHODS
  // (All calls to setState() are consolidated here)
  // =========================================================================

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // =========================================================================
  // 3. MAIN BUILD METHOD (Now much cleaner)
  // (This method just assembles the pieces)
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

    // Layout Variables
    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    // --- FIX FOR OVERFLOW ---
    // This calculation is still needed by the screen to pass down
    // to the ServiceGridView.
    final double navBarHeight = 56.0 + 20.0;
    final double outerBottomMargin = 10.0;
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
        MediaQuery.of(context).padding.bottom;
    // ------------------------

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),

          // REFACTORED: Call the new _buildWhiteContainer
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
          ),

          // REFACTORED: Call the new SearchHeader widget
          SearchHeader(onChanged: _onSearchChanged),

          _buildHomeImage(logoTopPosition, logoHeight),
        ],
      ),
      // REFACTORED: Call the new CustomBottomNavBar widget
      bottomNavigationBar: CustomBottomNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  // =========================================================================
  // 4. PRIVATE BUILD HELPERS
  // (Simple widgets that are only used by this screen)
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

  // REFACTORED: This widget is now much simpler.
  // It only builds the white container and passes data to the ServiceGridView.
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
            const SizedBox(height: 15.0), // Space for overlapping logo
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Select a service',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // REFACTORED: The GridView is now its own widget.
            Expanded(
              child: ServiceGridView(
                services: services,
                searchQuery: _searchQuery,
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
// WIDGET 2: SEARCH HEADER (STATELESS)
// This widget only knows how to build the search bar.
// It reports changes via the `onChanged` callback.
// =========================================================================
class SearchHeader extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchHeader({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // This is the exact same code from your _buildSearchOverlay method.
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      // MODIFICATION: Adjust left padding to account for the IconButton's own padding
      left: 12,
      right: 20,
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

          // --- NEW LAYOUT: Row for Icon + Search Bar ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. THE NEW MENU ICON
              IconButton(
                iconSize: 30.0, // Make it a good, tappable size
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  debugPrint('Menu icon tapped!');
                  // TODO: Add navigation to SettingsScreen here
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
              ),

              // A small gap between icon and search bar
              const SizedBox(width: 4.0),

              // 2. THE SEARCH BAR, WRAPPED IN EXPANDED
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.white, width: 1.5),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
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
                    onChanged: onChanged, // Use the callback
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
            ],
          ),
          // --- END OF MODIFICATION ---
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET 3: SERVICE GRID VIEW (STATELESS)
// This widget only knows how to build the grid.
// It receives all the data it needs as parameters.
// =========================================================================
class ServiceGridView extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final String searchQuery;
  final double bottomPadding;

  const ServiceGridView({
    super.key,
    required this.services,
    required this.searchQuery,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    // The highlighting logic now lives inside the widget that uses it.
    String normalizedQuery = searchQuery.trim().toLowerCase();
    bool shouldHighlight(String serviceName) {
      return normalizedQuery.isNotEmpty &&
          serviceName.toLowerCase().contains(normalizedQuery);
    }

    // This is the exact same code from the Expanded() block
    // in your old _buildWhiteContainer method.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding), // Apply padding
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final serviceName = services[index]['name'];
          return ServiceGridItem(
            icon: services[index]['icon'],
            name: serviceName,
            isHighlighted: shouldHighlight(serviceName),
            onTap: () {
              debugPrint('Service tapped: $serviceName');
            },
          );
        },
      ),
    );
  }
}

// =========================================================================
// WIDGET 4: CUSTOM BOTTOM NAV BAR (STATELESS)
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
                      Icon(
                        isSelected ? item['activeIcon'] : item['icon'],
                        size: 28.0,
                        color: isSelected ? Colors.blue : Colors.grey,
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

// =========================================================================
// WIDGET 5: SERVICE GRID ITEM (STATELESS)
// (This was already well-factored, so it is unchanged)
// =========================================================================
class ServiceGridItem extends StatelessWidget {
  final IconData? icon;
  final String name;
  final bool isHighlighted;
  final VoidCallback onTap;

  const ServiceGridItem({
    super.key,
    required this.icon,
    required this.name,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isHighlighted ? Colors.green : Colors.blue;
    final Color backgroundColor = primaryColor.withOpacity(0.08);
    final Color borderColor = primaryColor.withOpacity(0.1);

    const double iconContainerSize = 80.0;
    const double iconSize = 40.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
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
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isHighlighted ? primaryColor : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
