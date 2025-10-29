import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;

  bool _isSelectionMode = false;
  final Set<int> _selectedBookingIndices = {};
  final List<Map<String, dynamic>> pendingBookings = [
    {'provider': 'Ahmad M.', 'service': 'Cleaning, Deep cleaning'},
    {'provider': 'Sara B.', 'service': 'Gardening, Grass cutting'},
  ];
  final List<Map<String, dynamic>> activeBookings = [
    {'provider': 'Fatima K.', 'service': 'Plumbing, Pipe fix'},
  ];
  final List<Map<String, dynamic>> closedBookings = [
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_isSelectionMode) {
        setState(() {
          _isSelectionMode = false;
          _selectedBookingIndices.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (_isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedBookingIndices.clear();
      });
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServiceScreen()),
      );
    } else if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
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
    final sortedIndices = _selectedBookingIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      for (final index in sortedIndices) {
        closedBookings.removeAt(index);
      }
      _isSelectionMode = false;
      _selectedBookingIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;

    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.25;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    const double navBarHeight = 56.0 + 20.0;
    const double outerBottomMargin = 10.0;
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
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
        body: Stack(
          children: [
            _buildBackgroundGradient(whiteContainerTop),
            _buildBookingsHeader(context),
            _buildWhiteContainer(
              containerTop: whiteContainerTop,
              bottomNavClearance: bottomNavClearance,
            ),
            _buildHomeImage(logoTopPosition, logoHeight),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          items: navItems,
          selectedIndex: _selectedIndex,
          onIndexChanged: _onNavItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _isSelectionMode
            ? FloatingActionButton(
                backgroundColor: Colors.red[700],
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
            colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

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

  Widget _buildBookingsHeader(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      right: 10,
      child: Stack(alignment: Alignment.center, children: [_buildAjeerTitle()]),
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
                'Bookings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _CustomTabBar(
                tabController: _tabController,
                activeCount: activeBookings.length,
                pendingCount: pendingBookings.length,
                closedCount: closedBookings.length,
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(
                    bookings: activeBookings,
                    status: _BookingStatus.active,
                    bottomPadding: bottomNavClearance,
                  ),
                  _buildBookingList(
                    bookings: pendingBookings,
                    status: _BookingStatus.pending,
                    bottomPadding: bottomNavClearance,
                  ),
                  _buildBookingList(
                    bookings: closedBookings,
                    status: _BookingStatus.closed,
                    bottomPadding: bottomNavClearance,
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
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No bookings here.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    final double finalBottomPadding =
        _isSelectionMode && _tabController.index == 2
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

  const _CustomTabBar({
    Key? key,
    required this.tabController,
    required this.activeCount,
    required this.pendingCount,
    required this.closedCount,
  }) : super(key: key);

  @override
  State<_CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<_CustomTabBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedIndex = widget.tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(
            text: 'Active',
            count: widget.activeCount,
            color: Colors.green,
            index: 0,
          ),
          _buildTabItem(
            text: 'Pending',
            count: widget.pendingCount,
            color: Colors.orange,
            index: 1,
          ),
          _buildTabItem(
            text: 'Closed',
            count: widget.closedCount,
            color: Colors.blue,
            index: 2,
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
  }) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.black87 : Colors.grey[600],
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
                          border: Border.all(color: Colors.white, width: 1.5),
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

enum _BookingStatus { active, pending, closed }

class _BookingItem extends StatelessWidget {
  final String providerName;
  final String serviceName;
  final _BookingStatus status;
  final String? closedStatusText;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BookingItem({
    Key? key,
    required this.providerName,
    required this.serviceName,
    required this.status,
    this.closedStatusText,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    const Color primaryRed = Color(0xFFD32F2F);
    final bool isDestructive = confirmColor == primaryRed;
    final Color titleColor = isDestructive
        ? primaryRed
        : const Color(0xFF1976D2);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        title: Text(
          title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(content, textAlign: TextAlign.center),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 16.0),
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
                    child: Center(
                      child: Text(
                        confirmText,
                        style: const TextStyle(
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
    String letter = '?';
    if (providerName.isNotEmpty) {
      final List<String> parts = providerName.split(' ');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        letter = parts[0][0].toUpperCase();
      }
    }

    final Color avatarColor =
        Colors.primaries[letter.hashCode % Colors.primaries.length].shade100;
    final Color avatarLetterColor =
        Colors.primaries[letter.hashCode % Colors.primaries.length].shade700;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? Colors.red : Colors.grey[300]!,
            width: 2.0,
          ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
    const Color primaryBlue = Color(0xFF1976D2);
    const Color primaryRed = Color(0xFFD32F2F);

    switch (status) {
      case _BookingStatus.active:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 22,
              icon: Icon(Icons.phone_outlined, color: Colors.grey[700]),
              onPressed: () => _showConfirmationDialog(
                context,
                title: 'Call Provider',
                content: 'Would you like to call $providerName?',
                confirmText: 'Call',
                confirmColor: primaryBlue,
                onConfirm: () => debugPrint('Calling provider...'),
              ),
            ),
            IconButton(
              iconSize: 22,
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[700]),
              onPressed: () => _showConfirmationDialog(
                context,
                title: 'Message Provider',
                content: 'Would you like to message $providerName?',
                confirmText: 'Message',
                confirmColor: primaryBlue,
                onConfirm: () => debugPrint('Messaging provider...'),
              ),
            ),
          ],
        );

      case _BookingStatus.pending:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: primaryRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                onPressed: () => _showConfirmationDialog(
                  context,
                  title: 'Cancel Booking',
                  content: 'Are you sure you want to cancel this booking?',
                  confirmText: 'Cancel Booking',
                  confirmColor: primaryRed,
                  onConfirm: () {
                    debugPrint('Cancelling booking...');
                  },
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  icon: Icon(Icons.phone_outlined, color: Colors.grey[700]),
                  onPressed: () => _showConfirmationDialog(
                    context,
                    title: 'Call Provider',
                    content: 'Would you like to call $providerName?',
                    confirmText: 'Call',
                    confirmColor: primaryBlue,
                    onConfirm: () => debugPrint('Calling provider...'),
                  ),
                ),
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey[700],
                  ),
                  onPressed: () => _showConfirmationDialog(
                    context,
                    title: 'Message Provider',
                    content: 'Would you like to message $providerName?',
                    confirmText: 'Message',
                    confirmColor: primaryBlue,
                    onConfirm: () => debugPrint('Messaging provider...'),
                  ),
                ),
              ],
            ),
          ],
        );

      case _BookingStatus.closed:
        bool isCompleted = closedStatusText == 'Completed';
        return Container(
          constraints: const BoxConstraints(minWidth: 90),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              closedStatusText ?? 'Closed',
              style: TextStyle(
                color: isCompleted ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
    }
  }
}
