// media_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';

class MediaScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;

  const MediaScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
  });

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _lightGrayText = Color(0xFFA0A0A0);
  static const Color _mediumGrayBorder = Color(0xFFDCDCDC);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _horizontalPadding = 20.0;
  static const double _borderRadiusLarge = 20.0;
  static const double _containerHeight = 150.0;

  int _selectedIndex = 3;
  String _selectedMediaType = 'Photo';
  String _userDescription = '';
  bool _isDescriptionSaved = false;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _pickedMediaFiles = [];

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

  @override
  void initState() {
    super.initState();
    _descriptionController.text = _userDescription;
    _descriptionController.addListener(_handleDescriptionChange);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_handleDescriptionChange);
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleDescriptionChange() {
    setState(() {
      _userDescription = _descriptionController.text;
      if (_isDescriptionSaved) {
        _isDescriptionSaved = false;
      }
    });
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

  void _onBackTap() {
    Navigator.pop(context);
  }

  void _onNextTap() {
    print('Navigating to the next screen (Contact/Payment)...');
    print('Selected media type: $_selectedMediaType');
    print('Description: $_userDescription');
    print('Number of media files: ${_pickedMediaFiles.length}');
  }

  void _onSaveDescription() {
    setState(() {
      _isDescriptionSaved = true;
    });
    FocusScope.of(context).unfocus();
  }

  void _onEditDescription() {
    setState(() {
      _isDescriptionSaved = false;
    });
    FocusScope.of(context).requestFocus();
  }

  Future<void> _pickMedia(ImageSource source) async {
    List<XFile> pickedFiles = [];
    if (_selectedMediaType == 'Photo') {
      pickedFiles = await _picker.pickMultiImage();
    } else if (_selectedMediaType == 'Video') {
      final XFile? videoFile = await _picker.pickVideo(source: source);
      if (videoFile != null) {
        pickedFiles.add(videoFile);
      }
    } else {
      print('Audio picking not implemented with ImagePicker.');
      Navigator.of(context).pop();
      return;
    }

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _pickedMediaFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      });
      print('${pickedFiles.length} files selected.');
    } else {
      print('No media selected.');
    }
    Navigator.of(context).pop();
  }

  void _removeMediaFile(int index) {
    setState(() {
      _pickedMediaFiles.removeAt(index);
    });
  }

  void _showMediaUploadDialog(BuildContext context) {
    String mediaType = _selectedMediaType;
    String action = mediaType == 'Photo'
        ? 'images'
        : mediaType == 'Video'
        ? 'video'
        : 'audio recording';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add ${mediaType == 'Photo' ? 'multiple photos' : action}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15.0),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _primaryBlue),
                title: Text(
                  'Select from Gallery / Files',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                onTap: () => _pickMedia(ImageSource.gallery),
              ),
              ListTile(
                leading: mediaType == 'Photo' || mediaType == 'Video'
                    ? const Icon(Icons.camera_alt, color: _primaryBlue)
                    : const Icon(Icons.mic, color: _primaryBlue),
                title: Text(
                  mediaType == 'Photo'
                      ? 'Take Photo'
                      : mediaType == 'Video'
                      ? 'Record Video'
                      : 'Record Audio',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                onTap: () => _pickMedia(ImageSource.camera),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        );
      },
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
          _buildMediaIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
          ),
          _buildHomeImage(logoTopPosition),
          _NavigationHeader(onBackTap: _onBackTap, onNextTap: _onNextTap),
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

  Widget _buildMediaIcon(double containerTop, double statusBarHeight) {
    final double headerHeight = statusBarHeight + 60;
    final double availableHeight = containerTop - headerHeight;
    final double iconTopPosition = headerHeight + (availableHeight / 2) - 70;

    return Positioned(
      top: iconTopPosition,
      right: 25.0,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [_secondaryLightBlue, _secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5.0,
              color: Colors.black38,
              offset: Offset(2.0, 2.0),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: const Icon(
          Icons.camera_alt_outlined,
          size: 55.0,
          color: Colors.white,
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
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Upload media',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 4.0,
                bottom: 10.0,
              ),
              child: Text(
                '${widget.serviceName} - ${widget.unitType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  10.0,
                  _horizontalPadding,
                  bottomNavClearance - _horizontalPadding,
                ),
                child: _buildMediaContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add a photo, video, or audio recording describing your problem',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _lightGrayText,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 25.0),
        _buildMediaTabs(),
        const SizedBox(height: 25.0),
        _buildUploadRectangle(),
        const SizedBox(height: 15.0),
        _buildDescriptionRectangle(),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildMediaTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TabButton(
          type: 'Photo',
          icon: Icons.image_outlined,
          color: _secondaryBlue,
          onTap: () => setState(() {
            _selectedMediaType = 'Photo';
            _pickedMediaFiles = [];
          }),
          isSelected: _selectedMediaType == 'Photo',
        ),
        _TabButton(
          type: 'Video',
          icon: Icons.videocam_outlined,
          color: _secondaryBlue,
          onTap: () => setState(() {
            _selectedMediaType = 'Video';
            _pickedMediaFiles = [];
          }),
          isSelected: _selectedMediaType == 'Video',
        ),
        _TabButton(
          type: 'Audio',
          icon: Icons.mic_none,
          color: _secondaryBlue,
          onTap: () => setState(() {
            _selectedMediaType = 'Audio';
            _pickedMediaFiles = [];
          }),
          isSelected: _selectedMediaType == 'Audio',
        ),
      ],
    );
  }

  Widget _buildUploadRectangle() {
    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _pickedMediaFiles.isEmpty
          ? _buildAddButton()
          : _buildMediaGallery(),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: GestureDetector(
        onTap: () => _showMediaUploadDialog(context),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _secondaryBlue.withOpacity(0.2),
          ),
          child: const Icon(Icons.add, size: 40.0, color: _primaryBlue),
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _pickedMediaFiles.length,
      itemBuilder: (context, index) {
        final file = _pickedMediaFiles[index];
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 10.0 : 5.0,
            right: 5.0,
            top: 10.0,
            bottom: 10.0,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  width: 120,
                  height: double.infinity,
                  color: _selectedMediaType == 'Photo'
                      ? Colors.grey.shade200
                      : Colors.black,
                  child: _selectedMediaType == 'Photo'
                      ? Image.file(file, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeMediaFile(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionRectangle() {
    final Color textColor = _isDescriptionSaved
        ? _lightGrayText
        : Colors.black87;
    final bool enableEditing = !_isDescriptionSaved;

    return Stack(
      children: [
        Container(
          height: _containerHeight,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_borderRadiusLarge),
            border: Border.all(color: Colors.grey.shade300, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 10.0,
                    right: _isDescriptionSaved ? 10.0 : 30.0,
                    bottom: 5.0,
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    enabled: enableEditing,
                    cursorColor: _primaryBlue,
                    decoration: const InputDecoration(
                      hintText:
                          'Write a description of your problem (Optional)',
                      hintStyle: TextStyle(
                        color: _lightGrayText,
                        fontSize: 16.0,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: textColor, fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              if (!_isDescriptionSaved)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _userDescription.trim().isEmpty
                        ? null
                        : _onSaveDescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_isDescriptionSaved)
                const Padding(
                  padding: EdgeInsets.only(right: 10.0, bottom: 5.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Description Saved',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isDescriptionSaved)
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: _primaryBlue),
              onPressed: _onEditDescription,
            ),
          ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const _TabButton({
    required this.type,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = _MediaScreenState._primaryBlue;
    const Color mediumGrayBorder = _MediaScreenState._mediumGrayBorder;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: isSelected ? primaryBlue : mediumGrayBorder,
                width: 2.0,
              ),
            ),
            child: Icon(
              icon,
              size: 30.0,
              color: isSelected ? Colors.white : primaryBlue,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            type,
            style: TextStyle(
              color: isSelected ? primaryBlue : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;

  const _NavigationHeader({required this.onBackTap, required this.onNextTap});

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
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: onNextTap,
          ),
        ],
      ),
    );
  }
}
