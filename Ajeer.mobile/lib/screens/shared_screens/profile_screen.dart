import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../widgets/customer_widgets/custom_bottom_nav_bar.dart';
import '../customer_screens/bookings_screen.dart';
import '../customer_screens/home_screen.dart';
import '../customer_screens/chat_screen.dart';
import '../../themes/theme_notifier.dart';
import '../customer_screens/login_screen.dart';
import '../../widgets/shared_widgets/settings_menu.dart';
import '../service_provider_screens/services_screen.dart';
import '../../notifiers/user_notifier.dart';
import '../../models/provider_data.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const ProfileScreen({super.key, required this.themeNotifier});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _darkBlue = Color(0xFF0D47A1);
  static const Color _subtleDark = Color(0xFF1E1E1E);
  static const Color _subtleLighterDark = Color(0xFF2C2C2C);
  static const Color _editableBorderColorDark = Color(0xFF757575);
  static const Color _saveGreen = Color(0xFF4CAF50);
  static const Color _cancelRed = Color(0xFFF44336);
  static const double _borderRadius = 50.0;
  static const double _profileAvatarHeight = 100.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _fieldVerticalPadding = 16.0;
  static const double _whiteContainerHeightRatio = 0.3;
  static const double _profileTextGapReduction = 10.0;
  static const double _maxButtonWidth = 260.0;

  int _selectedIndex = 0;
  bool _isPasswordVisible = false;
  bool _isEditing = false;
  bool _dataHasChanged = false;

  Set<int> _selectedNotifications = {};
  bool _isDeleting = false;
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Booking Confirmation',
      'subtitle': 'Your booking #1023 is confirmed.',
      'icon': Icons.calendar_today,
      'color': Colors.green,
    },
    {
      'title': 'Provider Assigned',
      'subtitle': 'John Doe has been assigned to your service.',
      'icon': Icons.people_alt,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Reminder',
      'subtitle': 'A service fee is due tomorrow.',
      'icon': Icons.payments,
      'color': Colors.orange,
    },
    {
      'title': 'Ajeer Update',
      'subtitle': 'Check out the new app features!',
      'icon': Icons.notifications_active,
      'color': Colors.purple,
    },
    {
      'title': 'System Maintenance',
      'subtitle': 'Scheduled downtime this Friday at 2 AM.',
      'icon': Icons.build,
      'color': Colors.grey,
    },
  ];

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

  String _firstName = 'Ahmad';
  String _lastName = 'K.';
  String _mobileNumber = '962 700000000';
  String _email = 'ahmad.k@example.com';
  String _password = '********';
  File? _profileImage;
  File? _originalProfileImage;

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
          (_profileImage != _originalProfileImage);

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
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(themeNotifier: widget.themeNotifier),
          ),
        );
        break;
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;

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
      _originalProfileImage = _profileImage;
      _dataHasChanged = false;
      _isEditing = false;
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

  void _toggleEditMode() {
    if (!_isEditing) {
      _originalProfileImage = _profileImage;
    } else {
      if (_dataHasChanged) {
        _firstNameController.text = _firstName;
        _lastNameController.text = _lastName;
        _mobileController.text = _mobileNumber;
        _emailController.text = _email;
        _passwordController.text = '********';
        _profileImage = _originalProfileImage;
        _dataHasChanged = false;
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _toggleNotificationSelection(int index) {
    setState(() {
      if (_selectedNotifications.contains(index)) {
        _selectedNotifications.remove(index);
      } else {
        _selectedNotifications.add(index);
      }
      _isDeleting = _selectedNotifications.isNotEmpty;
    });
  }

  void _deleteSelectedNotifications() {
    setState(() {
      final List<Map<String, dynamic>> toKeep = [];
      for (int i = 0; i < _notifications.length; i++) {
        if (!_selectedNotifications.contains(i)) {
          toKeep.add(_notifications[i]);
        }
      }
      _notifications = toKeep;
      _selectedNotifications.clear();
      _isDeleting = false;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1976D2)),
              SizedBox(width: 10),
              Text('Ajeer Info'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Ajeer is your dedicated platform for booking and managing home services. '
                  'We connect two main user types: customers who need reliable services, and '
                  'service providers (professionals) who offer them, ensuring a seamless experience for all.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    final Color contentTextColor = Theme.of(
      context,
    ).textTheme.bodyLarge!.color!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          title: Text(
            'Sign Out',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          content: const Text(
            'Would you like to sign out?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('No', style: TextStyle(color: contentTextColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'SIGN OUT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSwitchModeDialog(BuildContext context, UserNotifier userNotifier) {
    final bool isProvider = userNotifier.isProvider;
    final bool isSetupComplete = userNotifier.isProviderSetupComplete;
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

    final String title = isProvider
        ? 'Switch to Customer Mode'
        : 'Switch to Provider Mode';
    final String content = isProvider
        ? 'Do you want to switch back to Customer mode?'
        : 'Do you want to switch to Service Provider mode?';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? _subtleDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        title: Text(
          title,
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
        ),
        actionsPadding: const EdgeInsets.all(10.0),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey.shade700,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();

                    if (isSetupComplete) {
                      userNotifier.toggleUserMode();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServicesScreen(
                            themeNotifier: widget.themeNotifier,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Center(
                    child: Text(
                      'Switch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
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
    final userNotifier = Provider.of<UserNotifier>(context);
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * _whiteContainerHeightRatio;
    final double avatarTopPosition =
        whiteContainerTop - (_profileAvatarHeight / 2);
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      drawer: SettingsMenu(
        themeNotifier: widget.themeNotifier,
        onInfoTap: _showInfoDialog,
        onSignOutTap: _showSignOutDialog,
        notifications: _notifications,
        selectedNotifications: _selectedNotifications,
        isDeleting: _isDeleting,
        onToggleNotificationSelection: _toggleNotificationSelection,
        onDeleteSelectedNotifications: _deleteSelectedNotifications,
      ),
      body: Stack(
        children: [
          _buildBackgroundGradient(
            containerTop: whiteContainerTop,
            isDarkMode: isDarkMode,
          ),
          _buildAjeerTitle(context),
          _buildSwitchModeButton(context, isDarkMode, userNotifier),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
            userNotifier: userNotifier,
          ),
          _buildProfileAvatar(avatarTopPosition, isDarkMode),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBackgroundGradient({
    required double containerTop,
    required bool isDarkMode,
  }) {
    final Color endColor = _primaryBlue;
    final Color startColor = _lightBlue;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
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

  Widget _buildSwitchModeButton(
    BuildContext context,
    bool isDarkMode,
    UserNotifier userNotifier,
  ) {
    final double buttonTop = MediaQuery.of(context).padding.top + 70;

    final Color bgColor = isDarkMode ? _subtleDark : Colors.grey.shade300;
    final Color fgColor = isDarkMode ? Colors.white : _primaryBlue;

    final bool isProvider = userNotifier.isProvider;
    final bool isSetupComplete = userNotifier.isProviderSetupComplete;

    final IconData icon;
    final String label;

    if (!isSetupComplete) {
      icon = Icons.rocket_launch;
      label = 'Become an Ajeer!';
    } else if (isProvider) {
      icon = Icons.person;
      label = 'Switch to Customer Mode';
    } else {
      icon = Icons.handyman;
      label = 'Switch to Provider Mode';
    }

    return Positioned(
      top: buttonTop,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: _maxButtonWidth,
          child: ElevatedButton.icon(
            onPressed: () {
              if (!isSetupComplete) {
                // 🚀 First time provider setup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServicesScreen(
                      themeNotifier: Provider.of<ThemeNotifier>(
                        context,
                        listen: false,
                      ),
                      isEdit: false,
                      initialData: null,
                    ),
                  ),
                );
              } else {
                // 🔄 Existing provider switching mode
                _showSwitchModeDialog(context, userNotifier);
              }
            },

            icon: Icon(icon, size: 20),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(double avatarTopPosition, bool isDarkMode) {
    final String initial = _firstName.isNotEmpty
        ? _firstName[0].toUpperCase()
        : '?';

    final Color avatarBgColor = isDarkMode ? _darkBlue : _lightBlue;
    final Color avatarFgColor = isDarkMode ? _lightBlue : _primaryBlue;
    final Color editIconBg = isDarkMode ? _subtleDark : Colors.white;

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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? _subtleDark : Colors.white,
                    width: 4.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: _profileAvatarHeight / 2,
                  backgroundColor: avatarBgColor,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: avatarFgColor,
                          ),
                        )
                      : null,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: editIconBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryBlue, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: _primaryBlue,
                      size: 20,
                    ),
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
    required bool isDarkMode,
    required UserNotifier userNotifier,
  }) {
    final Color containerColor = isDarkMode ? _subtleDark : Colors.white;
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return Positioned(
      top: containerTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_borderRadius),
            topRight: Radius.circular(_borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  (_profileAvatarHeight / 2) + 20.0 - _profileTextGapReduction,
                  0,
                  20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                    ),
                    Builder(
                      builder: (context) {
                        return _buildEditSaveButtons(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 10.0,
                    bottom: bottomNavClearance + 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isDarkMode: isDarkMode,
                      ),
                      if (userNotifier.isProviderSetupComplete &&
                          userNotifier.providerData != null)
                        _ProviderInfoSection(
                          providerData: userNotifier.providerData!,
                          isEnabled: userNotifier.isProvider,
                          isDarkMode: isDarkMode,
                          isEditing: _isEditing,
                          editableBorderColorDark: _editableBorderColorDark,
                          subtleLighterDark: _subtleLighterDark,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditSaveButtons(BuildContext context) {
    final Color saveColor = _dataHasChanged ? _saveGreen : Colors.grey;
    final bool saveEnabled = _dataHasChanged;

    final Color cancelColor = _isEditing ? _cancelRed : _primaryBlue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isEditing)
          _buildActionButton(
            icon: Icons.check,
            tooltip: 'Save Changes',
            onPressed: saveEnabled ? _saveProfile : null,
            backgroundColor: saveColor,
          ),
        if (_isEditing) const SizedBox(width: 10),
        _buildActionButton(
          icon: _isEditing ? Icons.close : Icons.edit,
          tooltip: _isEditing ? 'Cancel Editing' : 'Edit Profile',
          onPressed: _toggleEditMode,
          backgroundColor: cancelColor,
        ),
        const SizedBox(width: 10),
        _buildActionButton(
          icon: Icons.settings,
          tooltip: 'Settings',
          onPressed: () => Scaffold.of(context).openDrawer(),
          backgroundColor: _primaryBlue,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required bool isDarkMode,
  }) {
    final Color fieldTextColor = _isEditing
        ? (isDarkMode ? Colors.white : Colors.black87)
        : Colors.grey.shade400;

    final Color fieldFillColor = _isEditing
        ? (isDarkMode ? _subtleLighterDark : Colors.white)
        : (isDarkMode ? _subtleDark : Colors.grey.shade100);

    final Color fieldBorderColor = _isEditing
        ? (isDarkMode ? _editableBorderColorDark : Colors.grey.shade400)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);

    final Color disabledBorderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        readOnly: !_isEditing,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: TextStyle(color: fieldTextColor),
        enableInteractiveSelection: _isEditing,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: _isEditing ? _primaryBlue : Colors.grey,
          ),
          suffixIcon: isPassword && _isEditing
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _primaryBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          floatingLabelStyle: _isEditing
              ? const TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.normal,
                )
              : TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.normal,
          ),
          fillColor: fieldFillColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: fieldBorderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: fieldBorderColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _primaryBlue, width: 3.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: disabledBorderColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: _fieldVerticalPadding,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}

class _ProviderInfoSection extends StatelessWidget {
  final ProviderData providerData;
  final bool isEnabled;
  final bool isDarkMode;
  final bool isEditing;
  final Color editableBorderColorDark;
  final Color subtleLighterDark;

  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _subtleDark = Color(0xFF1E1E1E);

  const _ProviderInfoSection({
    required this.providerData,
    required this.isEnabled,
    required this.isDarkMode,
    required this.isEditing,
    required this.editableBorderColorDark,
    required this.subtleLighterDark,
  });

  Widget _buildSmallEditButton(BuildContext context) {
    if (!isEditing || !isEnabled) return const SizedBox.shrink();

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _primaryBlue,
        shape: BoxShape.circle,
        border: Border.all(color: subtleLighterDark, width: 1.0),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
        onPressed: () {
          final userNotifier = Provider.of<UserNotifier>(
            context,
            listen: false,
          );
          final providerData = userNotifier.providerData;

          if (providerData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServicesScreen(
                  themeNotifier: Provider.of<ThemeNotifier>(
                    context,
                    listen: false,
                  ),
                  isEdit: true,
                  initialData: providerData,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isEnabled
        ? (isDarkMode ? Colors.white : Colors.black87)
        : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Provider Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                _buildSmallEditButton(context),
              ],
            ),
          ),
          _buildProviderField(
            context,
            'My Services',
            Icons.miscellaneous_services_outlined,
            providerData.selectedServices.entries
                    .where((entry) => entry.value.isNotEmpty)
                    .map(
                      (entry) => '**${entry.key}**: ${entry.value.join(', ')}',
                    )
                    .toList()
                    .cast<String>()
                    .isEmpty
                ? ['No services selected.']
                : providerData.selectedServices.entries
                      .where((entry) => entry.value.isNotEmpty)
                      .map(
                        (entry) =>
                            '**${entry.key}**: ${entry.value.join(', ')}',
                      )
                      .toList(),
          ),

          _buildProviderField(
            context,
            'My Locations',
            Icons.location_on_outlined,
            providerData.selectedLocations.isEmpty
                ? ['No locations selected.']
                : providerData.selectedLocations
                      .map((loc) => '**${loc.city}**: ${loc.areas.join(', ')}')
                      .toList(),
          ),
          _buildProviderField(
            context,
            'My Schedule',
            Icons.schedule_outlined,
            providerData.finalSchedule.isEmpty
                ? ['No schedule set.']
                : providerData.finalSchedule
                      .map(
                        (schedule) =>
                            '${schedule.day}: ${schedule.timeSlots.map((t) => t.toString()).join(', ')}',
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderField(
    BuildContext context,
    String label,
    IconData icon,
    List<String> contentLines,
  ) {
    final bool isReadOnly = !isEnabled || !isEditing;

    final Color fieldTextColor = isReadOnly
        ? (isDarkMode ? Colors.grey.shade400 : Colors.black54)
        : (isDarkMode ? Colors.white70 : Colors.black87);

    final Color fieldFillColor = isReadOnly
        ? (isDarkMode ? _subtleDark : Colors.grey.shade100)
        : (isDarkMode ? subtleLighterDark : Colors.white);

    final Color fieldBorderColor = isReadOnly
        ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)
        : (isDarkMode ? editableBorderColorDark : Colors.grey.shade400);

    final Color labelColor = isReadOnly
        ? (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600)
        : (isDarkMode ? Colors.white : Colors.black87);

    final Color iconColor = isEnabled && isEditing ? _primaryBlue : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: fieldFillColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: fieldBorderColor, width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ...contentLines.map((line) {
              final int separatorIndex = line.indexOf(': ');

              if (separatorIndex != -1 && line.startsWith('**')) {
                final String keyPart = line.substring(0, separatorIndex);
                final String valuePart = line.substring(separatorIndex + 2);

                final String plainKey = keyPart.replaceAll('**', '');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$plainKey: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: fieldTextColor,
                          ),
                        ),
                        TextSpan(
                          text: valuePart,
                          style: TextStyle(fontSize: 14, color: fieldTextColor),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    line,
                    style: TextStyle(fontSize: 14, color: fieldTextColor),
                  ),
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}
