import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../config/app_config.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import '../../models/booking_models.dart';
import '../../models/review_models.dart';
import '../../services/booking_service.dart';
import '../../services/review_service.dart';
import '../../services/chat_service.dart';
import '../shared_screens/chat_screen.dart';
import '../shared_screens/profile_screen.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _Consts {
  static const primaryBlue = Color(0xFF2f6cfa);
  static const lightBlue = Color(0xFFa2bdfc);
  static const primaryRed = Color(0xFFD32F2F);
  static const successGreen = Color(0xFF2E7D32);
  static const subtleDark = Color(0xFF2C2C2C);
  static const darkBorder = Color(0xFF3A3A3A);
  static const logoHeight = 105.0;
  static const borderRadius = 50.0;
  static const navBarHeight = 86.0;
}

const List<Color> _vibrantColors = [
  Color(0xFFE57373),
  Color(0xFFF06292),
  Color(0xFFBA68C8),
  Color(0xFF64B5F6),
  Color(0xFF4DB6AC),
  Color(0xFF81C784),
  Color(0xFFFFD54F),
  Color(0xFFFF8A65),
];

Color _getAvatarColor(String name) {
  if (name.isEmpty) return Colors.grey;
  final int index = name.hashCode.abs() % _vibrantColors.length;
  return _vibrantColors[index];
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  late TabController _tabController;
  final _bookingService = BookingService();
  bool _isLoading = true;
  List<BookingListItem> _allBookings = [];

  List<BookingListItem> get _active => _allBookings
      .where(
        (b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inProgress,
      )
      .toList();

  List<BookingListItem> get _pending =>
      _allBookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingListItem> get _closed => _allBookings
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final bookings = await _bookingService.getBookings(role: 'serviceprovider');
    if (mounted) {
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(int id, String actionType) async {
    _showLoading();
    bool success = false;
    String message = '';

    switch (actionType) {
      case 'cancel':
        success = await _bookingService.cancelBooking(id);
        message = 'Booking cancelled.';
        break;
      case 'accept':
        success = await _bookingService.acceptBooking(id);
        message = 'Booking accepted.';
        break;
      case 'reject':
        success = await _bookingService.rejectBooking(id);
        message = 'Booking rejected.';
        break;
      case 'complete':
        success = await _bookingService.completeBooking(id);
        message = 'Booking completed.';
        break;
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      _fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _showBookingDetails(int id, bool isDarkMode) async {
    _showLoading();
    final details = await _bookingService.getBookingDetails(id);
    if (!mounted) return;
    Navigator.pop(context);
    if (details != null) {
      showDialog(
        context: context,
        builder: (_) => _DetailDialog(details: details, isDarkMode: isDarkMode),
      );
    }
  }

  Future<void> _showBookingLocation(int id, bool isDarkMode) async {
    _showLoading();
    final details = await _bookingService.getBookingDetails(id);
    if (!mounted) return;
    Navigator.pop(context);

    if (details != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _BookingMapScreen(
            latitude: details.latitude,
            longitude: details.longitude,
            isDarkMode: isDarkMode,
          ),
        ),
      );
    }
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
    final topHeight = screenHeight * 0.25;

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
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: topHeight + 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_Consts.lightBlue, _Consts.primaryBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
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
          ),
          Positioned(
            top: topHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_Consts.borderRadius),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                      counts: [_active.length, _pending.length, _closed.length],
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
                                _active,
                                _BookingListType.active,
                                isDarkMode,
                              ),
                              _buildList(
                                _pending,
                                _BookingListType.pending,
                                isDarkMode,
                              ),
                              _buildList(
                                _closed,
                                _BookingListType.closed,
                                isDarkMode,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: topHeight - _Consts.logoHeight + 10,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                isDarkMode
                    ? 'assets/image/home_dark.png'
                    : 'assets/image/home.png',
                width: 140,
                height: _Consts.logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
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
        ],
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildList(
    List<BookingListItem> items,
    _BookingListType type,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No jobs found.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }
    final padding =
        _Consts.navBarHeight + MediaQuery.of(context).padding.bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 10, 20, padding),
      itemCount: items.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: items[i],
        listType: type,
        isDarkMode: isDark,
        onAction: (action) => _handleAction(items[i].id, action),
        onInfoTap: () => _showBookingDetails(items[i].id, isDark),
        onLocationTap: () => _showBookingLocation(items[i].id, isDark),
      ),
    );
  }
}

enum _BookingListType { active, pending, closed }

class _BookingCard extends StatefulWidget {
  final BookingListItem booking;
  final _BookingListType listType;
  final bool isDarkMode;
  final Function(String) onAction;
  final VoidCallback onInfoTap;
  final VoidCallback onLocationTap;

  const _BookingCard({
    required this.booking,
    required this.listType,
    required this.isDarkMode,
    required this.onAction,
    required this.onInfoTap,
    required this.onLocationTap,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  late AnimationController _jumpController;
  late Animation<Offset> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _jumpAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.2)).animate(
          CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut),
        );

    if (widget.listType == _BookingListType.active ||
        widget.listType == _BookingListType.pending) {
      _bounceController.repeat(reverse: true);
    }

    if (widget.listType == _BookingListType.closed &&
        widget.booking.hasReview) {
      _jumpController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  Future<void> _handleReviewTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final service = ReviewService();
    final review = await service.getReview(widget.booking.id);

    if (context.mounted) Navigator.pop(context);

    if (context.mounted && review != null) {
      showDialog(
        context: context,
        builder: (_) => _ReviewDialog(
          bookingId: widget.booking.id,
          isDarkMode: widget.isDarkMode,
          existingReview: review,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No review found for this booking.')),
      );
    }
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? _Consts.subtleDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          'Message Customer',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _Consts.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Would you like to message ${widget.booking.otherSideName}?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey.shade300 : Colors.black87,
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
                      color: widget.isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Consts.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          bookingId: widget.booking.id,
                          otherSideName: widget.booking.otherSideName,
                          chatService: ChatService(),
                          isDarkMode: widget.isDarkMode,
                          primaryColor: _Consts.primaryBlue,
                        ),
                      ),
                    );
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

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String action,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDarkMode ? _Consts.subtleDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey.shade300 : Colors.black87,
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
                      color: widget.isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onAction(action);
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

  @override
  Widget build(BuildContext context) {
    final letter = widget.booking.otherSideName.isNotEmpty
        ? widget.booking.otherSideName[0].toUpperCase()
        : '?';
    final avatarColor = _getAvatarColor(widget.booking.otherSideName);
    final fullImageUrl = AppConfig.getFullImageUrl(
      widget.booking.otherSideImageUrl,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.isDarkMode ? _Consts.subtleDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: widget.isDarkMode ? _Consts.darkBorder : Colors.grey.shade300,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor,
              backgroundImage: fullImageUrl.isNotEmpty
                  ? NetworkImage(fullImageUrl)
                  : null,
              child: fullImageUrl.isEmpty
                  ? Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.white,
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
                    widget.booking.otherSideName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    widget.booking.serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    List<Widget> icons = [];

    if (widget.listType == _BookingListType.active) {
      icons.add(
        _iconBtn(
          Icons.chat_bubble_outline,
          widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          22,
          () => _showMessageDialog(context),
        ),
      );
    }

    if (widget.booking.status == BookingStatus.completed &&
        widget.booking.hasReview) {
      icons.add(
        SlideTransition(
          position: _jumpAnimation,
          child: _iconBtn(
            Icons.star_rounded,
            Colors.amber,
            24,
            () => _handleReviewTap(context),
          ),
        ),
      );
    }

    icons.add(
      _iconBtn(
        Icons.location_on_outlined,
        _Consts.primaryBlue,
        24,
        widget.onLocationTap,
      ),
    );
    icons.add(
      _iconBtn(Icons.info_outline, _Consts.primaryBlue, 24, widget.onInfoTap),
    );

    if (widget.listType == _BookingListType.active) {
      return Column(
        children: [
          Row(children: icons),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionButton(
                'Cancel',
                _Consts.primaryRed,
                () => _showConfirmationDialog(
                  context,
                  'Cancel Booking',
                  'Cancel this booking?',
                  'cancel',
                  _Consts.primaryRed,
                ),
              ),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _actionButton(
                  'Complete',
                  _Consts.successGreen,
                  () => _showConfirmationDialog(
                    context,
                    'Complete Job',
                    'Mark this job as completed?',
                    'complete',
                    _Consts.successGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (widget.listType == _BookingListType.pending) {
      return Column(
        children: [
          Row(children: icons),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionButton(
                'Reject',
                _Consts.primaryRed,
                () => _showConfirmationDialog(
                  context,
                  'Reject Booking',
                  'Reject this request?',
                  'reject',
                  _Consts.primaryRed,
                ),
              ),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _actionButton(
                  'Accept',
                  _Consts.successGreen,
                  () => widget.onAction('accept'),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(children: icons),
          const SizedBox(height: 4),
          _statusBadge(),
        ],
      );
    }
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, double size, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onTap,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _statusBadge() {
    Color bg, txt;
    String text;
    Color getBg(MaterialColor c) => widget.isDarkMode ? c.shade900 : c.shade100;
    Color getTxt(MaterialColor c) =>
        widget.isDarkMode ? c.shade100 : c.shade800;

    switch (widget.booking.status) {
      case BookingStatus.completed:
        bg = getBg(Colors.green);
        txt = getTxt(Colors.green);
        text = "Completed";
        break;
      case BookingStatus.cancelled:
        bg = getBg(Colors.red);
        txt = getTxt(Colors.red);
        text = "Cancelled";
        break;
      case BookingStatus.rejected:
        bg = getBg(Colors.red);
        txt = getTxt(Colors.red);
        text = "Rejected";
        break;
      default:
        bg = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
        txt = widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
        text = "Closed";
    }

    return Container(
      width: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _ReviewDialog extends StatelessWidget {
  final int bookingId;
  final bool isDarkMode;
  final ReviewResponse existingReview;

  const _ReviewDialog({
    required this.bookingId,
    required this.isDarkMode,
    required this.existingReview,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final txtColor = isDarkMode ? Colors.white : Colors.black87;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Center(
        child: Text(
          'Customer Review',
          style: TextStyle(fontWeight: FontWeight.bold, color: txtColor),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(
                  i < existingReview.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                existingReview.comment.isEmpty
                    ? "No comment provided."
                    : existingReview.comment,
                style: TextStyle(color: txtColor),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: tabController,
    builder: (context, _) => Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDarkMode ? _Consts.subtleDark : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tab('Active', 0, Colors.green),
          _tab('Pending', 1, Colors.orange),
          _tab('Closed', 2, _Consts.primaryBlue),
        ],
      ),
    ),
  );

  Widget _tab(String text, int i, Color color) {
    final sel = tabController.index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => tabController.animateTo(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel
                ? (isDarkMode ? const Color(0xFF424242) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: sel
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
                  fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                  color: sel
                      ? (isDarkMode ? Colors.white : Colors.black87)
                      : (isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                ),
              ),
              if (counts[i] > 0)
                Positioned(
                  top: -8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${counts[i]}',
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

class _DetailDialog extends StatelessWidget {
  final BookingDetail details;
  final bool isDarkMode;
  const _DetailDialog({required this.details, required this.isDarkMode});

  bool _isVideo(String url) => [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
  ].any((ext) => url.toLowerCase().endsWith(ext));

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeString = DateFormat('h:mm a').format(details.scheduledDate);
    final cleanEst = details.estimatedTime
        .replaceAll(RegExp(r'Est\. Time:?'), '')
        .trim();

    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      title: Center(
        child: Text(
          'Details',
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
            _row('Service(s)', details.serviceName),
            _row('Customer', details.otherSideName),
            if (details.otherSidePhone.isNotEmpty)
              _row('Phone', details.otherSidePhone),
            _row('Area', details.areaName),
            _row('Address', details.address),
            _row('Date', dateFormat.format(details.scheduledDate)),
            _row('Time', timeString),
            if (cleanEst.isNotEmpty) _row('Est. Time', cleanEst),
            _row('Price', details.formattedPrice),
            if (details.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _row('Notes', details.notes!),
            ],
            if (details.attachmentUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Attachments:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.attachmentUrls
                    .map(
                      (url) => _buildAttachment(
                        context,
                        AppConfig.getFullImageUrl(url),
                      ),
                    )
                    .toList(),
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

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
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

  Widget _buildAttachment(BuildContext context, String fullUrl) {
    final isVid = _isVideo(fullUrl);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isVid
                ? _FullScreenNetworkVideoPlayer(videoUrl: fullUrl)
                : _FullScreenNetworkImageViewer(imageUrl: fullUrl),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isVid ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isVid
              ? const Center(child: Icon(Icons.play_arrow, color: Colors.white))
              : Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
        ),
      ),
    );
  }
}

class _BookingMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool isDarkMode;

  const _BookingMapScreen({
    required this.latitude,
    required this.longitude,
    required this.isDarkMode,
  });

  @override
  State<_BookingMapScreen> createState() => _BookingMapScreenState();
}

class _BookingMapScreenState extends State<_BookingMapScreen> {
  late MapController _mapController;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(widget.latitude, widget.longitude),
              zoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: _Consts.primaryBlue,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  backgroundColor: _Consts.primaryBlue,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  backgroundColor: _Consts.primaryBlue,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenNetworkImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenNetworkImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class _FullScreenNetworkVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _FullScreenNetworkVideoPlayer({required this.videoUrl});

  @override
  State<_FullScreenNetworkVideoPlayer> createState() =>
      _FullScreenNetworkVideoPlayerState();
}

class _FullScreenNetworkVideoPlayerState
    extends State<_FullScreenNetworkVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: _controller.value.isPlaying
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 60,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
