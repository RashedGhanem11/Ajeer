import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 FIX 1: Import Provider package
import '../../themes/theme_notifier.dart'; // 💡 FIX 2: Import ThemeNotifier definition
import '../../widgets/customer_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import '../shared_screens/profile_screen.dart';
// Removed: import '../../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 1;

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

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    // 💡 FIX 3: Retrieve themeNotifier using Provider (listen: false for navigation)
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // FIX: Pass themeNotifier to ProfileScreen
            builder: (context) => ProfileScreen(themeNotifier: themeNotifier),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: const Center(child: Text('Chat Screen Content')),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }
}
