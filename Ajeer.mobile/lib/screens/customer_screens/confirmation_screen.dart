import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import 'home_screen.dart';
import '../../services/booking_service.dart';
import '../../notifiers/language_notifier.dart';

class ConfirmationScreen extends StatefulWidget {
  final List<int> serviceIds;
  final int serviceAreaId;
  final double latitude;
  final double longitude;
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final String? userDescription;
  final List<File> pickedMediaFiles;
  final int totalTimeMinutes;
  final double totalPrice;
  final String resolvedCityArea;
  final String resolvedAddress;

  const ConfirmationScreen({
    super.key,
    required this.serviceIds,
    required this.serviceAreaId,
    required this.latitude,
    required this.longitude,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    this.userDescription,
    required this.pickedMediaFiles,
    required this.totalTimeMinutes,
    required this.totalPrice,
    required this.resolvedCityArea,
    required this.resolvedAddress,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationConstants {
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlue = Color(0xFF57b2ff);
  static const Color confirmGreen = Color(0xFF4CAF50);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color subtleLighterDark = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const double logoHeight = 105.0;
  static const double overlapAdjustment = 10.0;
  static const double navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double horizontalPadding = 20.0;
  static const double iconPositionAdjustment = 18.0;
  static const double detailItemBottomPadding = 10.0;
  static const double detailItemVerticalPadding = 8.0;
  static const double detailItemHorizontalPadding = 12.0;
  static const double detailItemBorderRadius = 10.0;
  static const Color subtleDark = Color(0xFF1E1E1E);
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  String _currentMediaView = 'Photo';
  bool _isConfirmButtonPressed = false;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context, listen: false);
  }

  List<File> get _videoFiles => widget.pickedMediaFiles.where((file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov');
  }).toList();

  List<File> get _audioFiles => widget.pickedMediaFiles.where((file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.mp3') ||
        path.endsWith('.m4a') ||
        path.endsWith('.wav') ||
        path.endsWith('.aac');
  }).toList();

  List<File> get _photoFiles => widget.pickedMediaFiles.where((file) {
    final path = file.path.toLowerCase();
    bool isVideo = path.endsWith('.mp4') || path.endsWith('.mov');
    bool isAudio =
        path.endsWith('.mp3') ||
        path.endsWith('.m4a') ||
        path.endsWith('.wav') ||
        path.endsWith('.aac');
    return !isVideo && !isAudio;
  }).toList();

  @override
  void initState() {
    super.initState();
    if (_photoFiles.isNotEmpty) {
      _currentMediaView = 'Photo';
    } else if (_videoFiles.isNotEmpty) {
      _currentMediaView = 'Video';
    } else {
      _currentMediaView = 'Photo';
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

  Future<void> _onConfirmTap() async {
    if (_isLoading) return;

    setState(() {
      _isConfirmButtonPressed = true;
      _isLoading = true;
    });

    final combinedDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.selectedTime.hour,
      widget.selectedTime.minute,
    );

    final BookingResult result = await BookingService().createBooking(
      serviceIds: widget.serviceIds,
      serviceAreaId: widget.serviceAreaId,
      scheduledDate: combinedDateTime,
      address: widget.resolvedAddress,
      latitude: widget.latitude,
      longitude: widget.longitude,
      notes: widget.userDescription,
      attachments: widget.pickedMediaFiles,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isConfirmButtonPressed = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: _ConfirmationConstants.confirmGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BookingsScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openFullScreenMedia(File file, bool isVideo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => isVideo
            ? _FullScreenVideoPlayer(videoFile: file)
            : _FullScreenImageViewer(imageFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    final bool isDarkMode = themeNotifier.isDarkMode;

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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop -
        _ConfirmationConstants.logoHeight +
        _ConfirmationConstants.overlapAdjustment;
    final double bottomNavClearance =
        _ConfirmationConstants.navBarTotalHeight +
        MediaQuery.of(context).padding.bottom;

    final navItems = [
      {
        'label': languageNotifier.translate('profile'),
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
      {
        'label': languageNotifier.translate('chat'),
        'icon': Icons.chat_bubble_outline,
        'activeIcon': Icons.chat_bubble,
      },
      {
        'label': languageNotifier.translate('bookings'),
        'icon': Icons.book_outlined,
        'activeIcon': Icons.book,
        'notificationCount': 3,
      },
      {
        'label': languageNotifier.translate('home'),
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
          _buildConfirmIcon(whiteContainerTop, statusBarHeight),
          Positioned(
            top: whiteContainerTop,
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
                    padding: const EdgeInsets.only(
                      left: _ConfirmationConstants.horizontalPadding,
                      right: _ConfirmationConstants.horizontalPadding,
                      top: 20.0,
                      bottom: 10.0,
                    ),
                    child: Text(
                      languageNotifier.translate('confirmBooking'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                    ),
                  ),
                  Expanded(
                    child: _buildConfirmationDetails(
                      bottomNavClearance,
                      isDarkMode,
                      languageNotifier,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _ConfirmationNavigationHeader(
            onBackTap: () => Navigator.pop(context),
            appName: languageNotifier.translate('appName'),
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
            colors: [
              _ConfirmationConstants.lightBlue,
              _ConfirmationConstants.primaryBlue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmIcon(double containerTop, double statusBarHeight) {
    final double headerHeight = statusBarHeight + 60;
    final double availableHeight = containerTop - headerHeight;
    final double iconTopPosition =
        headerHeight +
        (availableHeight / 2) -
        _ConfirmationConstants.logoHeight / 2 -
        _ConfirmationConstants.iconPositionAdjustment;

    final isArabic = _languageNotifier.isArabic;

    Color primaryColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants.secondaryBlue;
    Color secondaryColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants._secondaryLightBlue;
    Color glowColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants._secondaryLightBlue;

    return Positioned(
      top: iconTopPosition,
      right: isArabic ? null : 25.0,
      left: isArabic ? 25.0 : null,
      child: GestureDetector(
        onTap: _onConfirmTap,
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                const BoxShadow(
                  blurRadius: 5.0,
                  color: Colors.black38,
                  offset: Offset(2.0, 2.0),
                ),
                BoxShadow(
                  color: glowColor.withOpacity(0.7),
                  blurRadius: _isConfirmButtonPressed ? 70.0 : 40.0,
                  spreadRadius: _isConfirmButtonPressed ? 20.0 : 10.0,
                  offset: const Offset(0, 0),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
                    Icons.check,
                    size: 60.0,
                    color: _isConfirmButtonPressed
                        ? Colors.white
                        : _ConfirmationConstants.primaryBlue,
                  ),
          ),
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
          height: _ConfirmationConstants.logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildConfirmationDetails(
    double bottomNavClearance,
    bool isDarkMode,
    LanguageNotifier languageNotifier,
  ) {
    IconData serviceIcon;
    switch (widget.serviceName) {
      case 'Cleaning':
        serviceIcon = Icons.cleaning_services;
        break;
      case 'Plumbing':
        serviceIcon = Icons.plumbing;
        break;
      case 'Electrical':
        serviceIcon = Icons.electrical_services;
        break;
      default:
        serviceIcon = Icons.home_repair_service;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _ConfirmationConstants.horizontalPadding,
        10.0,
        _ConfirmationConstants.horizontalPadding,
        bottomNavClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriceAndDurationDisplay(
            totalPrice: widget.totalPrice,
            totalTimeMinutes: widget.totalTimeMinutes,
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
          ),
          const SizedBox(height: 15.0),
          _DetailItem(
            icon: serviceIcon,
            title: languageNotifier.translate(widget.serviceName),
            subtitle: widget.unitType,
            isDarkMode: isDarkMode,
          ),
          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: languageNotifier.getFormattedDate(widget.selectedDate),
            subtitle: widget.selectionMode == 'Custom'
                ? languageNotifier.convertNumbers(
                    widget.selectedTime.format(context),
                  )
                : languageNotifier.translate('instantBooking'),
            isDarkMode: isDarkMode,
          ),
          _DetailItem(
            icon: Icons.location_on_outlined,
            title: widget.resolvedCityArea,
            subtitle: widget.resolvedAddress,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 15.0),
          _MediaSummary(
            photoCount: _photoFiles.length,
            videoCount: _videoFiles.length,
            audioCount: 0,
            currentView: _currentMediaView,
            onViewChange: (view) => setState(() => _currentMediaView = view),
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
          ),
          const SizedBox(height: 10.0),
          _buildMediaContent(isDarkMode, languageNotifier),
          const SizedBox(height: 20.0),
          if (widget.userDescription != null &&
              widget.userDescription!.trim().isNotEmpty)
            _DescriptionDisplay(
              description: widget.userDescription!,
              isDarkMode: isDarkMode,
              languageNotifier: languageNotifier,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(
    bool isDarkMode,
    LanguageNotifier languageNotifier,
  ) {
    List<File> currentFiles = [];
    IconData placeholderIcon = Icons.clear;
    String placeholderText = '';

    if (_currentMediaView == 'Photo') {
      currentFiles = _photoFiles;
      placeholderIcon = Icons.image_not_supported_outlined;
      placeholderText = languageNotifier.translate('noImages');
    } else if (_currentMediaView == 'Video') {
      currentFiles = _videoFiles;
      placeholderIcon = Icons.videocam_off_outlined;
      placeholderText = languageNotifier.translate('noVideos');
    } else if (_currentMediaView == 'Audio') {
      currentFiles = [];
      placeholderIcon = Icons.mic_off_outlined;
      placeholderText = languageNotifier.translate('noAudio');
    }

    final Color containerColor = isDarkMode
        ? _ConfirmationConstants.subtleLighterDark
        : Colors.white;
    final Color placeholderBg = isDarkMode
        ? _ConfirmationConstants.subtleDark
        : Colors.grey[100]!;
    final Color borderColor = isDarkMode
        ? _ConfirmationConstants.darkBorder
        : Colors.grey[300]!;
    final Color placeholderTextColor = isDarkMode
        ? Colors.grey.shade500
        : Colors.grey.shade600;

    if (currentFiles.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: placeholderBg,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(placeholderIcon, size: 30, color: placeholderTextColor),
              const SizedBox(height: 5),
              Text(
                placeholderText,
                style: TextStyle(color: placeholderTextColor),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: borderColor, width: 2.0),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentFiles.length,
        itemBuilder: (context, index) {
          final file = currentFiles[index];
          final isImage = _currentMediaView == 'Photo';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _openFullScreenMedia(file, !isImage),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: 100,
                  color: isImage
                      ? Colors.grey.shade200
                      : _ConfirmationConstants.subtleDark,
                  child: isImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PriceAndDurationDisplay extends StatelessWidget {
  final double totalPrice;
  final int totalTimeMinutes;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _PriceAndDurationDisplay({
    required this.totalPrice,
    required this.totalTimeMinutes,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  String _formatDuration(int totalMinutes) {
    String timeString = '';

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    final hrStr = languageNotifier.translate('hr');
    final hrsStr = languageNotifier.translate('hrs');
    final minStr = languageNotifier.translate('min');
    final minsStr = languageNotifier.translate('mins');

    if (hours > 0) {
      timeString += '$hours ${hours > 1 ? hrsStr : hrStr}';
    }

    if (hours > 0 && minutes > 0) timeString += ' ';

    if (minutes > 0 || hours == 0) {
      timeString += '$minutes ${minutes > 1 ? minsStr : minStr}';
    }

    return languageNotifier.convertNumbers(timeString);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    const double labelFontSize = 13.0;
    const double valueFontSize = 18.0;
    const Color labelColor = Color.fromARGB(255, 70, 162, 255);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2C2C2C)
            : const Color(0xFF1976D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF3A3A3A)
              : const Color(0xFF1976D2).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on_outlined,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          languageNotifier.translate('estimatedCost'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: labelFontSize,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            languageNotifier.isArabic
                                ? '${languageNotifier.convertNumbers(totalPrice.toStringAsFixed(2))} ${languageNotifier.translate('jod')}' // Arabic: 20.00 JOD
                                : '${languageNotifier.translate('jod')} ${totalPrice.toStringAsFixed(2)}', // English: JOD 20.00
                            style: TextStyle(
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              color: const Color(0xFF1976D2).withOpacity(0.3),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          languageNotifier.translate('estDuration'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: labelFontSize,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDuration(totalTimeMinutes),
                            style: TextStyle(
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final String appName;

  const _ConfirmationNavigationHeader({
    required this.onBackTap,
    required this.appName,
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
          Text(
            appName,
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
          const SizedBox(width: 48.0),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDarkMode;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color containerColor = isDarkMode
        ? _ConfirmationConstants.subtleLighterDark
        : Colors.white;
    final Color borderColor = isDarkMode
        ? _ConfirmationConstants.darkBorder
        : Colors.grey[300]!;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: _ConfirmationConstants.detailItemBottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Correct padding using directional EdgeInsets
            padding: const EdgeInsetsDirectional.only(top: 8.0, end: 15.0),
            child: Icon(
              icon,
              color: _ConfirmationConstants.primaryBlue,
              size: 30,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _ConfirmationConstants.detailItemHorizontalPadding,
                vertical: _ConfirmationConstants.detailItemVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(
                  _ConfirmationConstants.detailItemBorderRadius,
                ),
                border: Border.all(color: borderColor, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... _MediaSummary, _BouncingMediaTab, _DescriptionDisplay, _FullScreenImageViewer, _FullScreenVideoPlayer
// are the same as provided previously in the truncated response.
// Just ensure they are all present in the file.
// I am including them here for completeness.

class _MediaSummary extends StatelessWidget {
  final int photoCount;
  final int videoCount;
  final int audioCount;
  final String currentView;
  final ValueChanged<String> onViewChange;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _MediaSummary({
    required this.photoCount,
    required this.videoCount,
    required this.audioCount,
    required this.currentView,
    required this.onViewChange,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageNotifier.translate('uploadedMedia'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BouncingMediaTab(
              label: languageNotifier.translate('photo'),
              type: 'Photo',
              icon: Icons.image_outlined,
              count: photoCount,
              isSelected: currentView == 'Photo',
              isDarkMode: isDarkMode,
              onTap: () => onViewChange('Photo'),
            ),
            _BouncingMediaTab(
              label: languageNotifier.translate('video'),
              type: 'Video',
              icon: Icons.videocam_outlined,
              count: videoCount,
              isSelected: currentView == 'Video',
              isDarkMode: isDarkMode,
              onTap: () => onViewChange('Video'),
            ),
            _BouncingMediaTab(
              label: languageNotifier.translate('audio'),
              type: 'Audio',
              icon: Icons.mic_none,
              count: audioCount,
              isSelected: currentView == 'Audio',
              isDarkMode: isDarkMode,
              onTap: () => onViewChange('Audio'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BouncingMediaTab extends StatefulWidget {
  final String label;
  final String type;
  final IconData icon;
  final int count;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _BouncingMediaTab({
    required this.label,
    required this.type,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_BouncingMediaTab> createState() => _BouncingMediaTabState();
}

class _BouncingMediaTabState extends State<_BouncingMediaTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
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
    final Color containerColor = widget.isSelected
        ? _ConfirmationConstants.primaryBlue
        : widget.isDarkMode
        ? _ConfirmationConstants.subtleLighterDark
        : Colors.white;
    final Color textColor = widget.isSelected
        ? Colors.white
        : widget.isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final Color borderColor = widget.isSelected
        ? _ConfirmationConstants.primaryBlue
        : widget.isDarkMode
        ? _ConfirmationConstants.darkBorder
        : Colors.grey[300]!;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width / 4.2,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? Colors.white
                    : _ConfirmationConstants.primaryBlue,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionDisplay extends StatelessWidget {
  final String description;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _DescriptionDisplay({
    required this.description,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
    final Color containerColor = isDarkMode
        ? _ConfirmationConstants.subtleLighterDark
        : Colors.white;
    final Color borderColor = isDarkMode
        ? _ConfirmationConstants.darkBorder
        : Colors.grey[300]!;
    final Color descriptionColor = isDarkMode
        ? Colors.grey.shade300
        : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageNotifier.translate('customerNote'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: borderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: descriptionColor,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final File imageFile;

  const _FullScreenImageViewer({required this.imageFile});

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
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final File videoFile;

  const _FullScreenVideoPlayer({required this.videoFile});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
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
            : const CircularProgressIndicator(),
      ),
    );
  }
}
