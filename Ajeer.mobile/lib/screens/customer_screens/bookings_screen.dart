import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import '../../models/booking_models.dart';
import '../../services/booking_service.dart';
import '../../services/chat_service.dart';
import '../../models/chat_models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

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
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  List<BookingListItem> _allBookings = [];

  List<BookingListItem> get _activeBookings => _allBookings
      .where(
        (b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inProgress,
      )
      .toList();

  List<BookingListItem> get _pendingBookings =>
      _allBookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingListItem> get _closedBookings => _allBookings
      .where(
        (b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.rejected,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final bookings = await _bookingService.getBookings();

    if (mounted) {
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCancel(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _bookingService.cancelBooking(id);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      _fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to cancel booking')));
    }
  }

  Future<void> _showBookingDetails(int id, bool isDarkMode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final details = await _bookingService.getBookingDetails(id);

    if (!mounted) return;
    Navigator.pop(context);

    if (details != null) {
      showDialog(
        context: context,
        builder: (ctx) =>
            _DetailDialog(details: details, isDarkMode: isDarkMode),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load booking details')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;
    final theme = Provider.of<ThemeNotifier>(context, listen: false);

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = ProfileScreen(themeNotifier: theme);
        break;
      case 1:
        nextScreen = const ChatScreen();
        break;
      case 3:
        nextScreen = HomeScreen(themeNotifier: theme);
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
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

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          _buildGradient(whiteContainerTop),
          _buildHeader(isDarkMode),
          _buildContent(whiteContainerTop, isDarkMode),
          _buildLogo(whiteContainerTop, isDarkMode),
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
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildGradient(double height) {
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

  Widget _buildLogo(double top, bool isDarkMode) {
    return Positioned(
      top: top - _BookingsConstants.logoHeight + 10,
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

  Widget _buildContent(double top, bool isDarkMode) {
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(
                          _activeBookings,
                          _BookingListType.active,
                          bottomPadding,
                          isDarkMode,
                        ),
                        _buildList(
                          _pendingBookings,
                          _BookingListType.pending,
                          bottomPadding,
                          isDarkMode,
                        ),
                        _buildList(
                          _closedBookings,
                          _BookingListType.closed,
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
    List<BookingListItem> items,
    _BookingListType type,
    double padding,
    bool isDarkMode,
  ) {
    if (items.isEmpty) {
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

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 10, 20, padding),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final booking = items[i];
        return _BookingCard(
          booking: booking,
          listType: type,
          isDarkMode: isDarkMode,
          onCancel: () => _handleCancel(booking.id),
          onInfoTap: () => _showBookingDetails(booking.id, isDarkMode),
        );
      },
    );
  }
}

enum _BookingListType { active, pending, closed }

class _BookingCard extends StatelessWidget {
  final BookingListItem booking;
  final _BookingListType listType;
  final bool isDarkMode;
  final VoidCallback onCancel;
  final VoidCallback onInfoTap;

  const _BookingCard({
    required this.booking,
    required this.listType,
    required this.isDarkMode,
    required this.onCancel,
    required this.onInfoTap,
  });

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _BookingsConstants.subtleDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Cancel Booking',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _BookingsConstants.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this booking?',
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
                    backgroundColor: _BookingsConstants.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onCancel();
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context) async {
    final ChatService chatService = ChatService();
    int targetBookingId = booking.id;

    try {
      final conversations = await chatService.getConversations();
      final existing = conversations.firstWhere(
        (c) => c.otherSideName == booking.otherSideName,
        orElse: () => ChatConversation(
          bookingId: -1,
          otherSideName: '',
          lastMessage: '',
          lastMessageFormattedTime: '',
          unreadCount: 0,
        ),
      );

      if (existing.bookingId != -1) {
        targetBookingId = existing.bookingId;
      }
    } catch (e) {
      debugPrint("Error finding existing chat: $e");
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          bookingId: targetBookingId,
          otherSideName: booking.otherSideName,
          chatService: chatService,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _BookingsConstants.subtleDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Message Provider',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _BookingsConstants.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Would you like to message ${booking.otherSideName}?',
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
                    'Cancel',
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
                    backgroundColor: _BookingsConstants.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToChat(context);
                  },
                  child: const Text(
                    'Message',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
    final letter = booking.otherSideName.isNotEmpty
        ? booking.otherSideName[0].toUpperCase()
        : '?';
    final MaterialColor avatarColor =
        Colors.primaries[letter.hashCode % Colors.primaries.length];
    final fullImageUrl = AppConfig.getFullImageUrl(booking.otherSideImageUrl);

    final borderColor = isDarkMode
        ? _BookingsConstants.darkBorder
        : Colors.grey.shade300;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? _BookingsConstants.subtleDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isDarkMode
                  ? avatarColor.shade900
                  : avatarColor.shade100,
              backgroundImage: fullImageUrl.isNotEmpty
                  ? NetworkImage(fullImageUrl)
                  : null,
              child: fullImageUrl.isEmpty
                  ? Text(
                      letter,
                      style: TextStyle(
                        color: isDarkMode
                            ? avatarColor.shade100
                            : avatarColor.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.otherSideName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    booking.serviceName,
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
            const SizedBox(width: 4),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (listType == _BookingListType.active ||
        listType == _BookingListType.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: _BookingsConstants.primaryBlue,
              size: 24,
            ),
            onPressed: onInfoTap,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 22,
            ),
            onPressed: () => _showMessageDialog(context),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 6),
          _cancelButton(context),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (booking.status == BookingStatus.completed)
          IconButton(
            icon: const Icon(
              Icons.star_rate_rounded,
              color: Colors.amber,
              size: 28,
            ),
            onPressed: () {},
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(right: 8),
            visualDensity: VisualDensity.compact,
          ),
        _statusBadge(),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _BookingsConstants.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => _showCancelDialog(context),
      child: const Text(
        'Cancel',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    Color getBg(MaterialColor c) => isDarkMode ? c.shade900 : c.shade100;
    Color getTxt(MaterialColor c) => isDarkMode ? c.shade100 : c.shade800;

    switch (booking.status) {
      case BookingStatus.completed:
        backgroundColor = getBg(Colors.green);
        textColor = getTxt(Colors.green);
        text = "Completed";
        break;
      case BookingStatus.cancelled:
        backgroundColor = getBg(Colors.red);
        textColor = getTxt(Colors.red);
        text = "Cancelled";
        break;
      case BookingStatus.rejected:
        backgroundColor = getBg(Colors.red);
        textColor = getTxt(Colors.red);
        text = "Rejected";
        break;
      default:
        backgroundColor = isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade300;
        textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
        text = "Closed";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailDialog extends StatelessWidget {
  final BookingDetail details;
  final bool isDarkMode;

  const _DetailDialog({required this.details, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return AlertDialog(
      backgroundColor: isDarkMode
          ? _BookingsConstants.subtleDark
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      title: Center(
        child: Text(
          details.serviceName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow('Provider', details.otherSideName, isDarkMode),
            if (details.otherSidePhone.isNotEmpty)
              _infoRow('Phone', details.otherSidePhone, isDarkMode),
            _infoRow('Area', details.areaName, isDarkMode),
            _infoRow('Address', details.address, isDarkMode),
            _infoRow(
              'Date',
              dateFormat.format(details.scheduledDate),
              isDarkMode,
            ),
            _infoRow(
              'Time',
              timeFormat.format(details.scheduledDate),
              isDarkMode,
            ),
            if (details.estimatedTime.isNotEmpty)
              _infoRow('Est. Time', details.estimatedTime, isDarkMode),
            _infoRow('Price', details.formattedPrice, isDarkMode),
            if (details.notes != null && details.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow('Notes', details.notes!, isDarkMode),
            ],
            if (details.attachmentUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Attachments:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.attachmentUrls.map((url) {
                  final fullUrl = AppConfig.getFullImageUrl(url);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fullUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontFamily: 'Segoe UI',
            fontSize: 14,
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
