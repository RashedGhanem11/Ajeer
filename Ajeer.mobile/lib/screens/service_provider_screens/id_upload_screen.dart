import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../widgets/shared_widgets/snackbar.dart';
import 'services_screen.dart';

class IdUploadScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const IdUploadScreen({super.key, required this.themeNotifier});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  static const Color _primaryBlue = Color(0xFF2f6cfa);
  static const Color _lightBlue = Color(0xFFa2bdfc);
  static const double _borderRadius = 50.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 8.0;
  static const double _whiteContainerTopRatio = 0.15;

  File? _idImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = File(image.path);
      });
    }
  }

  void _onNextTap() {
    if (_idImage == null) {
      CustomSnackBar.show(
        context,
        messageKey:
            'required', // Ensure 'required' exists or use a hardcoded fallback key
        dynamicText: ' - Please upload ID',
        backgroundColor: Colors.red,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(
          themeNotifier: widget.themeNotifier,
          idCardImage: _idImage,
          isEdit: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final lang = Provider.of<LanguageNotifier>(context);

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
    final double whiteContainerTop = screenHeight * _whiteContainerTopRatio;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(context),
          _buildWhiteContainer(
            context: context,
            containerTop: whiteContainerTop,
            bottomPadding: bottomNavClearance,
            isDarkMode: isDarkMode,
            lang: lang,
          ),
          _IdUploadNavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onNextTap: _onNextTap,
            isNextEnabled: _idImage != null,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightBlue, _primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required BuildContext context,
    required double containerTop,
    required double bottomPadding,
    required bool isDarkMode,
    required LanguageNotifier lang,
  }) {
    return Positioned(
      top: containerTop,
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(_borderRadius)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  lang.translate('uploadId'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10.0),
                // Subtitle
                Center(
                  child: Text(
                    lang.translate('uploadIdDesc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 250, // Square-ish container
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        image: _idImage != null
                            ? DecorationImage(
                                image: FileImage(_idImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _idImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 60,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  lang.translate('tapToUpload'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdUploadNavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _IdUploadNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
  });

  @override
  State<_IdUploadNavigationHeader> createState() =>
      _IdUploadNavigationHeaderState();
}

class _IdUploadNavigationHeaderState extends State<_IdUploadNavigationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isNextEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_IdUploadNavigationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNextEnabled != oldWidget.isNextEnabled) {
      if (widget.isNextEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Arrow
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: widget.onBackTap,
          ),
          // Ajeer Title
          Text(
            languageNotifier.translate('appName'),
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
          // Next Arrow with Animation
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isNextEnabled)
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
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: widget.isNextEnabled ? Colors.white : Colors.white54,
                ),
                onPressed: widget.isNextEnabled ? widget.onNextTap : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
