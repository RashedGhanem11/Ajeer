import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_config.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import '../../models/booking_models.dart';
import '../../models/review_models.dart';
import '../../services/booking_service.dart';
import '../../services/chat_service.dart';
import '../../services/review_service.dart';
import '../../notifiers/language_notifier.dart';

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

  static const activeGreen = Color(0xFF2abf52);
  static const pendingYellow = Color(0xFFffe042);
  static const closedIndigo = Color(0xFF7c54ff);
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

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 2;
  late TabController _tabController;
  final _bookingService = BookingService();
  bool _isLoading = true;
  List<BookingListItem> _allBookings = [];
  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCurrentBottomColor() {
    switch (_tabController.index) {
      case 0:
        return _Consts.activeGreen;
      case 1:
        return _Consts.pendingYellow;
      case 2:
        return _Consts.closedIndigo;
      default:
        return _Consts.primaryBlue;
    }
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
    _showLoading();
    final success = await _bookingService.cancelBooking(id);
    if (!mounted) return;
    Navigator.pop(context);
    if (success) {
      _fetchBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageNotifier.translate('bookingCancelled')),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_languageNotifier.translate('cancelFailed'))),
      );
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
        items: [
          {
            'label': _languageNotifier.translate('profile'),
            'icon': Icons.person_outline,
            'activeIcon': Icons.person,
          },
          {
            'label': _languageNotifier.translate('chat'),
            'icon': Icons.chat_bubble_outline,
            'activeIcon': Icons.chat_bubble,
          },
          {
            'label': _languageNotifier.translate('bookings'),
            'icon': Icons.book_outlined,
            'activeIcon': Icons.book,
            'notificationCount': 3,
          },
          {
            'label': _languageNotifier.translate('home'),
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
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: height + 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_Consts.lightBlue, _getCurrentBottomColor()],
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
        _languageNotifier.translate('appName'),
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
          boxShadow: const [
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
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _languageNotifier.translate('bookings'),
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
          _languageNotifier.translate('noBookings'),
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
        onLocationTap: () => _showBookingLocation(items[i].id, isDark),
        onRefresh: _fetchBookings,
      ),
    );
  }
}

enum _BookingListType { active, pending, closed }

class _BookingCard extends StatefulWidget {
  final BookingListItem booking;
  final _BookingListType listType;
  final bool isDarkMode;
  final VoidCallback onCancel;
  final VoidCallback onInfoTap;
  final VoidCallback onLocationTap;
  final VoidCallback onRefresh;

  const _BookingCard({
    required this.booking,
    required this.listType,
    required this.isDarkMode,
    required this.onCancel,
    required this.onInfoTap,
    required this.onLocationTap,
    required this.onRefresh,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _jumpController;
  late Animation<Offset> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _jumpAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.2)).animate(
          CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut),
        );
    if (widget.listType == _BookingListType.closed &&
        widget.booking.hasReview) {
      _jumpController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  Future<void> _handleReviewTap(BuildContext context) async {
    if (!widget.booking.hasReview) {
      final result = await showDialog(
        context: context,
        builder: (_) => _ReviewDialog(
          bookingId: widget.booking.id,
          isDarkMode: widget.isDarkMode,
        ),
      );
      if (result == true) widget.onRefresh();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final review = await ReviewService().getReview(widget.booking.id);
      if (mounted) Navigator.pop(context);
      if (mounted && review != null) {
        showDialog(
          context: context,
          builder: (_) => _ReviewDialog(
            bookingId: widget.booking.id,
            isDarkMode: widget.isDarkMode,
            existingReview: review,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = Provider.of<LanguageNotifier>(context);
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
                    languageNotifier.translateServices(
                      widget.booking.serviceName,
                    ),
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
    final icons = <Widget>[];
    if (widget.listType == _BookingListType.active) {
      icons.add(
        _iconBtn(
          Icons.chat_bubble_outline,
          widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          22,
          () => _showMessageDialog(context),
        ),
      );
    } else if (widget.booking.status == BookingStatus.completed &&
        widget.listType == _BookingListType.closed) {
      Widget star = _iconBtn(
        widget.booking.hasReview
            ? Icons.star_rounded
            : Icons.star_border_rounded,
        Colors.amber,
        24,
        () => _handleReviewTap(context),
      );
      if (widget.booking.hasReview)
        star = SlideTransition(position: _jumpAnimation, child: star);
      icons.add(star);
    }

    icons.addAll([
      _iconBtn(
        Icons.location_on_outlined,
        _Consts.primaryBlue,
        24,
        widget.onLocationTap,
      ),
      _iconBtn(Icons.info_outline, _Consts.primaryBlue, 24, widget.onInfoTap),
    ]);

    Widget action = widget.listType != _BookingListType.closed
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _Consts.primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(80, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _showCancelDialog(context),
            child: Text(
              Provider.of<LanguageNotifier>(context).translate('cancel'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        : _statusBadge();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: icons),
        const SizedBox(height: 2),
        action,
      ],
    );
  }

  Widget _iconBtn(
    IconData icon,
    Color color,
    double size,
    VoidCallback onTap,
  ) => IconButton(
    icon: Icon(icon, color: color, size: size),
    onPressed: onTap,
    constraints: const BoxConstraints(),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    visualDensity: VisualDensity.compact,
  );

  Widget _statusBadge() {
    final ln = Provider.of<LanguageNotifier>(context);
    Color bg, txt;
    String text;
    Color getBg(MaterialColor c) => widget.isDarkMode ? c.shade900 : c.shade100;
    Color getTxt(MaterialColor c) =>
        widget.isDarkMode ? c.shade100 : c.shade800;

    switch (widget.booking.status) {
      case BookingStatus.completed:
        bg = getBg(Colors.green);
        txt = getTxt(Colors.green);
        text = ln.translate('completed');
        break;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        bg = getBg(Colors.red);
        txt = getTxt(Colors.red);
        text = ln.translate(
          widget.booking.status == BookingStatus.cancelled
              ? 'cancelled'
              : 'rejected',
        );
        break;
      default:
        bg = widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
        txt = widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
        text = ln.translate('closed');
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

  void _showCancelDialog(BuildContext context) {
    final ln = Provider.of<LanguageNotifier>(context, listen: false);
    _genericDialog(
      context,
      ln.translate('cancelBooking'),
      ln.translate('cancelBookingMsg'),
      _Consts.primaryRed,
      ln.translate('confirm'),
      widget.onCancel,
    );
  }

  void _showMessageDialog(BuildContext context) {
    final ln = Provider.of<LanguageNotifier>(context, listen: false);
    _genericDialog(
      context,
      ln.translate('messageProvider'),
      '${ln.translate('messageProviderMsg')} ${widget.booking.otherSideName}?',
      _Consts.primaryBlue,
      ln.translate('message'),
      () {
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
    );
  }

  void _genericDialog(
    BuildContext context,
    String title,
    String content,
    Color main,
    String btn,
    VoidCallback onConfirm,
  ) {
    final ln = Provider.of<LanguageNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: AlertDialog(
          backgroundColor: widget.isDarkMode
              ? _Consts.subtleDark
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: main, fontWeight: FontWeight.bold),
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
                      ln.translate('back'),
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
                      backgroundColor: main,
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
                      btn,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final int bookingId;
  final bool isDarkMode;
  final ReviewResponse? existingReview;
  const _ReviewDialog({
    required this.bookingId,
    required this.isDarkMode,
    this.existingReview,
  });
  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late TextEditingController _commentController;
  final _reviewService = ReviewService();
  int _rating = 5;
  bool _isSubmitting = false;
  bool get _isReadOnly => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final res = await _reviewService.submitReview(
      CreateReviewRequest(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.message),
        backgroundColor: res.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ln = Provider.of<LanguageNotifier>(context);
    final bgColor = widget.isDarkMode ? _Consts.subtleDark : Colors.white;
    final txtColor = widget.isDarkMode ? Colors.white : Colors.black87;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Center(
          child: Text(
            _isReadOnly ? ln.translate('yourReview') : ln.translate('review'),
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
                    onPressed: _isReadOnly
                        ? null
                        : () => setState(() => _rating = i + 1),
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
                enabled: !_isReadOnly,
                maxLines: 3,
                maxLength: _isReadOnly ? null : 500,
                style: TextStyle(color: txtColor),
                decoration: InputDecoration(
                  hintText: ln.translate('leaveComment'),
                  hintStyle: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey
                        : Colors.grey.shade600,
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
          if (_isReadOnly)
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  ln.translate('close'),
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      ln.translate('cancel'),
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
                        : Text(
                            ln.translate('submit'),
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

class _DetailDialog extends StatelessWidget {
  final BookingDetail details;
  final bool isDarkMode;
  const _DetailDialog({required this.details, required this.isDarkMode});

  Widget _row(BuildContext context, String label, String val, bool dark) {
    final ln = Provider.of<LanguageNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: dark ? Colors.white70 : Colors.black87,
            fontFamily: ln.currentFontFamily,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: val),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ln = Provider.of<LanguageNotifier>(context);
    final date = ln.getFormattedDate(details.scheduledDate);
    String time = DateFormat('h:mm a').format(details.scheduledDate);
    if (ln.isArabic)
      time = time
          .replaceAll('AM', ln.translate('am'))
          .replaceAll('PM', ln.translate('pm'));
    String cleanEst = details.estimatedTime
        .replaceAll(RegExp(r'Est\. Time:?'), '')
        .trim();
    String price = details.formattedPrice;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Center(
          child: Text(
            ln.translate('details'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: ln.currentFontFamily,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(
                context,
                ln.translate('serviceLabel'),
                ln.translateServices(details.serviceName),
                isDarkMode,
              ),
              _row(
                context,
                ln.translate('providerLabel'),
                details.otherSideName,
                isDarkMode,
              ),
              if (details.otherSidePhone.isNotEmpty)
                _row(
                  context,
                  ln.translate('phoneLabel'),
                  ln.convertNumbers(details.otherSidePhone),
                  isDarkMode,
                ),
              _row(
                context,
                ln.translate('areaLabel'),
                ln.translateCityArea(details.areaName),
                isDarkMode,
              ),
              _row(
                context,
                ln.translate('addressLabel'),
                ln.translateAddress(details.address),
                isDarkMode,
              ),
              _row(context, ln.translate('dateLabel'), date, isDarkMode),
              _row(
                context,
                ln.translate('timeLabel'),
                ln.convertNumbers(time),
                isDarkMode,
              ),
              if (cleanEst.isNotEmpty)
                _row(
                  context,
                  ln.translate('estTime'),
                  ln.convertNumbers(cleanEst),
                  isDarkMode,
                ),
              _row(
                context,
                ln.translate('priceLabel'),
                ln.convertNumbers(price),
                isDarkMode,
              ),
              if (details.notes?.isNotEmpty == true)
                _row(
                  context,
                  ln.translate('notesLabel'),
                  details.notes!,
                  isDarkMode,
                ),
              if (details.attachmentUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${ln.translate('attachmentsLabel')}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: ln.currentFontFamily,
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
              ln.translate('close'),
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontFamily: ln.currentFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, String url) {
    final isVid = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
    ].any((e) => url.toLowerCase().endsWith(e));
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => isVid
              ? _FullScreenNetworkVideoPlayer(videoUrl: url)
              : _FullScreenNetworkImageViewer(imageUrl: url),
        ),
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
              ? const Icon(Icons.play_arrow, color: Colors.white)
              : Image.network(
                  url,
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
    final ln = Provider.of<LanguageNotifier>(context);
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode ? _Consts.subtleDark : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _tab(ln, ln.translate('active'), 0, Colors.green),
            _tab(ln, ln.translate('pending'), 1, Colors.orange),
            _tab(ln, ln.translate('closed'), 2, _Consts.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _tab(LanguageNotifier ln, String text, int i, Color color) {
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
                      ln.convertNumbers('${counts[i]}'),
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

class _BookingMapScreen extends StatefulWidget {
  final double latitude, longitude;
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
  double _zoom = 15.0;
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
              zoom: _zoom,
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
                  heroTag: 'in',
                  mini: true,
                  backgroundColor: _Consts.primaryBlue,
                  onPressed: () => setState(() {
                    _zoom++;
                    _mapController.move(_mapController.center, _zoom);
                  }),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'out',
                  mini: true,
                  backgroundColor: _Consts.primaryBlue,
                  onPressed: () => setState(() {
                    _zoom--;
                    _mapController.move(_mapController.center, _zoom);
                  }),
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
  bool _init = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then(
        (_) => setState(() {
          _init = true;
          _controller.play();
        }),
      );
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
        child: _init
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () => setState(
                        () => _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play(),
                      ),
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
