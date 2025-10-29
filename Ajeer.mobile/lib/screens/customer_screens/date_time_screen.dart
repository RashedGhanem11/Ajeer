import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'bookings_screen.dart'; // <-- ADDED: Import BookingsScreen

// =========================================================================
// WIDGET 1: THE DATE TIME SCREEN (STATEFUL)
// =========================================================================

class DateTimeScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;

  const DateTimeScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
  });

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
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

  String _selectionMode = 'Custom';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _days = List.generate(30, (i) => DateTime.now().add(Duration(days: i)));
  }

  // =========================================================================
  // 2. STATE-CHANGING METHODS (NAVIGATION FIXED)
  // =========================================================================

  void _onNavItemTapped(int index) {
    if (index == 3) {
      // Go back to the root (HomeScreen)
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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onModeSelected(String mode) {
    setState(() {
      _selectionMode = mode;
    });
  }

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _onDateSelected(pickedDate);
    }
  }

  void _showTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
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
              debugPrint('Next arrow tapped!');
              // TODO: Navigate to the next screen (e.g., Address Screen)
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
        child: const Icon(
          Icons.calendar_today_outlined,
          size: 55.0,
          color: Colors.white,
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
                'Select Date & Time',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 4.0,
                bottom: 10.0,
              ),
              child: Text(
                '${widget.serviceName} - ${widget.unitType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(child: _buildDateTimeContent(bottomNavClearance)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. NEW PRIVATE BUILD HELPERS (for date/time content)
  // =========================================================================

  /// Main content area inside the white container
  Widget _buildDateTimeContent(double bottomNavClearance) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: bottomNavClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopControls(),
          const SizedBox(height: 15),

          // Conditional content based on mode
          if (_selectionMode == 'Custom') ...[
            _buildDateDisplay(),
            _buildDaySlider(),
            const SizedBox(height: 10),
            _buildTimeSelector(),
          ] else ...[
            _buildInstantBookingCard(),
          ],
        ],
      ),
    );
  }

  /// The "Custom" / "Instant" buttons
  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildModeChip('Custom', _selectionMode == 'Custom'),
        const SizedBox(width: 8),
        _buildModeChip('Instant', _selectionMode == 'Instant'),
      ],
    );
  }

  /// The date display and edit button
  Widget _buildDateDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.grey[400]!, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(Icons.edit_outlined, color: Colors.blue[700], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Helper for the "Custom" and "Instant" chips
  Widget _buildModeChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onModeSelected(label);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF1976D2),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : Colors.black54,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey[400]!,
        ),
      ),
      elevation: isSelected ? 3 : 0,
    );
  }

  /// The horizontal list of selectable days
  Widget _buildDaySlider() {
    return Container(
      height: 95,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return _buildDayItem(date, isSelected);
        },
      ),
    );
  }

  /// A single item in the horizontal day list
  Widget _buildDayItem(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        width: 65,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.MMM().format(date).toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.E().format(date).toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The button-like display for selecting time
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _showTimePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.grey[400]!, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(Icons.edit_calendar_outlined, color: Colors.blue[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The card shown for "Instant" booking
  Widget _buildInstantBookingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flash_on, color: Colors.blue[700], size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'An Ajeer will be assigned to you as soon as possible based on availability.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: onNextTap,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET 3: CUSTOM BOTTOM NAV BAR (LOCAL)
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
