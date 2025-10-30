import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final String? userDescription;
  final List<File> pickedMediaFiles;

  const ConfirmationScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    this.userDescription,
    required this.pickedMediaFiles,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _confirmGreen = Color(0xFF4CAF50);
  static const Color _lightGrayText = Color(0xFFA0A0A0);
  static const Color _mediumGrayBorder = Color(0xFFDCDCDC);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _horizontalPadding = 20.0;

  int _selectedIndex = 3;
  bool _isConfirmIconTapped = false;
  String _currentMediaView = 'Images';

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
      _currentMediaView = 'Images';
    } else if (_videoFiles.isNotEmpty) {
      _currentMediaView = 'Video';
    } else {
      _currentMediaView = 'Images';
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 3) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onConfirmTap() {
    setState(() {
      _isConfirmIconTapped = !_isConfirmIconTapped;
    });

    if (_isConfirmIconTapped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking for ${widget.serviceName} confirmed!'),
          backgroundColor: _confirmGreen,
        ),
      );
    }
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
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - _logoHeight + _overlapAdjustment;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildConfirmIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
          ),
          _buildHomeImage(logoTopPosition),
          _ConfirmationNavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onConfirmTap: _onConfirmTap,
            isConfirmed: _isConfirmIconTapped,
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

  Widget _buildBackgroundGradient(double containerTop) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightBlue, _primaryBlue],
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
    final double iconTopPosition = headerHeight + (availableHeight / 2) - 70;

    return Positioned(
      top: iconTopPosition,
      right: 25.0,
      child: GestureDetector(
        onTap: _onConfirmTap,
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _isConfirmIconTapped
                ? LinearGradient(
                    colors: [_confirmGreen.withOpacity(0.8), _confirmGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [_secondaryLightBlue, _secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                color: Colors.black38,
                offset: const Offset(2.0, 2.0),
              ),
              if (_isConfirmIconTapped)
                BoxShadow(
                  color: _confirmGreen.withOpacity(1.0),
                  blurRadius: 70.0,
                  spreadRadius: 20.0,
                  offset: const Offset(0, 0),
                )
              else
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 20.0,
                  spreadRadius: 3.0,
                  offset: const Offset(0, 0),
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
          height: _logoHeight,
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
              padding: const EdgeInsets.only(
                left: _horizontalPadding,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                'Confirm your booking',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  10.0,
                  _horizontalPadding,
                  bottomNavClearance,
                ),
                child: _buildConfirmationDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationDetails() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20.0),

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
    );
  }

  Widget _buildMediaContent() {
    List<File> currentFiles = [];
    IconData placeholderIcon = Icons.clear;
    String placeholderText = '';

    if (_currentMediaView == 'Images') {
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
              Icon(placeholderIcon, size: 30, color: _lightGrayText),
              const SizedBox(height: 5),
              Text(placeholderText, style: TextStyle(color: _lightGrayText)),
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
          final isImage = _currentMediaView == 'Images';

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
}

class _ConfirmationNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onConfirmTap;
  final bool isConfirmed;

  const _ConfirmationNavigationHeader({
    required this.onBackTap,
    required this.onConfirmTap,
    required this.isConfirmed,
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

  static const Color _mediumGrayBorder =
      _ConfirmationScreenState._mediumGrayBorder;
  static const Color _primaryBlue = _ConfirmationScreenState._primaryBlue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 15.0),
            child: Icon(icon, color: _primaryBlue, size: 30),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: _mediumGrayBorder, width: 2.0),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
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

  static const Color _primaryBlue = _ConfirmationScreenState._primaryBlue;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMediaTab(
                label: 'Images',
                type: 'Images',
                icon: Icons.image_outlined,
                count: photoCount,
              ),
            ),
            Expanded(
              child: _buildMediaTab(
                label: 'Video',
                type: 'Video',
                icon: Icons.videocam_outlined,
                count: videoCount,
              ),
            ),
            Expanded(
              child: _buildMediaTab(
                label: 'Audio',
                type: 'Audio',
                icon: Icons.mic_none,
                count: audioCount,
              ),
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
  }) {
    final bool isSelected = currentView == type;
    return GestureDetector(
      onTap: () => onViewChange(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: isSelected ? _primaryBlue : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : _primaryBlue,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (count > 0)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(left: 35.0, bottom: 25.0),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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

  static const Color _mediumGrayBorder =
      _ConfirmationScreenState._mediumGrayBorder;

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
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: _mediumGrayBorder, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
