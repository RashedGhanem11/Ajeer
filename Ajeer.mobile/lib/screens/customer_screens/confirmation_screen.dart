import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 💡 FIX 1: Import Provider package
import '../../themes/theme_notifier.dart'; // 💡 FIX 2: Import ThemeNotifier definition
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import '../../models/booking.dart';
// Removed: import '../../main.dart';

class ConfirmationScreen extends StatefulWidget {
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

  static const Color subtleDark = Color(0xFF1E1E1E);
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
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  int _selectedIndex = 3;
  String _currentMediaView = 'Photo';
  bool _isConfirmButtonPressed = false;

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

  List<File> get _photoFiles => widget.pickedMediaFiles
      .where(
        (file) =>
            !file.path.toLowerCase().endsWith('.mp4') &&
            !file.path.toLowerCase().endsWith('.m4a'),
      )
      .toList();

  List<File> get _videoFiles => widget.pickedMediaFiles
      .where((file) => file.path.toLowerCase().endsWith('.mp4'))
      .toList();

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
  }

  void _onNavItemTapped(int index) {
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

  void _onConfirmTap() {
    setState(() {
      _isConfirmButtonPressed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking for ${widget.serviceName} confirmed! Estimated cost: JOD ${widget.totalPrice.toStringAsFixed(2)}',
        ),
        backgroundColor: _ConfirmationConstants.confirmGreen,
      ),
    );
    final booking = Booking(
      provider: 'Khalid S.',
      phone: '0796753640',
      location: 'Amman - Khalda',
      serviceName: widget.serviceName,
      unitType: widget.unitType,
      selectedDate: widget.selectedDate,
      selectedTime: widget.selectedTime,
      selectionMode: widget.selectionMode,
      userDescription: widget.userDescription,
      uploadedFiles: widget.pickedMediaFiles,
      totalTimeMinutes: widget.totalTimeMinutes,
      totalPrice: widget.totalPrice,
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingsScreen(
            newBooking: booking,
            resolvedCityArea: widget.resolvedCityArea,
            resolvedAddress: widget.resolvedAddress,
          ),
        ),
      );
    });
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

    Color primaryColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants.secondaryBlue;
    Color secondaryColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants.lightBlue;
    Color glowColor = _isConfirmButtonPressed
        ? _ConfirmationConstants.confirmGreen
        : _ConfirmationConstants.lightBlue;

    return Positioned(
      top: iconTopPosition,
      right: 25.0,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isConfirmButtonPressed = true),
        onTapUp: (_) => setState(() => _isConfirmButtonPressed = false),
        onTapCancel: () => setState(() => _isConfirmButtonPressed = false),
        onTap: _onConfirmTap,
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
              const BoxShadow(
                blurRadius: 5.0,
                color: Colors.black38,
                offset: Offset(2.0, 2.0),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.check, size: 60.0, color: Colors.white),
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

  Widget _buildConfirmationDetails(double bottomNavClearance, bool isDarkMode) {
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
          ),
          const SizedBox(height: 15.0),
          _DetailItem(
            icon: serviceIcon,
            title: widget.serviceName,
            subtitle: widget.unitType,
            isDarkMode: isDarkMode,
          ),
          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: DateFormat.yMMMMd().format(widget.selectedDate),
            subtitle: widget.selectionMode == 'Custom'
                ? widget.selectedTime.format(context)
                : 'Instant Booking',
            isDarkMode: isDarkMode,
          ),
          _DetailItem(
            icon: Icons.location_on_outlined,
            title: widget.resolvedCityArea,
            subtitle: widget.resolvedAddress,
            isDarkMode: isDarkMode,
          ),
          _DetailItem(
            icon: Icons.person_outline,
            title: 'Khalid. S',
            subtitle: '0796753640',
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
          ),
          const SizedBox(height: 10.0),
          _buildMediaContent(isDarkMode),
          const SizedBox(height: 20.0),
          if (widget.userDescription != null &&
              widget.userDescription!.trim().isNotEmpty)
            _DescriptionDisplay(
              description: widget.userDescription!,
              isDarkMode: isDarkMode,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(bool isDarkMode) {
    List<File> currentFiles = [];
    IconData placeholderIcon = Icons.clear;
    String placeholderText = '';

    if (_currentMediaView == 'Photo') {
      currentFiles = _photoFiles;
      placeholderIcon = Icons.image_not_supported_outlined;
      placeholderText = 'No images uploaded.';
    } else if (_currentMediaView == 'Video') {
      currentFiles = _videoFiles;
      placeholderIcon = Icons.videocam_off_outlined;
      placeholderText = 'No videos uploaded.';
    } else if (_currentMediaView == 'Audio') {
      currentFiles = [];
      placeholderIcon = Icons.mic_off_outlined;
      placeholderText = 'No audio uploaded.';
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
          );
        },
      ),
    );
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop -
        _ConfirmationConstants.logoHeight +
        _ConfirmationConstants.overlapAdjustment;
    final double bottomNavClearance =
        _ConfirmationConstants.navBarTotalHeight +
        MediaQuery.of(context).padding.bottom;

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
                      top: 20.0,
                      bottom: 10.0,
                    ),
                    child: Text(
                      'Confirm your booking',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _ConfirmationNavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onConfirmTap: _onConfirmTap,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }
}

class _PriceAndDurationDisplay extends StatelessWidget {
  final double totalPrice;
  final int totalTimeMinutes;
  final bool isDarkMode;

  const _PriceAndDurationDisplay({
    required this.totalPrice,
    required this.totalTimeMinutes,
    required this.isDarkMode,
  });

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? _ConfirmationConstants.subtleLighterDark
            : _ConfirmationConstants.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          _ConfirmationConstants.detailItemBorderRadius,
        ),
        border: Border.all(
          color: isDarkMode
              ? _ConfirmationConstants.darkBorder
              : _ConfirmationConstants.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  color: _ConfirmationConstants.primaryBlue,
                  size: 30,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Cost',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 70, 162, 255),
                        ),
                      ),
                      Text(
                        'JOD ${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1.0,
            color: _ConfirmationConstants.primaryBlue.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: _ConfirmationConstants.primaryBlue,
                  size: 30,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Est. Duration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 70, 162, 255),
                        ),
                      ),
                      Text(
                        _formatDuration(totalTimeMinutes),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
    );
  }
}

class _ConfirmationNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onConfirmTap;

  const _ConfirmationNavigationHeader({
    required this.onBackTap,
    required this.onConfirmTap,
  });

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
            padding: const EdgeInsets.only(top: 8.0, right: 15.0),
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

class _MediaSummary extends StatelessWidget {
  final int photoCount;
  final int videoCount;
  final int audioCount;
  final String currentView;
  final ValueChanged<String> onViewChange;
  final bool isDarkMode;

  const _MediaSummary({
    required this.photoCount,
    required this.videoCount,
    required this.audioCount,
    required this.currentView,
    required this.onViewChange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Media',
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
            _buildMediaTab(
              label: 'Photo',
              type: 'Photo',
              icon: Icons.image_outlined,
              count: photoCount,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildMediaTab(
              label: 'Video',
              type: 'Video',
              icon: Icons.videocam_outlined,
              count: videoCount,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildMediaTab(
              label: 'Audio',
              type: 'Audio',
              icon: Icons.mic_none,
              count: audioCount,
              isDarkMode: isDarkMode,
              context: context,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaTab({
    required String label,
    required String type,
    required IconData icon,
    required int count,
    required bool isDarkMode,
    required BuildContext context,
  }) {
    final bool isSelected = currentView == type;
    final Color containerColor = isSelected
        ? _ConfirmationConstants.primaryBlue
        : isDarkMode
        ? _ConfirmationConstants.subtleLighterDark
        : Colors.white;
    final Color textColor = isSelected
        ? Colors.white
        : isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final Color borderColor = isSelected
        ? _ConfirmationConstants.primaryBlue
        : isDarkMode
        ? _ConfirmationConstants.darkBorder
        : Colors.grey[300]!;

    return GestureDetector(
      onTap: () => onViewChange(type),
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
              icon,
              color: isSelected
                  ? Colors.white
                  : _ConfirmationConstants.primaryBlue,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionDisplay extends StatelessWidget {
  final String description;
  final bool isDarkMode;

  const _DescriptionDisplay({
    required this.description,
    required this.isDarkMode,
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
          'Customer Note',
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
