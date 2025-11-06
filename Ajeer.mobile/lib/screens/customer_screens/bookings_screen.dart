import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // 💡 FIX 1: Import Provider package
import '../../themes/theme_notifier.dart'; // 💡 FIX 2: Import ThemeNotifier definition
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
// Removed: import '../../main.dart'; // Imports themeNotifier

enum _BookingStatus { active, pending, closed }

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsConstants {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color subtleLighterDark = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);

  static const double logoHeight = 105.0;
  static const double borderRadius = 50.0;
  static const double navBarTotalHeight = 56.0 + 20.0 + 10.0;
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;

  bool _isSelectionMode = false;
  final Set<int> _selectedBookingIndices = {};

  final List<Map<String, dynamic>> _pendingBookings = [
    {'provider': 'Ahmad M.', 'service': 'Cleaning, Deep cleaning'},
    {'provider': 'Sara B.', 'service': 'Gardening, Grass cutting'},
  ];
  final List<Map<String, dynamic>> _activeBookings = [
    {'provider': 'Fatima K.', 'service': 'Plumbing, Pipe fix'},
  ];
  final List<Map<String, dynamic>> _closedBookings = [
    {
      'provider': 'Khalid S.',
      'service': 'AC Repair, Full service',
      'status': 'Completed',
    },
    {
      'provider': 'Laila A.',
      'service': 'Pest Control, Indoors',
      'status': 'Cancelled',
    },
  ];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedBookingIndices.clear();
      });
    }
  }

  void _onNavItemTapped(int index) {
    if (_isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedBookingIndices.clear();
      });
    }

    if (index == _selectedIndex) return;

    // 💡 FIX 3: Retrieve themeNotifier using Provider (listen: false for navigation)
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // FIX: Pass the required 'themeNotifier' to ProfileScreen
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

  void _onBookingLongPress(int index) {
    if (_tabController.index == 2) {
      setState(() {
        _isSelectionMode = true;
        _selectedBookingIndices.add(index);
      });
    }
  }

  void _onBookingTap(int index) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedBookingIndices.contains(index)) {
          _selectedBookingIndices.remove(index);
        } else {
          _selectedBookingIndices.add(index);
        }
        if (_selectedBookingIndices.isEmpty) {
          _isSelectionMode = false;
        }
      });
    }
  }

  void _deleteSelectedBookings() {
    if (_tabController.index != 2) return;

    final sortedIndices = _selectedBookingIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      for (final index in sortedIndices) {
        _closedBookings.removeAt(index);
      }
      _isSelectionMode = false;
      _selectedBookingIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 FIX 4: Retrieve isDarkMode via Provider for build
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
    final double whiteContainerTop = screenHeight * 0.25;
    final double logoTopPosition =
        whiteContainerTop - _BookingsConstants.logoHeight + 10.0;
    final double bottomNavClearance =
        _BookingsConstants.navBarTotalHeight +
        MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          setState(() {
            _isSelectionMode = false;
            _selectedBookingIndices.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            _buildBackgroundGradient(whiteContainerTop),
            _buildBookingsHeader(context, isDarkMode), // Passed isDarkMode
            _buildContentContainer(
              containerTop: whiteContainerTop,
              bottomNavClearance: bottomNavClearance,
              isDarkMode: isDarkMode,
            ),
            _buildHomeImage(logoTopPosition, isDarkMode),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          items: _navItems,
          selectedIndex: _selectedIndex,
          onIndexChanged: _onNavItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _isSelectionMode && _tabController.index == 2
            ? FloatingActionButton(
                backgroundColor: _BookingsConstants.primaryRed,
                onPressed: _deleteSelectedBookings,
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : null,
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
            colors: [
              _BookingsConstants.lightBlue,
              _BookingsConstants.primaryBlue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // 💡 FIX 5: Updated method signature to accept isDarkMode
  Widget _buildAjeerTitle(BuildContext context, bool isDarkMode) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Ajeer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            shadows: isDarkMode
                ? null
                : const [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black26,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  // 💡 FIX 6: Updated method to pass isDarkMode from the build method
  Widget _buildBookingsHeader(BuildContext context, bool isDarkMode) {
    return _buildAjeerTitle(context, isDarkMode);
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
          height: _BookingsConstants.logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContentContainer({
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
            topLeft: Radius.circular(_BookingsConstants.borderRadius),
            topRight: Radius.circular(_BookingsConstants.borderRadius),
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
            const SizedBox(height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Bookings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _CustomTabBar(
                tabController: _tabController,
                activeCount: _activeBookings.length,
                pendingCount: _pendingBookings.length,
                closedCount: _closedBookings.length,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(
                    bookings: _activeBookings,
                    status: _BookingStatus.active,
                    bottomPadding: bottomNavClearance,
                    isDarkMode: isDarkMode,
                  ),
                  _buildBookingList(
                    bookings: _pendingBookings,
                    status: _BookingStatus.pending,
                    bottomPadding: bottomNavClearance,
                    isDarkMode: isDarkMode,
                  ),
                  _buildBookingList(
                    bookings: _closedBookings,
                    status: _BookingStatus.closed,
                    bottomPadding: bottomNavClearance,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList({
    required List<Map<String, dynamic>> bookings,
    required _BookingStatus status,
    required double bottomPadding,
    required bool isDarkMode,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No bookings here.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    final double finalBottomPadding =
        _isSelectionMode && status == _BookingStatus.closed
        ? bottomPadding + 80
        : bottomPadding;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 10, 20, finalBottomPadding),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final bool isSelected = _selectedBookingIndices.contains(index);

        return _BookingItem(
          providerName: booking['provider'],
          serviceName: booking['service'],
          status: status,
          closedStatusText: booking['status'],
          isSelected: isSelected,
          onTap: () => _onBookingTap(index),
          onLongPress: () => _onBookingLongPress(index),
          isDarkMode: isDarkMode,
        );
      },
    );
  }
}

class _CustomTabBar extends StatefulWidget {
  final TabController tabController;
  final int activeCount;
  final int pendingCount;
  final int closedCount;
  final bool isDarkMode;

  const _CustomTabBar({
    required this.tabController,
    required this.activeCount,
    required this.pendingCount,
    required this.closedCount,
    required this.isDarkMode,
  });

  @override
  State<_CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<_CustomTabBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_updateSelectedIndex);
    _selectedIndex = widget.tabController.index;
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_updateSelectedIndex);
    super.dispose();
  }

  void _updateSelectedIndex() {
    if (mounted) {
      setState(() {
        _selectedIndex = widget.tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDarkMode
        ? _BookingsConstants.subtleLighterDark
        : Colors.grey.shade200;

    final Color selectedColor = widget.isDarkMode
        ? const Color(0xFF424242)
        : Colors.white;
    final Color shadowColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(
            text: 'Active',
            count: widget.activeCount,
            color: Colors.green,
            index: 0,
            selectedColor: selectedColor,
            shadowColor: shadowColor,
          ),
          _buildTabItem(
            text: 'Pending',
            count: widget.pendingCount,
            color: Colors.orange,
            index: 1,
            selectedColor: selectedColor,
            shadowColor: shadowColor,
          ),
          _buildTabItem(
            text: 'Closed',
            count: widget.closedCount,
            color: _BookingsConstants.primaryBlue,
            index: 2,
            selectedColor: selectedColor,
            shadowColor: shadowColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String text,
    required int count,
    required Color color,
    required int index,
    required Color selectedColor,
    required Color shadowColor,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color textColor = isSelected
        ? (widget.isDarkMode ? Colors.white : Colors.black87)
        : (widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -14,
                      right: -14,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: selectedColor, width: 1.5),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final String providerName;
  final String serviceName;
  final _BookingStatus status;
  final String? closedStatusText;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isDarkMode;

  const _BookingItem({
    required this.providerName,
    required this.serviceName,
    required this.status,
    this.closedStatusText,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.isDarkMode,
  });

  static const double _minActionWidth = 80.0;

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    final bool isDestructive = confirmColor == _BookingsConstants.primaryRed;
    final Color titleColor = isDestructive
        ? _BookingsConstants.primaryRed
        : _BookingsConstants.primaryBlue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _BookingsConstants.subtleLighterDark
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        title: Text(
          title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: confirmColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onConfirm();
                    },
                    child: const Center(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String letter =
        providerName.isNotEmpty && providerName.split(' ')[0].isNotEmpty
        ? providerName.split(' ')[0][0].toUpperCase()
        : '?';

    final int hash = letter.hashCode;
    final MaterialColor avatarBaseColor =
        Colors.primaries[hash % Colors.primaries.length];

    final Color avatarColor = isDarkMode
        ? avatarBaseColor.shade900
        : avatarBaseColor.shade100;
    final Color avatarLetterColor = isDarkMode
        ? avatarBaseColor.shade100
        : avatarBaseColor.shade700;

    final Color cardColor = isDarkMode
        ? _BookingsConstants.subtleLighterDark
        : Colors.white;
    final Color borderColor = isSelected
        ? _BookingsConstants.primaryRed
        : isDarkMode
        ? _BookingsConstants.darkBorder
        : Colors.grey.shade300;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor,
                child: Text(
                  letter,
                  style: TextStyle(
                    color: avatarLetterColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailingWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    switch (status) {
      case _BookingStatus.active:
        final Color iconColor = isDarkMode
            ? Colors.grey.shade400
            : Colors.grey.shade700;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 22,
              icon: Icon(Icons.phone_outlined, color: iconColor),
              onPressed: () => _showConfirmationDialog(
                context,
                title: 'Call Provider',
                content: 'Would you like to call $providerName?',
                confirmText: 'Call',
                confirmColor: _BookingsConstants.primaryBlue,
                onConfirm: () {},
              ),
            ),
            IconButton(
              iconSize: 22,
              icon: Icon(Icons.chat_bubble_outline, color: iconColor),
              onPressed: () => _showConfirmationDialog(
                context,
                title: 'Message Provider',
                content: 'Would you like to message $providerName?',
                confirmText: 'Message',
                confirmColor: _BookingsConstants.primaryBlue,
                onConfirm: () {},
              ),
            ),
          ],
        );

      case _BookingStatus.pending:
        final Color buttonBg = isDarkMode
            ? Colors.red.shade900
            : Colors.red.shade100;

        // FIXED: Lightened the text color for better visibility in Dark Mode
        final Color buttonFg = isDarkMode
            ? Colors.red.shade100
            : _BookingsConstants.primaryRed;

        return Container(
          constraints: const BoxConstraints(minWidth: _minActionWidth),
          child: SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: buttonFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: buttonFg,
                ),
              ),
              onPressed: () => _showConfirmationDialog(
                context,
                title: 'Cancel Booking',
                content: 'Are you sure you want to cancel this booking?',
                confirmText: 'Cancel Booking',
                confirmColor: _BookingsConstants.primaryRed,
                onConfirm: () {},
              ),
            ),
          ),
        );

      case _BookingStatus.closed:
        bool isCompleted = closedStatusText == 'Completed';
        Color color = isCompleted
            ? (isDarkMode ? Colors.green.shade900 : Colors.green.shade100)
            : (isDarkMode ? Colors.red.shade900 : Colors.red.shade100);

        // FIXED: Lightened the text color for better visibility in Dark Mode
        Color textColor = isCompleted
            ? (isDarkMode ? Colors.green.shade100 : Colors.green.shade800)
            : (isDarkMode ? Colors.red.shade100 : Colors.red.shade800);

        return Container(
          constraints: const BoxConstraints(minWidth: _minActionWidth),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              closedStatusText ?? 'Closed',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
    }
  }
}
