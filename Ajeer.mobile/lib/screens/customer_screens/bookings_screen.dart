import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../config/app_config.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import '../../models/booking_models.dart';
import '../../models/review_models.dart';
import '../../services/booking_service.dart';
import '../../services/chat_service.dart';
import '../../services/review_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _Consts {
  static const primaryBlue = Color(0xFF1976D2);
  static const lightBlue = Color(0xFF8CCBFF);
  static const primaryRed = Color(0xFFD32F2F);
  static const subtleDark = Color(0xFF2C2C2C);
  static const darkBorder = Color(0xFF3A3A3A);
  static const logoHeight = 105.0;
  static const borderRadius = 50.0;
  static const navBarHeight = 86.0;
}

class _BookingsScreenState extends State<BookingsScreen>
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
    final bookings = await _bookingService.getBookings();
    if (mounted)
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
  }

  Future<void> _handleCancel(int id) async {
    _showLoading();
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
    _showLoading();
    final details = await _bookingService.getBookingDetails(id);
    if (!mounted) return;
    Navigator.pop(context);
    if (details != null) {
      showDialog(
        context: context,
        builder: (_) => _DetailDialog(details: details, isDarkMode: isDarkMode),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load booking details')),
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
          _buildGradient(topHeight),
          _buildHeader(isDarkMode),
          _buildContent(topHeight, isDarkMode),
          _buildLogo(topHeight, isDarkMode),
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

  Widget _buildGradient(double height) => Align(
    alignment: Alignment.topCenter,
    child: Container(
      height: height + 50,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_Consts.lightBlue, _Consts.primaryBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
  );

  Widget _buildHeader(bool isDark) => Positioned(
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
          shadows: isDark
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

  Widget _buildLogo(double top, bool isDark) => Positioned(
    top: top - _Consts.logoHeight + 10,
    left: 0,
    right: 0,
    child: Center(
      child: Image.asset(
        isDark ? 'assets/image/home_dark.png' : 'assets/image/home.png',
        width: 140,
        height: _Consts.logoHeight,
        fit: BoxFit.contain,
      ),
    ),
  );

  Widget _buildContent(double top, bool isDark) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CustomTabBar(
                tabController: _tabController,
                counts: [_active.length, _pending.length, _closed.length],
                isDarkMode: isDark,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_active, _BookingListType.active, isDark),
                        _buildList(_pending, _BookingListType.pending, isDark),
                        _buildList(_closed, _BookingListType.closed, isDark),
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
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No bookings here.',
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
        onCancel: () => _handleCancel(items[i].id),
        onInfoTap: () => _showBookingDetails(items[i].id, isDark),
      ),
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

  @override
  Widget build(BuildContext context) {
    final letter = booking.otherSideName.isNotEmpty
        ? booking.otherSideName[0].toUpperCase()
        : '?';
    final avatarColor =
        Colors.primaries[letter.hashCode % Colors.primaries.length];
    final fullImageUrl = AppConfig.getFullImageUrl(booking.otherSideImageUrl);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? _Consts.subtleDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isDarkMode ? _Consts.darkBorder : Colors.grey.shade300,
          width: 2.0,
        ),
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
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final icons = <Widget>[];

    if (booking.status == BookingStatus.completed &&
        listType == _BookingListType.closed) {
      icons.add(
        _iconBtn(
          Icons.star_rate_rounded,
          Colors.amber,
          28,
          () => _showReviewDialog(context),
        ),
      );
    }

    icons.add(_iconBtn(Icons.info_outline, _Consts.primaryBlue, 24, onInfoTap));

    if (listType == _BookingListType.active) {
      icons.add(
        _iconBtn(
          Icons.chat_bubble_outline,
          isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          22,
          () => _showMessageDialog(context),
        ),
      );
    }

    if (listType != _BookingListType.closed) {
      icons.add(const SizedBox(width: 6));
      icons.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _Consts.primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _showCancelDialog(context),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      icons.add(_statusBadge());
    }

    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }

  Widget _iconBtn(IconData icon, Color color, double size, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onTap,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.only(right: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _statusBadge() {
    Color bg, txt;
    String text;
    Color getBg(MaterialColor c) => isDarkMode ? c.shade900 : c.shade100;
    Color getTxt(MaterialColor c) => isDarkMode ? c.shade100 : c.shade800;

    switch (booking.status) {
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
        bg = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
        txt = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
        text = "Closed";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) => _genericDialog(
    context,
    'Cancel Booking',
    'Are you sure you want to cancel this booking?',
    _Consts.primaryRed,
    'Confirm',
    onCancel,
  );

  void _showMessageDialog(BuildContext context) => _genericDialog(
    context,
    'Message Provider',
    'Would you like to message ${booking.otherSideName}?',
    _Consts.primaryBlue,
    'Message',
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            bookingId: booking.id,
            otherSideName: booking.otherSideName,
            chatService: ChatService(),
            isDarkMode: isDarkMode,
          ),
        ),
      );
    },
  );

  void _genericDialog(
    BuildContext context,
    String title,
    String content,
    Color mainColor,
    String btnText,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? _Consts.subtleDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
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
                    backgroundColor: mainColor,
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

  void _showReviewDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) =>
        _ReviewDialog(bookingId: booking.id, isDarkMode: isDarkMode),
  );
}

class _ReviewDialog extends StatefulWidget {
  final int bookingId;
  final bool isDarkMode;
  const _ReviewDialog({required this.bookingId, required this.isDarkMode});
  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _commentController = TextEditingController();
  final _reviewService = ReviewService();
  int _rating = 5;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final result = await _reviewService.submitReview(
      CreateReviewRequest(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? _Consts.subtleDark : Colors.white;
    final txtColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Center(
        child: Text(
          'Review',
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
                (i) => IconButton(
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              style: TextStyle(color: txtColor),
              decoration: InputDecoration(
                hintText: 'Leave a comment...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.grey : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
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
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
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
            _row('Provider', details.otherSideName),
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
      onTap: () => showDialog(
        context: context,
        builder: (_) => isVid
            ? _VideoPlayerDialog(videoUrl: fullUrl)
            : _imageDialog(context, fullUrl),
      ),
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

  Widget _imageDialog(BuildContext context, String url) => Dialog(
    backgroundColor: Colors.transparent,
    child: Stack(
      alignment: Alignment.center,
      children: [
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    ),
  );
}

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerDialog({required this.videoUrl});
  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _c;
  bool _init = false, _err = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() => _init = true);
              _c.play();
            }
          })
          .catchError((_) {
            if (mounted) setState(() => _err = true);
          });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(10),
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (_init)
          AspectRatio(
            aspectRatio: _c.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_c),
                _Controls(c: _c),
              ],
            ),
          )
        else if (_err)
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
            ),
            child: const Center(
              child: Text(
                'Video failed to load',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        else
          const CircularProgressIndicator(color: Colors.white),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Controls extends StatelessWidget {
  final VideoPlayerController c;
  const _Controls({required this.c});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => c.value.isPlaying ? c.pause() : c.play(),
    child: Stack(
      children: [
        Container(color: Colors.transparent),
        if (!c.value.isPlaying)
          const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 50.0),
              ),
            ),
          ),
      ],
    ),
  );
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
