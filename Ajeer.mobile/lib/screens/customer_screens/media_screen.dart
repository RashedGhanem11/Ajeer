import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'confirmation_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import 'home_screen.dart';
import '../../notifiers/language_notifier.dart';
import 'dart:ui';

class MediaScreen extends StatefulWidget {
  final List<int> serviceIds;
  final int serviceAreaId;
  final double latitude;
  final double longitude;
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
    required this.serviceIds,
    required this.serviceAreaId,
    required this.latitude,
    required this.longitude,
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

  final int _selectedIndex = 3;
  String _selectedMediaType = 'Photo';
  String _userDescription = '';
  bool _isDescriptionSaved = false;

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<File> _photoFiles = [];
  final List<File> _videoFiles = [];
  final List<File> _audioFiles = [];

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context, listen: false);
  }

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
    if (_selectedMediaType == 'Photo') return _photoFiles;
    if (_selectedMediaType == 'Video') return _videoFiles;
    if (_selectedMediaType == 'Audio') return _audioFiles;
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

  void _onBackTap() => Navigator.pop(context);

  void _onNextTap() => _navigateToConfirmation();

  void _navigateToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          serviceIds: widget.serviceIds,
          serviceAreaId: widget.serviceAreaId,
          latitude: widget.latitude,
          longitude: widget.longitude,
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectionMode: widget.selectionMode,
          userDescription: _userDescription,
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
    setState(() => _isDescriptionSaved = true);
    FocusScope.of(context).unfocus();
  }

  void _onEditDescription() {
    setState(() => _isDescriptionSaved = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageNotifier.translate(
              source == ImageSource.gallery
                  ? 'audioNotImplemented'
                  : 'audioSimulated',
            ),
          ),
        ),
      );
      Navigator.of(context).pop();
      return;
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
      if (_selectedMediaType == 'Photo') {
        _photoFiles.removeAt(index);
      } else if (_selectedMediaType == 'Video') {
        _videoFiles.removeAt(index);
      } else {
        _audioFiles.removeAt(index);
      }
    });
  }

  void _showMediaUploadDialog(BuildContext context, bool isDarkMode) {
    String mediaTypeKey = _selectedMediaType == 'Photo'
        ? 'addPhoto'
        : (_selectedMediaType == 'Video' ? 'addVideo' : 'addAudio');

    bool isAudio = _selectedMediaType == 'Audio';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _languageNotifier.translate(mediaTypeKey),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 15.0),
                if (!isAudio)
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: _primaryBlue,
                    ),
                    title: Text(
                      _languageNotifier.translate('selectFromGallery'),
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade700,
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
                    isAudio
                        ? _languageNotifier.translate('recordAudio')
                        : _languageNotifier.translate('camera'),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  onTap: () => _pickMedia(ImageSource.camera),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        );
      },
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
          _buildMediaIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(
            onBackTap: _onBackTap,
            onNextTap: _onNextTap,
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
    final isArabic = _languageNotifier.isArabic;

    return Positioned(
      top: iconTopPosition,
      right: isArabic ? null : 25.0,
      left: isArabic ? 25.0 : null,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
    required LanguageNotifier languageNotifier,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Text(
                languageNotifier.translate('uploadMedia'),
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
                child: _buildMediaContent(isDarkMode, languageNotifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(
    bool isDarkMode,
    LanguageNotifier languageNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          languageNotifier.translate('mediaDescription'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey : Colors.grey.shade600,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 25.0),
        _buildMediaTabs(isDarkMode, languageNotifier),
        const SizedBox(height: 25.0),
        _buildUploadRectangle(isDarkMode),
        const SizedBox(height: 15.0),
        _buildDescriptionRectangle(
          isDarkMode,
          isDarkMode ? Colors.white70 : Colors.black87,
          languageNotifier,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildMediaTabs(bool isDarkMode, LanguageNotifier languageNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TabButton(
          type: languageNotifier.translate('photo'),
          icon: Icons.image_outlined,
          onTap: () => setState(() => _selectedMediaType = 'Photo'),
          isSelected: _selectedMediaType == 'Photo',
          isDarkMode: isDarkMode,
        ),
        _TabButton(
          type: languageNotifier.translate('video'),
          icon: Icons.videocam_outlined,
          onTap: () => setState(() => _selectedMediaType = 'Video'),
          isSelected: _selectedMediaType == 'Video',
          isDarkMode: isDarkMode,
        ),
        _TabButton(
          type: languageNotifier.translate('audio'),
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

  Widget _buildDescriptionRectangle(
    bool isDarkMode,
    Color textColor,
    LanguageNotifier languageNotifier,
  ) {
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
                  padding: EdgeInsetsDirectional.only(
                    top: 10.0,
                    end: _isDescriptionSaved ? 10.0 : 30.0,
                    bottom: 5.0,
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    enabled: !_isDescriptionSaved,
                    cursorColor: _primaryBlue,
                    decoration: InputDecoration(
                      hintText: languageNotifier.translate('descriptionHint'),
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
                    child: Text(
                      languageNotifier.translate('save'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_isDescriptionSaved)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 5.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      languageNotifier.translate('descriptionSaved'),
                      style: const TextStyle(
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

class _TabButton extends StatefulWidget {
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
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
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
      end: 0.8,
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
    const Color primaryBlue = Color(0xFF1976D2);
    final Color borderColor = widget.isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? primaryBlue
                    : (widget.isDarkMode
                          ? const Color(0xFF2C2C2C)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: widget.isSelected ? primaryBlue : borderColor,
                  width: 2.0,
                ),
              ),
              child: Icon(
                widget.icon,
                size: 30.0,
                color: widget.isSelected ? Colors.white : primaryBlue,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.type,
              style: TextStyle(
                color: widget.isSelected
                    ? primaryBlue
                    : (widget.isDarkMode
                          ? Colors.grey.shade500
                          : Colors.grey.shade600),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final String appName;

  const _NavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    required this.appName,
  });

  @override
  State<_NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<_NavigationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            onPressed: widget.onBackTap,
          ),
          Text(
            widget.appName,
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
          Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
              IconButton(
                iconSize: 28.0,
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: widget.onNextTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
