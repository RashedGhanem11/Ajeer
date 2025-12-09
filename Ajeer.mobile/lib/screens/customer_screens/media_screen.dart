import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http; // Add http package
import 'package:provider/provider.dart';

// --- IMPORTS FOR YOUR PROJECT ---
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'confirmation_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';

// Check this path matches where you store your AppConfig class
import '../../config/app_config.dart';

class MediaScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final int totalTimeMinutes;
  final double totalPrice;
  final String resolvedCityArea;
  final String resolvedAddress;

  const MediaScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    required this.totalTimeMinutes,
    required this.totalPrice,
    required this.resolvedAddress,
    required this.resolvedCityArea,
  });

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  // --- COLORS & CONSTANTS ---
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleLighterDark = Color(0xFF2C2C2C);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _horizontalPadding = 20.0;
  static const double _borderRadiusLarge = 20.0;
  static const double _containerHeight = 150.0;

  // --- STATE VARIABLES ---
  int _selectedIndex = 3;
  String _selectedMediaType = 'Photo';
  String _userDescription = '';
  bool _isDescriptionSaved = false;
  bool _isUploading = false; // New state for loading overlay

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final MediaService _mediaService = MediaService(); // Service Instance

  final List<File> _photoFiles = [];
  final List<File> _videoFiles = [];
  final List<File> _audioFiles = [];

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

  List<File> get _currentMediaFiles {
    if (_selectedMediaType == 'Photo') {
      return _photoFiles;
    } else if (_selectedMediaType == 'Video') {
      return _videoFiles;
    } else if (_selectedMediaType == 'Audio') {
      return _audioFiles;
    }
    return [];
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
    if (index == _selectedIndex) return;
    if (_isUploading) return; // Prevent navigation during upload

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

  void _onBackTap() {
    if (!_isUploading) Navigator.pop(context);
  }

  // --- REWRITTEN UPLOAD LOGIC ---
  Future<void> _onNextTap() async {
    List<File> allFiles = [..._photoFiles, ..._videoFiles, ..._audioFiles];

    // Optional: If no files, just proceed (or you can block it)
    if (allFiles.isEmpty) {
      _navigateToConfirmation([]);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<AttachmentResponse> uploadedAttachments = [];

      // Loop through all files and upload them
      for (var file in allFiles) {
        // Adjust 'Attachments' to your specific API controller route if different
        // e.g. 'Attachments/upload'
        var result = await _mediaService.uploadMedia(file, "Attachments");

        if (result != null) {
          uploadedAttachments.add(result);
        }
      }

      if (mounted) {
        _navigateToConfirmation(uploadedAttachments);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading media: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _navigateToConfirmation(List<AttachmentResponse> uploadedAttachments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectionMode: widget.selectionMode,
          userDescription: _userDescription,

          // You likely need to update ConfirmationScreen to accept this:
          // uploadedAttachments: uploadedAttachments,

          // Passing raw files for UI preview (if needed)
          pickedMediaFiles: [..._photoFiles, ..._videoFiles, ..._audioFiles],

          totalTimeMinutes: widget.totalTimeMinutes,
          totalPrice: widget.totalPrice,
          resolvedCityArea: widget.resolvedCityArea,
          resolvedAddress: widget.resolvedAddress,
        ),
      ),
    );
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
      if (videoFile != null) pickedFiles.add(videoFile);
    } else if (_selectedMediaType == 'Audio') {
      if (source == ImageSource.gallery) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio from files not implemented in simulation.'),
          ),
        );
        Navigator.of(context).pop();
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording is simulated.')),
        );
        Navigator.of(context).pop();
        return;
      }
    }

    if (pickedFiles.isNotEmpty) {
      setState(() {
        if (_selectedMediaType == 'Photo') {
          _photoFiles.addAll(pickedFiles.map((x) => File(x.path)));
        } else if (_selectedMediaType == 'Video') {
          _videoFiles.addAll(pickedFiles.map((x) => File(x.path)));
        } else {
          _audioFiles.addAll(pickedFiles.map((x) => File(x.path)));
        }
      });
    }
    Navigator.of(context).pop();
  }

  void _removeMediaFile(int index) {
    setState(() {
      if (_selectedMediaType == 'Photo')
        _photoFiles.removeAt(index);
      else if (_selectedMediaType == 'Video')
        _videoFiles.removeAt(index);
      else
        _audioFiles.removeAt(index);
    });
  }

  void _showMediaUploadDialog(BuildContext context, bool isDarkMode) {
    String mediaType = _selectedMediaType;
    bool isAudio = mediaType == 'Audio';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add $mediaType',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 15.0),
              if (!isAudio)
                ListTile(
                  leading: const Icon(Icons.photo_library, color: _primaryBlue),
                  title: Text(
                    'Select from Gallery',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  onTap: () => _pickMedia(ImageSource.gallery),
                ),
              ListTile(
                leading: Icon(
                  isAudio ? Icons.mic : Icons.camera_alt,
                  color: _primaryBlue,
                ),
                title: Text(
                  isAudio ? 'Record Audio' : 'Camera',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                  ),
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bool isDarkMode = themeNotifier.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
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
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
            isDarkMode: isDarkMode,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(onBackTap: _onBackTap, onNextTap: _onNextTap),

          // --- LOADING OVERLAY ---
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Uploading Media...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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

  // --- WIDGET BUILDERS (Unchanged logic, just compacted for brevity) ---
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
          color: _primaryBlue,
        ),
      ),
    );
  }

  Widget _buildHomeImage(double logoTopPosition, bool isDarkMode) {
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          isDarkMode ? 'assets/image/home_dark.png' : 'assets/image/home.png',
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
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
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
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Upload media',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
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
                child: _buildMediaContent(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add a photo, video, or audio recording describing your problem',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey : Colors.grey.shade600,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 25.0),
        _buildMediaTabs(isDarkMode),
        const SizedBox(height: 25.0),
        _buildUploadRectangle(isDarkMode),
        const SizedBox(height: 15.0),
        _buildDescriptionRectangle(
          isDarkMode,
          isDarkMode ? Colors.white70 : Colors.black87,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildMediaTabs(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TabButton(
          type: 'Photo',
          icon: Icons.image_outlined,
          onTap: () => setState(() => _selectedMediaType = 'Photo'),
          isSelected: _selectedMediaType == 'Photo',
          isDarkMode: isDarkMode,
        ),
        _TabButton(
          type: 'Video',
          icon: Icons.videocam_outlined,
          onTap: () => setState(() => _selectedMediaType = 'Video'),
          isSelected: _selectedMediaType == 'Video',
          isDarkMode: isDarkMode,
        ),
        _TabButton(
          type: 'Audio',
          icon: Icons.mic_none,
          onTap: () => setState(() => _selectedMediaType = 'Audio'),
          isSelected: _selectedMediaType == 'Audio',
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildUploadRectangle(bool isDarkMode) {
    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
        color: isDarkMode ? _subtleLighterDark : Colors.white,
        borderRadius: BorderRadius.circular(_borderRadiusLarge),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 2.0,
        ),
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
      child: _currentMediaFiles.isEmpty
          ? _buildAddButton(isDarkMode)
          : _buildMediaGallery(),
    );
  }

  Widget _buildAddButton(bool isDarkMode) {
    return Center(
      child: GestureDetector(
        onTap: () => _showMediaUploadDialog(context, isDarkMode),
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
      itemCount: _currentMediaFiles.length,
      itemBuilder: (context, index) {
        final file = _currentMediaFiles[index];
        final isPhoto = _selectedMediaType == 'Photo';
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
                  color: isPhoto ? Colors.grey.shade200 : Colors.black,
                  child: isPhoto
                      ? Image.file(file, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            _selectedMediaType == 'Audio'
                                ? Icons.mic_rounded
                                : Icons.play_circle_outline,
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

  Widget _buildDescriptionRectangle(bool isDarkMode, Color textColor) {
    final Color effectiveTextColor = _isDescriptionSaved
        ? (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600)
        : textColor;
    return Stack(
      children: [
        Container(
          height: _containerHeight,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isDarkMode ? _subtleLighterDark : Colors.white,
            borderRadius: BorderRadius.circular(_borderRadiusLarge),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 2.0,
            ),
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
                    enabled: !_isDescriptionSaved,
                    cursorColor: _primaryBlue,
                    decoration: InputDecoration(
                      hintText:
                          'Write a description of your problem (Optional)',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                        fontSize: 16.0,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: effectiveTextColor, fontSize: 16.0),
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
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDarkMode;

  const _TabButton({
    required this.type,
    required this.icon,
    required this.onTap,
    required this.isSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1976D2);
    final Color borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryBlue
                  : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.transparent),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: isSelected ? primaryBlue : borderColor,
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
              color: isSelected
                  ? primaryBlue
                  : (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
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
          const Text(
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
          ),
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

// ==========================================
// SERVICE AND MODELS (Move these to separate files ideally)
// ==========================================

class MediaService {
  Future<AttachmentResponse?> uploadMedia(File file, String endpoint) async {
    try {
      // NOTE: endpoint should be just the controller name or full path suffix like "Attachments"
      // Resulting URL: http://localhost:5289/api/Attachments
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiUrl}/$endpoint'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AttachmentResponse.fromJson(data);
      } else {
        debugPrint("Upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading media: $e");
      return null;
    }
  }
}

enum FileType { Image, Video, Audio }

enum MimeType { Jpeg, Png, Webp, Mp4, Mov, Mp3, Wav, M4a, Other }

class AttachmentResponse {
  final int id;
  final String url;
  final FileType fileType;
  final MimeType mimeType;

  AttachmentResponse({
    required this.id,
    required this.url,
    required this.fileType,
    required this.mimeType,
  });

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) {
    // Helper to parse enums safely
    T enumFromString<T>(Iterable<T> values, String? value, T defaultValue) {
      return values.firstWhere(
        (type) => type.toString().split('.').last == value,
        orElse: () => defaultValue,
      );
    }

    return AttachmentResponse(
      id: json['id'] ?? json['Id'] ?? 0,
      url: json['url'] ?? json['Url'] ?? '',
      fileType: enumFromString(
        FileType.values,
        json['fileType'] ?? json['FileType'],
        FileType.Image,
      ),
      mimeType: enumFromString(
        MimeType.values,
        json['mimeType'] ?? json['MimeType'],
        MimeType.Other,
      ),
    );
  }
}
