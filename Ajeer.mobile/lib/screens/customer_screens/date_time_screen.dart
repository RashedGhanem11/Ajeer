import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'location_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';

class DateTimeScreen extends StatefulWidget {
  // --- ADDED: Pass-through data for DTO ---
  final List<int> serviceIds;

  final String serviceName;
  final String unitType;
  final int totalTimeMinutes;
  final double totalPrice;

  const DateTimeScreen({
    super.key,
    required this.serviceIds, // Add this required parameter
    required this.serviceName,
    required this.unitType,
    required this.totalTimeMinutes,
    required this.totalPrice,
  });

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  int _selectedIndex = 3;
  String _selectionMode = 'Custom';
  DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime;
  late List<DateTime> _days;

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

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleDark = Color(0xFF1E1E1E);
  static const Color _subtleLighterDark = Color(0xFF2C2C2C);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _dialogBorderRadius = 38.0;

  @override
  void initState() {
    super.initState();

    // Calculate the time 30 minutes from now
    final DateTime now = DateTime.now();
    final DateTime futureTime = now.add(const Duration(minutes: 30));

    // Set the selected time
    _selectedTime = TimeOfDay.fromDateTime(futureTime);
    _days = List.generate(30, (i) => DateTime.now().add(Duration(days: i)));
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
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
    final isDarkMode = Provider.of<ThemeNotifier>(
      context,
      listen: false,
    ).isDarkMode;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final ColorScheme colorScheme = isDarkMode
            ? const ColorScheme.dark(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                surface: _subtleLighterDark,
                onSurface: Colors.white,
              )
            : const ColorScheme.light(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              );

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryBlue),
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_dialogBorderRadius),
              ),
              backgroundColor: isDarkMode ? _subtleDark : Colors.white,
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
    final isDarkMode = Provider.of<ThemeNotifier>(
      context,
      listen: false,
    ).isDarkMode;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final ColorScheme colorScheme = isDarkMode
            ? const ColorScheme.dark(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                surface: _subtleLighterDark,
                onSurface: Colors.white,
              )
            : const ColorScheme.light(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              );

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primaryBlue),
            ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_dialogBorderRadius),
              ),
              backgroundColor: isDarkMode ? _subtleDark : Colors.white,
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

  void _onNextTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(
          // --- FIX: Pass the IDs to LocationScreen ---
          serviceIds: widget.serviceIds,
          // ------------------------------------------
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          selectionMode: _selectionMode,
          totalTimeMinutes: widget.totalTimeMinutes,
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

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
          _buildServiceIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onNextTap: _onNextTap,
          ),
        ],
      ),
      bottomNavigationBar: _CustomBottomNavBar(
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
          Icons.calendar_today_outlined,
          size: 55.0,
          color: _primaryBlue,
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
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Select date & time',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _buildDateTimeContent(bottomNavClearance, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeContent(double bottomNavClearance, bool isDarkMode) {
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
          _buildTopControls(isDarkMode),
          const SizedBox(height: 15),
          if (_selectionMode == 'Custom') ...[
            _buildDateDisplay(isDarkMode),
            _buildDaySlider(isDarkMode),
            const SizedBox(height: 10),
            _buildTimeSelector(isDarkMode),
          ] else ...[
            _buildInstantBookingCard(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildTopControls(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildModeChip('Custom', _selectionMode == 'Custom', isDarkMode),
        const SizedBox(width: 8),
        _buildModeChip('Instant', _selectionMode == 'Instant', isDarkMode),
      ],
    );
  }

  Widget _buildDateDisplay(bool isDarkMode) {
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color containerColor = isDarkMode
        ? _subtleLighterDark
        : Colors.grey[100]!;
    final Color borderColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[400]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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
              color: containerColor,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                Icon(Icons.edit_outlined, color: Colors.blue[400], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, bool isSelected, bool isDarkMode) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onModeSelected(label);
      },
      backgroundColor: isDarkMode ? _subtleLighterDark : Colors.grey[100],
      selectedColor: _primaryBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected
            ? Colors.white
            : isDarkMode
            ? Colors.white70
            : Colors.black54,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? _primaryBlue
              : isDarkMode
              ? Colors.grey[700]!
              : Colors.grey[400]!,
        ),
      ),
      elevation: isSelected ? 3 : 0,
    );
  }

  Widget _buildDaySlider(bool isDarkMode) {
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

          return _buildDayItem(date, isSelected, isDarkMode);
        },
      ),
    );
  }

  Widget _buildDayItem(DateTime date, bool isSelected, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        width: 65,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_lightBlue, _primaryBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected
              ? null
              : isDarkMode
              ? _subtleDark
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? null
              : Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1.5,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.3),
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
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : isDarkMode
                    ? Colors.grey
                    : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDarkMode
                    ? Colors.white
                    : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.E().format(date).toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : isDarkMode
                    ? Colors.grey
                    : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(bool isDarkMode) {
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color containerColor = isDarkMode
        ? _subtleLighterDark
        : Colors.grey[100]!;
    final Color borderColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[400]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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
              color: containerColor,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                Icon(Icons.edit_calendar_outlined, color: Colors.blue[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstantBookingCard(bool isDarkMode) {
    final Color cardColor = isDarkMode
        ? Colors.blue[900]!.withOpacity(0.3)
        : Colors.blue[50]!;
    final Color cardBorderColor = isDarkMode
        ? Colors.blue[400]!.withOpacity(0.5)
        : Colors.blue[200]!;
    final Color iconColor = isDarkMode ? Colors.blue[400]! : Colors.blue[700]!;
    final Color messageColor = isDarkMode ? Colors.white70 : Colors.blue[900]!;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cardBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flash_on, color: iconColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'An Ajeer will be assigned to you as soon as possible based on availability.',
              style: TextStyle(
                fontSize: 16,
                color: messageColor,
                fontWeight: FontWeight.w500,
              ),
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

class _CustomBottomNavBar extends CustomBottomNavBar {
  const _CustomBottomNavBar({
    required super.items,
    required super.selectedIndex,
    required super.onIndexChanged,
  });
}
