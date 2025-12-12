import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import '../../widgets/shared_widgets/settings_menu.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/user_notifier.dart';
import '../../models/provider_data.dart';

import '../customer_screens/bookings_screen.dart';
import '../customer_screens/home_screen.dart';
import '../customer_screens/chat_screen.dart';
import '../customer_screens/login_screen.dart';
import '../service_provider_screens/services_screen.dart';

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
  static const double _navBarTotalHeight = 86.0;
  static const double _whiteContainerHeightRatio = 0.3;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  bool _isPasswordVisible = false;
  bool _isEditing = false;
  bool _dataHasChanged = false;

  String _firstName = '';
  String _lastName = '';
  String _mobileNumber = '';
  String _email = '';
  String _password = '';
  File? _profileImage;
  File? _originalProfileImage;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final Set<int> _selectedNotifications = {};
  bool _isDeleting = false;
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Booking Confirmation',
      'subtitle': 'Your booking #1023 is confirmed.',
      'icon': Icons.calendar_today,
      'color': Colors.green,
    },
    {
      'title': 'Provider Assigned',
      'subtitle': 'John Doe has been assigned.',
      'icon': Icons.people_alt,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Reminder',
      'subtitle': 'Service fee due tomorrow.',
      'icon': Icons.payments,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();

    // ✅ NEW: Force backend fetch for Provider Data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserNotifier>(context, listen: false).loadUserData();
    });
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _addListenersToControllers();
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
        setState(() => _dataHasChanged = changed);
      }
    }

    _firstNameController.addListener(listener);
    _lastNameController.addListener(listener);
    _mobileController.addListener(listener);
    _emailController.addListener(listener);
    _passwordController.addListener(listener);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      if (mounted) {
        setState(() {
          _firstName = user['firstName'] ?? '';
          _lastName = user['lastName'] ?? '';
          _mobileNumber = user['phone'] ?? '';
          _email = user['email'] ?? '';
          _password = user['password'] ?? '';

          _firstNameController.text = _firstName;
          _lastNameController.text = _lastName;
          _mobileController.text = _mobileNumber;
          _emailController.text = _email;
          _passwordController.text = '********';
        });
      }
    }
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

  Future<void> _saveProfile() async {
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

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      user['firstName'] = _firstName;
      user['lastName'] = _lastName;
      user['phone'] = _mobileNumber;
      user['email'] = _email;
      user['password'] = _password;

      final usersJsonList = prefs.getStringList('users') ?? [];
      final List<Map<String, dynamic>> users = usersJsonList
          .map((u) => Map<String, dynamic>.from(jsonDecode(u)))
          .toList();

      for (int i = 0; i < users.length; i++) {
        if (users[i]['email'] == user['email']) {
          users[i] = user;
          break;
        }
      }

      await prefs.setStringList(
        'users',
        users.map((u) => jsonEncode(u)).toList(),
      );
      await prefs.setString('currentUser', jsonEncode(user));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _firstNameController.text = _firstName;
        _lastNameController.text = _lastName;
        _mobileController.text = _mobileNumber;
        _emailController.text = _email;
        _passwordController.text = '********';
        _profileImage = _originalProfileImage;
        _dataHasChanged = false;
      } else {
        _originalProfileImage = _profileImage;
      }
      _isEditing = !_isEditing;
    });
  }

  List<Map<String, dynamic>> _getNavItems(UserNotifier userNotifier) {
    final baseItems = [
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
    ];
    if (!userNotifier.isProvider) {
      baseItems.add({
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      });
    }
    return baseItems;
  }

  void _onNavItemTapped(int index) {
    final navItems = _getNavItems(
      Provider.of<UserNotifier>(context, listen: false),
    );
    if (index >= navItems.length) return;

    final label = navItems[index]['label'];
    Widget? nextScreen;

    switch (label) {
      case 'Chat':
        nextScreen = const ChatScreen();
        break;
      case 'Bookings':
        nextScreen = const BookingsScreen();
        break;
      case 'Home':
        nextScreen = HomeScreen(themeNotifier: widget.themeNotifier);
        break;
    }

    if (nextScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final navItems = _getNavItems(userNotifier);

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
    final double whiteContainerTop = screenHeight * _whiteContainerHeightRatio;
    final double avatarTopPosition =
        whiteContainerTop - (_profileAvatarHeight / 2);
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildAjeerTitle(),
          _buildSwitchModeButton(context, isDarkMode, userNotifier),
          _buildMainContent(
            whiteContainerTop,
            bottomNavClearance,
            isDarkMode,
            userNotifier,
          ),
          _buildProfileAvatar(avatarTopPosition, isDarkMode),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        key: ValueKey(navItems.length),
        items: navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildDrawer() {
    return SettingsMenu(
      themeNotifier: widget.themeNotifier,
      onInfoTap: () => _showInfoDialog(context),
      onSignOutTap: () => _showSignOutDialog(context),
      notifications: _notifications,
      selectedNotifications: _selectedNotifications,
      isDeleting: _isDeleting,
      onToggleNotificationSelection: (i) {
        setState(() {
          _selectedNotifications.contains(i)
              ? _selectedNotifications.remove(i)
              : _selectedNotifications.add(i);
          _isDeleting = _selectedNotifications.isNotEmpty;
        });
      },
      onDeleteSelectedNotifications: () {
        setState(() {
          _notifications.removeWhere(
            (n) => _selectedNotifications.contains(_notifications.indexOf(n)),
          );
          _selectedNotifications.clear();
          _isDeleting = false;
        });
      },
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

  Widget _buildAjeerTitle() {
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
    final bool isSetupComplete = userNotifier.isProviderSetupComplete;

    String label = !isSetupComplete
        ? 'Become an Ajeer!'
        : (userNotifier.isProvider
              ? 'Switch to Customer Mode'
              : 'Switch to Provider Mode');
    IconData icon = !isSetupComplete
        ? Icons.rocket_launch
        : (userNotifier.isProvider ? Icons.person : Icons.handyman);

    return Positioned(
      top: buttonTop,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 260.0,
          child: ElevatedButton.icon(
            onPressed: () {
              if (!isSetupComplete) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(themeNotifier: widget.themeNotifier),
                  ),
                );
              } else {
                userNotifier.toggleUserMode();
              }
            },
            icon: Icon(icon, size: 20),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? _subtleDark : Colors.grey.shade300,
              foregroundColor: isDarkMode ? Colors.white : _primaryBlue,
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

  Widget _buildProfileAvatar(double topPosition, bool isDarkMode) {
    final String initial = _firstName.isNotEmpty
        ? _firstName[0].toUpperCase()
        : '?';
    return Positioned(
      top: topPosition,
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
                  backgroundColor: isDarkMode ? _darkBlue : _lightBlue,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? _lightBlue : _primaryBlue,
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
                      color: isDarkMode ? _subtleDark : Colors.white,
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

  Widget _buildMainContent(
    double top,
    double bottomPadding,
    bool isDarkMode,
    UserNotifier userNotifier,
  ) {
    final Color bgColor = isDarkMode ? _subtleDark : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
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
                  (_profileAvatarHeight / 2) + 10.0,
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
                            color: textColor,
                          ),
                    ),
                    _buildActionButtons(context, userNotifier),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomPadding + 20),
                  child: Column(
                    children: [
                      _buildTextField(
                        _firstNameController,
                        'First Name',
                        Icons.person_outline,
                        isDarkMode,
                      ),
                      _buildTextField(
                        _lastNameController,
                        'Last Name',
                        Icons.person_outline,
                        isDarkMode,
                      ),
                      _buildTextField(
                        _mobileController,
                        'Mobile Number',
                        Icons.call_outlined,
                        isDarkMode,
                        type: TextInputType.phone,
                      ),
                      _buildTextField(
                        _emailController,
                        'Email',
                        Icons.email_outlined,
                        isDarkMode,
                        type: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        _passwordController,
                        'Password',
                        Icons.lock_outline,
                        isDarkMode,
                        isPassword: true,
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

  Widget _buildActionButtons(BuildContext context, UserNotifier userNotifier) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isEditing) ...[
          _buildCircleButton(
            Icons.check,
            _dataHasChanged ? _saveGreen : Colors.grey,
            _dataHasChanged ? _saveProfile : null,
            'Save',
          ),
          const SizedBox(width: 10),
        ],
        _buildCircleButton(
          _isEditing ? Icons.close : Icons.edit,
          _isEditing ? _cancelRed : _primaryBlue,
          _toggleEditMode,
          _isEditing ? 'Cancel' : 'Edit',
        ),
        const SizedBox(width: 10),
        _buildCircleButton(
          Icons.settings,
          _primaryBlue,
          () => _scaffoldKey.currentState?.openDrawer(),
          'Settings',
        ),
      ],
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color color,
    VoidCallback? onTap,
    String tooltip,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isDarkMode, {
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    final Color textColor = _isEditing
        ? (isDarkMode ? Colors.white : Colors.black87)
        : Colors.grey.shade400;
    final Color fillColor = _isEditing
        ? (isDarkMode ? _subtleLighterDark : Colors.white)
        : (isDarkMode ? _subtleDark : Colors.grey.shade100);
    final Color borderColor = _isEditing
        ? (isDarkMode ? _editableBorderColorDark : Colors.grey.shade400)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        readOnly: !_isEditing,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: type,
        style: TextStyle(color: textColor),
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
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _primaryBlue, width: 3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: _primaryBlue),
            SizedBox(width: 10),
            Text('Ajeer Info'),
          ],
        ),
        content: const Text(
          'Ajeer connects customers with professional service providers for a seamless experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Sign Out',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // ✅ NEW: Clear Provider Data logic on Sign Out
              Provider.of<UserNotifier>(context, listen: false).clearData();

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentUser');
              await prefs.remove('authToken'); // Ensure token is removed too

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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

  const _ProviderInfoSection({
    required this.providerData,
    required this.isEnabled,
    required this.isDarkMode,
    required this.isEditing,
    required this.editableBorderColorDark,
    required this.subtleLighterDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isEnabled
        ? (isDarkMode ? Colors.white : Colors.black87)
        : Colors.grey;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                if (isEditing && isEnabled)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      fixedSize: const Size(30, 30),
                    ),
                    onPressed: () {
                      final providerData = Provider.of<UserNotifier>(
                        context,
                        listen: false,
                      ).providerData;
                      if (providerData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServicesScreen(
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
              ],
            ),
          ),
          _infoBox(
            'My Services',
            Icons.miscellaneous_services_outlined,
            providerData.services.isEmpty
                ? ['No services.']
                : providerData.services
                      .map(
                        (s) =>
                            '**${s.name}**: ${s.selectedUnitTypes.join(', ')}',
                      )
                      .toList(),
          ),
          _infoBox(
            'My Locations',
            Icons.location_on_outlined,
            providerData.selectedLocations.isEmpty
                ? ['No locations.']
                : providerData.selectedLocations
                      .map((l) => '**${l.city}**: ${l.areas.join(', ')}')
                      .toList(),
          ),
          _infoBox(
            'My Schedule',
            Icons.schedule_outlined,
            providerData.finalSchedule.isEmpty
                ? ['No schedule.']
                : providerData.finalSchedule
                      .map((s) => '${s.day}: ${s.timeSlots.join(', ')}')
                      .toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, IconData icon, List<String> content) {
    final bool readOnly = !isEnabled || !isEditing;
    final Color bgColor = readOnly
        ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100)
        : (isDarkMode ? subtleLighterDark : Colors.white);
    final Color borderColor = readOnly
        ? Colors.grey
        : (isDarkMode ? editableBorderColorDark : Colors.grey.shade400);
    final Color textColor = readOnly
        ? Colors.grey
        : (isDarkMode ? Colors.white70 : Colors.black87);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isEditing && isEnabled
                    ? const Color(0xFF1976D2)
                    : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...content.map(
            (line) => Text(
              line.replaceAll('**', ''),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
