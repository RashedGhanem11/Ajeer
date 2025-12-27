import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'location_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import 'home_screen.dart';
import 'dart:ui';
import '../../widgets/shared_widgets/snackbar.dart';

class DateTimeScreen extends StatefulWidget {
  final List<int> serviceIds;
  final String serviceName;
  final String unitType;
  final int totalTimeMinutes;
  final double totalPrice;

  const DateTimeScreen({
    super.key,
    required this.serviceIds,
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

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleDark = Color(0xFF1E1E1E);
  static const Color _subtleLighterDark = Color(0xFF2C2C2C);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _dialogBorderRadius = 40.0;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime futureTime = now.add(const Duration(minutes: 30));
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
      if (mode == 'Instant') {
        final DateTime now = DateTime.now();
        final DateTime futureTime = now.add(const Duration(minutes: 30));
        _selectedTime = TimeOfDay.fromDateTime(futureTime);
      }
    });
  }

  void _showDatePicker() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;
    final lang = Provider.of<LanguageNotifier>(context, listen: false);

    final pickedDate = await showDatePicker(
      context: context,
      locale: lang.appLocale,
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

        return Localizations.override(
          context: context,
          locale: lang.appLocale,
          child: Theme(
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
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: child!,
            ),
          ),
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _onDateSelected(pickedDate);
    }
  }

  void _showTimePicker() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;
    final lang = Provider.of<LanguageNotifier>(context, listen: false);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final ColorScheme colorScheme = isDarkMode
            ? const ColorScheme.dark(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                surface: _subtleDark,
                onSurface: Colors.white,
                secondaryContainer: _primaryBlue,
                onSecondaryContainer: Colors.white,
              )
            : const ColorScheme.light(
                primary: _primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
                secondaryContainer: _secondaryLightBlue,
              );

        return Localizations.override(
          context: context,
          locale: lang.appLocale,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: colorScheme,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              timePickerTheme: TimePickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_dialogBorderRadius),
                ),
                backgroundColor: isDarkMode ? _subtleDark : Colors.white,
                dialBackgroundColor: isDarkMode
                    ? _subtleLighterDark
                    : Colors.grey.shade200,
                dialHandColor: _primaryBlue,
                entryModeIconColor: _primaryBlue,
                dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected))
                    return Colors.white;
                  return isDarkMode ? Colors.white70 : Colors.black87;
                }),
                dayPeriodColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected))
                    return _primaryBlue;
                  return Colors.transparent;
                }),
                dayPeriodBorderSide: const BorderSide(color: _primaryBlue),
                hourMinuteTextColor: isDarkMode ? Colors.white : Colors.black87,
                hourMinuteColor: isDarkMode
                    ? _subtleLighterDark
                    : Colors.grey.shade200,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: child!,
            ),
          ),
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      bool isToday =
          _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      if (isToday) {
        final pickedMinutes = pickedTime.hour * 60 + pickedTime.minute;
        final currentMinutes = now.hour * 60 + now.minute;

        if (pickedMinutes <= currentMinutes) {
          if (mounted) {
            CustomSnackBar.show(
              context,
              messageKey: 'selectFutureTime',
              backgroundColor: Colors.red,
            );
          }
          return;
        }
      }

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
          serviceIds: widget.serviceIds,
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
    final lang = Provider.of<LanguageNotifier>(context);

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

    final List<Map<String, dynamic>> navItems = [
      {
        'label': lang.translate('profile'),
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
      {
        'label': lang.translate('chat'),
        'icon': Icons.chat_bubble_outline,
        'activeIcon': Icons.chat_bubble,
      },
      {
        'label': lang.translate('bookings'),
        'icon': Icons.book_outlined,
        'activeIcon': Icons.book,
        'notificationCount': 3,
      },
      {
        'label': lang.translate('home'),
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
    ];

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
            lang: lang,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onNextTap: _onNextTap,
            lang: lang,
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

    return PositionedDirectional(
      top: iconTopPosition,
      end: 25.0,
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
    required LanguageNotifier lang,
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
              padding: const EdgeInsetsDirectional.only(start: 20.0, top: 20.0),
              child: Text(
                lang.translate('selectDateTime'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _buildDateTimeContent(
                bottomNavClearance,
                isDarkMode,
                lang,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeContent(
    double bottomNavClearance,
    bool isDarkMode,
    LanguageNotifier lang,
  ) {
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
          _buildTopControls(isDarkMode, lang),
          const SizedBox(height: 15),
          if (_selectionMode == 'Custom') ...[
            _buildDateDisplay(isDarkMode, lang),
            _buildDaySlider(isDarkMode, lang),
            const SizedBox(height: 10),
            _buildTimeSelector(isDarkMode, lang),
          ] else ...[
            _buildInstantBookingCard(isDarkMode, lang),
          ],
        ],
      ),
    );
  }

  Widget _buildTopControls(bool isDarkMode, LanguageNotifier lang) {
    return Row(
      children: [
        _buildModeChip('Custom', _selectionMode == 'Custom', isDarkMode, lang),
        const SizedBox(width: 8),
        _buildModeChip(
          'Instant',
          _selectionMode == 'Instant',
          isDarkMode,
          lang,
        ),
      ],
    );
  }

  Widget _buildDateDisplay(bool isDarkMode, LanguageNotifier lang) {
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
          lang.translate('selectDate'),
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
                  lang.convertNumbers(
                    DateFormat.yMMMMd(
                      lang.appLocale.languageCode,
                    ).format(_selectedDate),
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(
    String modeKey,
    bool isSelected,
    bool isDarkMode,
    LanguageNotifier lang,
  ) {
    return GestureDetector(
      onTap: () => _onModeSelected(modeKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryBlue
              : (isDarkMode ? _subtleLighterDark : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[400]!),
          ),
        ),
        child: Text(
          lang.translate(modeKey.toLowerCase()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySlider(bool isDarkMode, LanguageNotifier lang) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return _BounceableDayItem(
            date: date,
            isSelected: isSelected,
            isDarkMode: isDarkMode,
            onTap: () => _onDateSelected(date),
            lang: lang,
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector(bool isDarkMode, LanguageNotifier lang) {
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
          lang.translate('selectTime'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
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
                  lang.convertNumbers(_selectedTime.format(context)),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                Icon(Icons.access_time_outlined, color: Colors.blue[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstantBookingCard(bool isDarkMode, LanguageNotifier lang) {
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
              lang.translate('instantBookingMsg'),
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

class _BounceableDayItem extends StatefulWidget {
  final DateTime date;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;
  final LanguageNotifier lang;

  const _BounceableDayItem({
    required this.date,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    required this.lang,
  });

  @override
  State<_BounceableDayItem> createState() => _BounceableDayItemState();
}

class _BounceableDayItemState extends State<_BounceableDayItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightBlue = Color(0xFF8CCBFF);
    const Color primaryBlue = Color(0xFF1976D2);
    const Color subtleDark = Color(0xFF1E1E1E);

    return GestureDetector(
      onTap: _handleTap,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 65,
            height: 95,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? const LinearGradient(
                      colors: [lightBlue, primaryBlue],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: widget.isSelected
                  ? null
                  : (widget.isDarkMode ? subtleDark : Colors.grey[100]),
              borderRadius: BorderRadius.circular(15),
              border: widget.isSelected
                  ? null
                  : Border.all(
                      color: widget.isDarkMode
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
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
                  DateFormat.MMM(
                    widget.lang.appLocale.languageCode,
                  ).format(widget.date).toUpperCase(),
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.9)
                        : (widget.isDarkMode ? Colors.grey : Colors.grey[600]),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.lang.convertNumbers(widget.date.day.toString()),
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white
                        : (widget.isDarkMode ? Colors.white : Colors.black87),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat.E(
                    widget.lang.appLocale.languageCode,
                  ).format(widget.date).toUpperCase(),
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.9)
                        : (widget.isDarkMode ? Colors.grey : Colors.grey[600]),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

class _NavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final LanguageNotifier lang;

  const _NavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    required this.lang,
  });

  @override
  State<_NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<_NavigationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            onPressed: widget.onBackTap,
          ),
          Text(
            widget.lang.translate('appName'),
            style: const TextStyle(
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
          Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
              IconButton(
                iconSize: 28.0,
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: widget.onNextTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
