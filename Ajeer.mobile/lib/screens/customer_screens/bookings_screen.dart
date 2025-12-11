import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import '../../models/booking.dart';

enum _BookingStatus { active, pending, closed }

class BookingsScreen extends StatefulWidget {
  final Booking? newBooking;
  final String? resolvedCityArea;
  final String? resolvedAddress;

  const BookingsScreen({
    super.key,
    this.newBooking,
    this.resolvedCityArea,
    this.resolvedAddress,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsConstants {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color subtleDark = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const double logoHeight = 105.0;
  static const double borderRadius = 50.0;
  static const double navBarHeight = 86.0;
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<int> _selectedActiveIndices = {};
  final Set<int> _selectedClosedIndices = {};
  final List<Booking> _pendingBookings = [];

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

  @override
  void initState() {
    super.initState();
    if (widget.newBooking != null) _pendingBookings.add(widget.newBooking!);
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_isSelectionMode) _exitSelectionMode();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedActiveIndices.clear();
      _selectedClosedIndices.clear();
    });
  }

  void _toggleSelection(int index, Set<int> selectionSet) {
    setState(() {
      if (selectionSet.contains(index)) {
        selectionSet.remove(index);
      } else {
        selectionSet.add(index);
      }
      _isSelectionMode = selectionSet.isNotEmpty;
    });
  }

  void _onBookingTap(int index) {
    if (_tabController.index == 0)
      _toggleSelection(index, _selectedActiveIndices);
    if (_tabController.index == 2)
      _toggleSelection(index, _selectedClosedIndices);
  }

  void _onBookingLongPress(int index) {
    setState(() => _isSelectionMode = true);
    _onBookingTap(index);
  }

  void _deleteSelectedClosedBookings() {
    final sortedIndices = _selectedClosedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final index in sortedIndices) {
        if (index < _closedBookings.length) _closedBookings.removeAt(index);
      }
      _exitSelectionMode();
    });
  }

  void _cancelPendingBooking(Booking booking) {
    setState(() {
      _pendingBookings.remove(booking);
      _closedBookings.insert(0, {
        'provider': booking.provider,
        'service': '${booking.serviceName}, ${booking.unitType}',
        'status': 'Cancelled',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeParams = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeParams.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final whiteContainerTop = screenHeight * 0.25;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            _buildGradientBackground(whiteContainerTop),
            _buildHeader(isDarkMode),
            _buildMainContent(whiteContainerTop, isDarkMode),
            _buildFloatingHomeIcon(whiteContainerTop, isDarkMode),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          items: const [
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
            {
              'label': 'Home',
              'icon': Icons.home_outlined,
              'activeIcon': Icons.home,
            },
          ],
          selectedIndex: _selectedIndex,
          onIndexChanged: (index) =>
              _handleNavigation(index, context, themeParams),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (_isSelectionMode && _tabController.index == 2)
            ? FloatingActionButton(
                backgroundColor: _BookingsConstants.primaryRed,
                onPressed: _deleteSelectedClosedBookings,
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : null,
      ),
    );
  }

  void _handleNavigation(int index, BuildContext context, ThemeNotifier theme) {
    if (_isSelectionMode) _exitSelectionMode();
    if (index == _selectedIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = ProfileScreen(themeNotifier: theme);
        break;
      case 1:
        screen = const ChatScreen();
        break;
      case 3:
        screen = HomeScreen(themeNotifier: theme);
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildGradientBackground(double height) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: height + 50,
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

  Widget _buildHeader(bool isDarkMode) {
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
                : [
                    const Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHomeIcon(double containerTop, bool isDarkMode) {
    return Positioned(
      top: containerTop - _BookingsConstants.logoHeight + 10,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          isDarkMode ? 'assets/image/home_dark.png' : 'assets/image/home.png',
          width: 140,
          height: _BookingsConstants.logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildMainContent(double top, bool isDarkMode) {
    final bottomPadding =
        _BookingsConstants.navBarHeight + MediaQuery.of(context).padding.bottom;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_BookingsConstants.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Bookings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CustomTabBar(
                tabController: _tabController,
                counts: [
                  _activeBookings.length,
                  _pendingBookings.length,
                  _closedBookings.length,
                ],
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(
                    context,
                    _activeBookings,
                    _BookingStatus.active,
                    bottomPadding,
                    isDarkMode,
                  ),
                  _buildList(
                    context,
                    [],
                    _BookingStatus.pending,
                    bottomPadding,
                    isDarkMode,
                  ), // Pending uses local list
                  _buildList(
                    context,
                    _closedBookings,
                    _BookingStatus.closed,
                    bottomPadding,
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Map<String, dynamic>> items,
    _BookingStatus status,
    double padding,
    bool isDarkMode,
  ) {
    // Handle Pending List (from Booking models)
    if (status == _BookingStatus.pending) {
      if (_pendingBookings.isEmpty)
        return _emptyState(isDarkMode, 'No pending bookings.');

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 10, 20, padding),
        itemCount: _pendingBookings.length,
        itemBuilder: (_, i) {
          final booking = _pendingBookings[i];
          return _BookingItem(
            provider: booking.provider,
            service: '${booking.serviceName} - ${booking.unitType}',
            status: status,
            isDarkMode: isDarkMode,
            isSelected: false,
            onTap: () {},
            onLongPress: () {},
            onCancel: () => _cancelPendingBooking(booking),
            onInfoTap: () => _showBookingDetails(context, booking, isDarkMode),
          );
        },
      );
    }

    // Handle Active/Closed Lists (from Maps)
    if (items.isEmpty) return _emptyState(isDarkMode, 'No bookings here.');

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 10, 20, padding),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isSelected = status == _BookingStatus.active
            ? _selectedActiveIndices.contains(i)
            : _selectedClosedIndices.contains(i);

        return _BookingItem(
          provider: item['provider'],
          service: item['service'],
          status: status,
          closedStatus: item['status'],
          isDarkMode: isDarkMode,
          isSelected: isSelected,
          onTap: () => _onBookingTap(i),
          onLongPress: () => _onBookingLongPress(i),
        );
      },
    );
  }

  Widget _emptyState(bool isDarkMode, String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showBookingDetails(
    BuildContext context,
    Booking booking,
    bool isDarkMode,
  ) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final duration =
        '${booking.totalTimeMinutes ~/ 60}h ${booking.totalTimeMinutes % 60}m';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _BookingsConstants.subtleDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Center(
          child: Text(
            booking.serviceName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Provider', booking.provider, isDarkMode),
              _infoRow(
                'Location',
                widget.resolvedCityArea ?? booking.location,
                isDarkMode,
              ),
              _infoRow(
                'Date',
                dateFormat.format(booking.selectedDate),
                isDarkMode,
              ),
              _infoRow(
                'Time',
                timeFormat.format(
                  DateTime(
                    0,
                    1,
                    1,
                    booking.selectedTime.hour,
                    booking.selectedTime.minute,
                  ),
                ),
                isDarkMode,
              ),
              _infoRow('Duration', duration, isDarkMode),
              _infoRow(
                'Cost',
                'JOD ${booking.totalPrice.toStringAsFixed(2)}',
                isDarkMode,
              ),
              if (booking.userDescription?.isNotEmpty == true)
                _infoRow('Note', booking.userDescription!, isDarkMode),
              if (booking.uploadedFiles?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                const Text(
                  'Media:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: booking.uploadedFiles!
                      .map((f) => _buildThumbnail(f))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontFamily: 'Segoe UI',
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(File file) {
    final path = file.path.toLowerCase();
    IconData icon = Icons.insert_drive_file;
    if (path.endsWith('.jpg') || path.endsWith('.png')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
      );
    }
    if (path.endsWith('.mp4')) icon = Icons.videocam;
    if (path.endsWith('.mp3')) icon = Icons.mic;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 30),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final String provider;
  final String service;
  final _BookingStatus status;
  final String? closedStatus;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onCancel;
  final VoidCallback? onInfoTap;

  const _BookingItem({
    required this.provider,
    required this.service,
    required this.status,
    this.closedStatus,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    required this.onLongPress,
    this.onCancel,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final letter = provider.isNotEmpty ? provider[0].toUpperCase() : '?';
    final avatarColor =
        Colors.primaries[letter.hashCode % Colors.primaries.length];

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDarkMode ? _BookingsConstants.subtleDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected
                ? _BookingsConstants.primaryRed
                : (isDarkMode
                      ? _BookingsConstants.darkBorder
                      : Colors.grey.shade300),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDarkMode
                    ? avatarColor.shade900
                    : avatarColor.shade100,
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isDarkMode
                        ? avatarColor.shade100
                        : avatarColor.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (status == _BookingStatus.active) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 22,
            ),
            onPressed: () => _confirmAction(
              context,
              'Message Provider',
              'Message $provider?',
              'Message',
              _BookingsConstants.primaryBlue,
              () {},
            ),
          ),
          const SizedBox(width: 4),
          _actionButton(context, 'Cancel', Colors.red, isDestructive: true),
        ],
      );
    }

    if (status == _BookingStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(
            context,
            'Cancel',
            Colors.red,
            isDestructive: true,
            onTapOverride: onCancel,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: onInfoTap,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      );
    }

    // Closed
    final isCompleted = closedStatus == 'Completed';
    final color = isCompleted ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? color.shade900 : color.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        closedStatus ?? 'Closed',
        style: TextStyle(
          color: isDarkMode ? color.shade100 : color.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    MaterialColor color, {
    bool isDestructive = false,
    VoidCallback? onTapOverride,
  }) {
    final bg = isDarkMode ? color.shade900 : color.shade100;
    final fg = isDarkMode ? color.shade100 : color;

    // For the Active "Cancel" specifically, user asked for Red Circle with White text
    // But generalized for Pending/Active reuse based on "red" intent
    final isSolidRed = label == 'Cancel' && status == _BookingStatus.active;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSolidRed ? _BookingsConstants.primaryRed : bg,
        foregroundColor: isSolidRed ? Colors.white : fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => _confirmAction(
        context,
        'Cancel Booking',
        'Are you sure you want to cancel?',
        'Confirm',
        _BookingsConstants.primaryRed,
        onTapOverride ?? () {},
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    String btnText,
    Color btnColor,
    VoidCallback onConfirm,
  ) {
    // Reuse message style but red text for cancel
    final isDestructive = btnColor == _BookingsConstants.primaryRed;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _BookingsConstants.subtleDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDestructive
                ? _BookingsConstants.primaryRed
                : _BookingsConstants.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
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
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  child: Text(
                    btnText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<int> counts;
  final bool isDarkMode;

  const _CustomTabBar({
    required this.tabController,
    required this.counts,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDarkMode
                ? _BookingsConstants.subtleDark
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _tabItem('Active', 0, Colors.green),
              _tabItem('Pending', 1, Colors.orange),
              _tabItem('Closed', 2, _BookingsConstants.primaryBlue),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItem(String text, int index, Color badgeColor) {
    final isSelected = tabController.index == index;
    final bg = isSelected
        ? (isDarkMode ? const Color(0xFF424242) : Colors.white)
        : Colors.transparent;
    final fg = isSelected
        ? (isDarkMode ? Colors.white : Colors.black87)
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    return Expanded(
      child: GestureDetector(
        onTap: () => tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.1),
                      blurRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: fg,
                ),
              ),
              if (counts[index] > 0)
                Positioned(
                  top: -8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${counts[index]}',
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
        ),
      ),
    );
  }
}
