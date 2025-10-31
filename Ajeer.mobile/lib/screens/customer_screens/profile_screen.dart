import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const double _borderRadius = 50.0;
  static const double _profileAvatarHeight = 100.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;

  int _selectedIndex = 0;

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

  String _firstName = 'Justin';
  String _lastName = 'Mason';
  String _mobileNumber = '962 700000000';
  String _email = 'justin.m@example.com';
  String _password = '********';
  File? _profileImage;
  bool _dataHasChanged = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
    _mobileController = TextEditingController(text: _mobileNumber);
    _emailController = TextEditingController(text: _email);
    _passwordController = TextEditingController(text: _password);
    _addListenersToControllers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addListenersToControllers() {
    void listener() {
      final bool changed =
          _firstNameController.text != _firstName ||
          _lastNameController.text != _lastName ||
          _mobileController.text != _mobileNumber ||
          _emailController.text != _email ||
          (_passwordController.text != _password &&
              _passwordController.text != '********') ||
          (_profileImage != null);

      if (_dataHasChanged != changed) {
        setState(() {
          _dataHasChanged = changed;
        });
      }
    }

    _firstNameController.addListener(listener);
    _lastNameController.addListener(listener);
    _mobileController.addListener(listener);
    _emailController.addListener(listener);
    _passwordController.addListener(listener);
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _dataHasChanged = true;
      });
    }
  }

  void _saveProfile() {
    setState(() {
      _firstName = _firstNameController.text;
      _lastName = _lastNameController.text;
      _mobileNumber = _mobileController.text;
      _email = _emailController.text;
      if (_passwordController.text != '********') {
        _password = _passwordController.text;
      }
      _dataHasChanged = false;
    });
    _passwordController.text = '********';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully!'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  void _showSwitchModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        title: Text(
          'Switch to Provider Mode',
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Do you want to switch from Customer mode to Service Provider mode?',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.all(10.0),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 16.0),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Center(
                    child: Text(
                      'Switch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * 0.25;
    final double avatarTopPosition =
        whiteContainerTop - (_profileAvatarHeight / 2);
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildAjeerTitle(context),
          _buildSwitchModeButton(context),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
          ),
          _buildProfileAvatar(avatarTopPosition),
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

  Widget _buildAjeerTitle(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 0,
      right: 0,
      child: const Center(
        child: Text(
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
      ),
    );
  }

  Widget _buildSwitchModeButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      right: 15,
      child: IconButton(
        icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
        onPressed: _showSwitchModeDialog,
        tooltip: 'Switch Mode',
      ),
    );
  }

  Widget _buildProfileAvatar(double avatarTopPosition) {
    final String initial = _firstName.isNotEmpty
        ? _firstName[0].toUpperCase()
        : '?';

    return Positioned(
      top: avatarTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: _profileAvatarHeight / 2,
                backgroundColor: _lightBlue,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _primaryBlue, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: _primaryBlue, size: 20),
                ),
              ),
            ],
          ),
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
            topLeft: Radius.circular(_borderRadius),
            topRight: Radius.circular(_borderRadius),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.0,
            (_profileAvatarHeight / 2) + 20.0,
            20.0,
            bottomNavClearance + 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25.0),
              _buildInfoField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
              ),
              _buildInfoField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              _buildInfoField(
                controller: _mobileController,
                label: 'Mobile Number (962 7XXXXXXXX)',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildInfoField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildInfoField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: _dataHasChanged ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 5,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor: _primaryBlue.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline, color: _primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _primaryBlue, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}
