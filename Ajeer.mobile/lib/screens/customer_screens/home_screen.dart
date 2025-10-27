import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  // =========================================================================
  // 1. STATE VARIABLES AND DATA
  // =========================================================================
  int _selectedIndex = 3; // Home icon is initially selected
  String _searchQuery = ''; // State variable for search query

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

  // Defines the custom navigation bar items for the new layout
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
  // 2. MAIN BUILD METHOD
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

    // Define Layout Variables for consistency
    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    return Scaffold(
      extendBody:
          true, // Crucial for letting the body extend behind the nav bar
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildWhiteContainer(whiteContainerTop),
          _buildSearchOverlay(context),
          _buildHomeImage(logoTopPosition, logoHeight),
        ],
      ),
      bottomNavigationBar:
          _buildCustomBottomNavigationBar(), // Use the custom widget
    );
  }

  // =========================================================================
  // 3. WIDGET BUILDER METHODS (UI Components)
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

  Widget _buildWhiteContainer(double containerTop) {
    // Logic to determine which service to highlight based on search query
    String normalizedQuery = _searchQuery.trim().toLowerCase();
    bool shouldHighlight(String serviceName) {
      return normalizedQuery.isNotEmpty &&
          serviceName.toLowerCase().contains(normalizedQuery);
    }

    // --- FIX FOR OVERFLOW ---
    // The height of the new, simplified custom nav bar.
    // The container height is 56.0 (standard height) + 20.0 (top/bottom padding of 10.0 each)
    // Outer Padding bottom is 10.0 (custom margin) + safe area.
    final double navBarHeight =
        56.0 +
        20.0; // The explicit height set in _buildCustomBottomNavigationBar
    final double outerBottomMargin =
        10.0; // The bottom padding of the outer Padding widget
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
        MediaQuery.of(context).padding.bottom;
    // ------------------------

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
            // Strong shadow for the main container
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space to align content under the overlapping logo
            const SizedBox(height: 20.0),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15.0,
                ),
                child: GridView.builder(
                  // FIX: Apply calculated padding to the GridView to reserve space
                  padding: EdgeInsets.only(bottom: bottomNavClearance),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 20,
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
                fontSize: 34, // Make it large and prominent
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.white, width: 1.5),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8CCBFF), // Light Blue-ish
                  Color(0xFF1976D2), // Slightly lighter
                ],
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
              onChanged: (value) {
                // Update search query and trigger rebuild to highlight
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                hintStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10, //reduce search bar size vertically
                ),
              ),
            ),
          ),
        ],
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
          'assets/image/home.png', // Ensure this asset path is correct
          width: 140,
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // REFACTORED: Custom Bottom Navigation Bar using Row for stable centering and spacing
  Widget _buildCustomBottomNavigationBar() {
    const double verticalPadding = 10.0;
    const double horizontalPadding = 15.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        MediaQuery.of(context).padding.bottom + 16.0,
      ),
      child: Container(
        height: kBottomNavigationBarHeight + verticalPadding * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0), // Pill shape radius
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
          children: navItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            bool isSelected = index == _selectedIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                behavior:
                    HitTestBehavior.translucent, // Makes entire area tappable
                child: Container(
                  // Use Padding here to adjust spacing/size around icon + label
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Vertically center content
                    children: [
                      Icon(
                        isSelected ? item['activeIcon'] : item['icon'],
                        size: 28.0, // Standard Icon size
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 4), // Space between icon and label
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
// ServiceGridItem (unchanged)
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

    // Original Sizing
    const double iconContainerSize = 80.0;
    const double iconSize = 40.0;

    return GestureDetector(
      onTap: onTap, // Apply the click handler
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
            child: Icon(
              icon,
              size: iconSize,
              color: primaryColor, // Use highlight-dependent color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isHighlighted
                  ? primaryColor
                  : Colors.black87, // Highlight text color
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
