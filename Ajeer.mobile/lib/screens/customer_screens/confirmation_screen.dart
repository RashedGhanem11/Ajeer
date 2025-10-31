import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart'; // Contains ServiceScreen

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
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationConstants {
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color secondaryBlue = Color(0xFF57b2ff);
  static const Color confirmGreen = Color(0xFF4CAF50);
  static const Color lightGrayText = Color(0xFFA0A0A0);
  static const Color mediumGrayBorder = Color(0xFFDCDCDC);
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
      .where((file) => !file.path.toLowerCase().endsWith('.mp4'))
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

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
          MaterialPageRoute(builder: (context) => const ServiceScreen()),
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
        : _ConfirmationConstants.secondaryLightBlue;
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

  Widget _buildHomeImage(double logoTopPosition) {
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/image/home.png',
          width: 140,
          height: _ConfirmationConstants.logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildConfirmationDetails(double bottomNavClearance) {
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
          ),
          const SizedBox(height: 15.0),
          _DetailItem(
            icon: serviceIcon,
            title: widget.serviceName,
            subtitle: widget.unitType,
          ),
          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: DateFormat.yMMMMd().format(widget.selectedDate),
            subtitle: widget.selectionMode == 'Custom'
                ? widget.selectedTime.format(context)
                : 'Instant Booking',
          ),
          const _DetailItem(
            icon: Icons.location_on_outlined,
            title: 'Amman',
            subtitle: 'Khalda',
          ),
          const _DetailItem(
            icon: Icons.person_outline,
            title: 'Khalid. S',
            subtitle: '0796753640',
          ),
          const SizedBox(height: 15.0),
          _MediaSummary(
            photoCount: _photoFiles.length,
            videoCount: _videoFiles.length,
            audioCount: 0,
            currentView: _currentMediaView,
            onViewChange: (view) => setState(() => _currentMediaView = view),
          ),
          const SizedBox(height: 10.0),
          _buildMediaContent(),
          const SizedBox(height: 20.0),
          if (widget.userDescription != null &&
              widget.userDescription!.trim().isNotEmpty)
            _DescriptionDisplay(description: widget.userDescription!),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
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

    if (currentFiles.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey[300]!, width: 2.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                placeholderIcon,
                size: 30,
                color: _ConfirmationConstants.lightGrayText,
              ),
              const SizedBox(height: 5),
              Text(
                placeholderText,
                style: TextStyle(color: _ConfirmationConstants.lightGrayText),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey[300]!, width: 2.0),
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
                color: isImage ? Colors.grey.shade200 : Colors.black,
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
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
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  Expanded(
                    child: _buildConfirmationDetails(bottomNavClearance),
                  ),
                ],
              ),
            ),
          ),
          _buildHomeImage(logoTopPosition),
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

  const _PriceAndDurationDisplay({
    required this.totalPrice,
    required this.totalTimeMinutes,
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
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: _ConfirmationConstants.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          _ConfirmationConstants.detailItemBorderRadius,
        ),
        border: Border.all(
          color: _ConfirmationConstants.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on_outlined,
                color: _ConfirmationConstants.primaryBlue,
                size: 30,
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Cost',
                    style: TextStyle(
                      fontSize: 14,
                      color: _ConfirmationConstants.primaryBlue,
                    ),
                  ),
                  Text(
                    'JOD ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1.0,
            color: _ConfirmationConstants.primaryBlue.withOpacity(0.5),
          ),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: _ConfirmationConstants.primaryBlue,
                size: 30,
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Est. Duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: _ConfirmationConstants.primaryBlue,
                    ),
                  ),
                  Text(
                    _formatDuration(totalTimeMinutes),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
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

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  _ConfirmationConstants.detailItemBorderRadius,
                ),
                border: Border.all(
                  color: _ConfirmationConstants.mediumGrayBorder,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
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

  const _MediaSummary({
    required this.photoCount,
    required this.videoCount,
    required this.audioCount,
    required this.currentView,
    required this.onViewChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uploaded Media',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
              context: context,
            ),
            _buildMediaTab(
              label: 'Video',
              type: 'Video',
              icon: Icons.videocam_outlined,
              count: videoCount,
              context: context,
            ),
            _buildMediaTab(
              label: 'Audio',
              type: 'Audio',
              icon: Icons.mic_none,
              count: audioCount,
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
    required BuildContext context,
  }) {
    final bool isSelected = currentView == type;
    return GestureDetector(
      onTap: () => onViewChange(type),
      child: Container(
        width: MediaQuery.of(context).size.width / 4.2,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? _ConfirmationConstants.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? _ConfirmationConstants.primaryBlue
                : Colors.grey.shade300,
            width: 1.5,
          ),
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
                color: isSelected ? Colors.white : Colors.grey.shade700,
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

  const _DescriptionDisplay({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Note',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: _ConfirmationConstants.mediumGrayBorder,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
