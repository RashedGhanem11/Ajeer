import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/customer_widgets/custom_bottom_nav_bar.dart';
import '../shared_screens/profile_screen.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';

// --- CHAT CONSTANTS ---
class _ChatConstants {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color subtleLighterDark = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const double navBarTotalHeight = 56.0 + 20.0 + 10.0;

  static const double logoHeight = 105.0;
  static const double borderRadius = 50.0;
  // New internal chat colors for better visual separation
  static const Color chatBackgroundColorLight = Color(0xFFF7F7F7);
  static const Color chatBackgroundColorDark = Color(0xFF1A1A1A);
}

class ChatScreen extends StatefulWidget {
  final String? initialProviderName;

  const ChatScreen({super.key, this.initialProviderName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final int _selectedIndex = 1; // Index 1 is for Chat
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock Chat data
  final List<Map<String, dynamic>> _allChats = [
    {
      'name': 'Fatima K.',
      'lastMessage': 'See you at 9 AM tomorrow.',
      'time': '9:15 PM',
      'unread': true,
      'providerName': 'Fatima K.',
      'messages': [
        {
          'text': 'Hello Fatima, when will you arrive?',
          'isUser': true,
          'id': 3,
          'timestamp': '9:15 PM',
        },
        {
          'text': 'See you at 9 AM tomorrow.',
          'isUser': false,
          'id': 4,
          'timestamp': '9:14 PM',
        },
      ],
    },
    {
      'name': 'Ahmad M.',
      'lastMessage': 'Sure, I will bring the tools.',
      'time': 'Yesterday',
      'unread': false,
      'providerName': 'Ahmad M.',
      'messages': [
        {
          'text': 'Do you have the spare parts?',
          'isUser': true,
          'id': 5,
          'timestamp': 'Yesterday',
        },
        {
          'text': 'Sure, I will bring the tools.',
          'isUser': false,
          'id': 6,
          'timestamp': 'Yesterday',
        },
      ],
    },
    {
      'name': 'Sara B.',
      'lastMessage': 'Okay, confirmed.',
      'time': 'Mon',
      'unread': false,
      'providerName': 'Sara B.',
      'messages': [
        {
          'text': 'Is 5 PM okay for the gardening job?',
          'isUser': true,
          'id': 7,
          'timestamp': 'Mon',
        },
        {
          'text': 'Okay, confirmed.',
          'isUser': false,
          'id': 8,
          'timestamp': 'Mon',
        },
      ],
    },
    {
      'name': 'Khalid S.',
      'lastMessage': 'Thank you for the excellent work!',
      'time': '2 weeks ago',
      'unread': false,
      'providerName': 'Khalid S.',
      'messages': [
        {
          'text': 'Job completed successfully.',
          'isUser': false,
          'id': 9,
          'timestamp': '2 weeks ago',
        },
        {
          'text': 'Thank code:Thank you for the excellent work!',
          'isUser': true,
          'id': 10,
          'timestamp': '2 weeks ago',
        },
      ],
    },
  ];

  // FIX: late keyword is kept, but initialization in initState is streamlined
  late List<Map<String, dynamic>> _filteredChats;

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
      'notificationCount': 3,
    },
    {
      'label': 'Bookings',
      'icon': Icons.book_outlined,
      'activeIcon': Icons.book,
    },
    {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
  ];

  @override
  void initState() {
    super.initState();
    // FIX APPLIED: Removed redundant initial assignment, relying only on _performSearch()
    // to initialize _filteredChats, which avoids the LateInitializationError.
    _performSearch();

    if (widget.initialProviderName != null) {
      _navigateToSpecificChat(widget.initialProviderName!);
    }
  }

  void _navigateToSpecificChat(String providerName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatData = _allChats.firstWhere(
        (chat) => chat['providerName'] == providerName,
        orElse: () => _allChats.first,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatData: chatData,
            isDarkMode: Provider.of<ThemeNotifier>(
              context,
              listen: false,
            ).isDarkMode,
          ),
        ),
      );
    });
  }

  void _performSearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredChats = List.from(_allChats);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredChats = _allChats
            .where(
              (chat) =>
                  (chat['name'] as String).toLowerCase().contains(query) ||
                  (chat['lastMessage'] as String).toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  void _deleteChat(Map<String, dynamic> chat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Delete Chat',
          style: TextStyle(color: _ChatConstants.primaryRed),
        ),
        content: Text(
          'Are you sure you want to delete the chat with ${chat['name']}? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _ChatConstants.primaryRed,
            ),
            onPressed: () {
              setState(() {
                _allChats.removeWhere(
                  (c) => c['providerName'] == chat['providerName'],
                );
                _performSearch();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  Widget _buildBackgroundGradient(double containerTop) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_ChatConstants.lightBlue, _ChatConstants.primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTitle(BuildContext context, bool isDarkMode) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            shadows: isDarkMode
                ? null
                : const [
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

  Widget _buildHomeImage(double logoTopPosition, bool isDarkMode) {
    final String imagePath = isDarkMode
        ? 'assets/image/home_dark.png'
        : 'assets/image/home.png';
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          imagePath,
          width: 140,
          height: _ChatConstants.logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _performSearch();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by provider name or message...',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDarkMode
            ? _ChatConstants.subtleLighterDark
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 8.0,
        ),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
    );
  }

  Widget _buildChatListContent(bool isDarkMode, double bottomNavClearance) {
    if (_filteredChats.isEmpty) {
      return Center(
        child: Text(
          'No chats found.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
          ),
        ),
      );
    }

    // Adjust padding to clear the bottom navigation bar
    final double finalBottomPadding = bottomNavClearance - 50;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: finalBottomPadding),
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];

        return _ChatListItem(
          name: chat['name'] as String,
          lastMessage: chat['lastMessage'] as String,
          time: chat['time'] as String,
          isUnread: chat['unread'] ?? false,
          isDarkMode: isDarkMode,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChatDetailScreen(chatData: chat, isDarkMode: isDarkMode),
              ),
            );
          },
          onLongPress: () => _deleteChat(chat),
        );
      },
    );
  }

  Widget _buildContentContainer({
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
            topLeft: Radius.circular(_ChatConstants.borderRadius),
            topRight: Radius.circular(_ChatConstants.borderRadius),
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
            const SizedBox(height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Conversations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSearchBar(isDarkMode),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: _buildChatListContent(isDarkMode, bottomNavClearance),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * 0.25;
    final double logoTopPosition =
        whiteContainerTop - _ChatConstants.logoHeight + 10.0;
    final double bottomNavClearance =
        _ChatConstants.navBarTotalHeight +
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildChatTitle(context, isDarkMode),
          _buildContentContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
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

// ----------------------------------------------------------------------
// CHAT LIST ITEM WIDGET
// ----------------------------------------------------------------------

class _ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatListItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isUnread,
    required this.isDarkMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Avatar Logic
    String letter = name.isNotEmpty && name.split(' ')[0].isNotEmpty
        ? name.split(' ')[0][0].toUpperCase()
        : '?';
    final int hash = letter.hashCode;
    final MaterialColor avatarBaseColor =
        Colors.primaries[hash % Colors.primaries.length];
    final Color avatarColor = isDarkMode
        ? avatarBaseColor.shade900
        : avatarBaseColor.shade100;
    final Color avatarLetterColor = isDarkMode
        ? avatarBaseColor.shade100
        : avatarBaseColor.shade700;

    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final Color timeColor = isUnread
        ? _ChatConstants.primaryBlue
        : subtitleColor;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isUnread && isDarkMode
              ? Colors.blue.withOpacity(0.1)
              : (isUnread ? Colors.blue.shade50 : Colors.transparent),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? _ChatConstants.darkBorder
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor,
              child: Text(
                letter,
                style: TextStyle(
                  color: avatarLetterColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? titleColor : subtitleColor,
                      fontWeight: isUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: timeColor,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: _ChatConstants.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// CHAT DETAIL SCREEN
// ----------------------------------------------------------------------

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final bool isDarkMode;

  const ChatDetailScreen({
    super.key,
    required this.chatData,
    required this.isDarkMode,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late List<Map<String, dynamic>> _messages;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.chatData['messages'] ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'id': DateTime.now().millisecondsSinceEpoch,
        'timestamp': 'Now', // Mock immediate timestamp
      });
      _messageController.clear();
      _selectedMessageId = null;
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onMessageLongPress(int id) {
    setState(() {
      if (_selectedMessageId == id) {
        _selectedMessageId = null;
      } else {
        _selectedMessageId = id;
      }
    });
  }

  void _onScreenTap() {
    if (_selectedMessageId != null) {
      setState(() {
        _selectedMessageId = null;
      });
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message copied!')));
    setState(() {
      _selectedMessageId = null;
    });
  }

  void _deleteMessage(int id) {
    setState(() {
      _messages.removeWhere((msg) => msg['id'] == id);
      _selectedMessageId = null;
    });
  }

  // Handle attachment menu
  void _showAttachmentOptions(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode
          ? _ChatConstants.subtleLighterDark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        final color = isDarkMode ? Colors.white : Colors.black87;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Send Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: _ChatConstants.primaryBlue,
                ),
                title: Text('Photo Gallery', style: TextStyle(color: color)),
                onTap: () {
                  Navigator.pop(bc);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Gallery... (Placeholder action)'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: _ChatConstants.primaryBlue,
                ),
                title: Text('Camera', style: TextStyle(color: color)),
                onTap: () {
                  Navigator.pop(bc);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Camera... (Placeholder action)'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: _ChatConstants.primaryBlue,
                ),
                title: Text('Location', style: TextStyle(color: color)),
                onTap: () {
                  Navigator.pop(bc);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sending Current Location... (Placeholder action)',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Handle audio recording
  void _startAudioRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording audio... Hold to record.')),
    );
  }

  // Call Simulation
  void _simulateCall(
    BuildContext context,
    String providerName,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? _ChatConstants.subtleLighterDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Calling $providerName...',
            style: const TextStyle(
              color: _ChatConstants.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_in_talk, size: 60, color: Colors.green),
            const SizedBox(height: 15),
            Text(
              'Connecting...',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(),
              icon: const Icon(Icons.call_end, color: Colors.white),
              label: const Text(
                'End Call',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ChatConstants.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to Provider Profile (Mock)
  void _navigateToProviderProfile(BuildContext context, String providerName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _MockProviderProfileScreen(
          providerName: providerName,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final String providerName = widget.chatData['name'] as String;

    // 2. Internal Chat Design: Subtle background color
    final chatBackgroundColor = isDarkMode
        ? _ChatConstants.chatBackgroundColorDark
        : _ChatConstants.chatBackgroundColorLight;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          providerName,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        elevation: 1,
        actions: [
          // Call Simulation Button
          IconButton(
            icon: Icon(
              Icons.call_outlined,
              color: isDarkMode ? Colors.white : Colors.black54,
            ),
            onPressed: () => _simulateCall(context, providerName, isDarkMode),
          ),
          // Navigate to Provider Profile Button
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white : Colors.black54,
            ),
            onPressed: () => _navigateToProviderProfile(context, providerName),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _onScreenTap, // Quick tap dismisses menu
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: chatBackgroundColor, // Applied subtle chat background
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final bool isUser = message['isUser'] as bool;
                    final bool isSelected = _selectedMessageId == message['id'];
                    final timestamp =
                        message['timestamp'] ?? '9:00 AM'; // Use mock timestamp

                    return _MessageBubble(
                      text: message['text'] as String,
                      timestamp: timestamp,
                      isUser: isUser,
                      isDarkMode: isDarkMode,
                      isSelected: isSelected,
                      onTap: _onScreenTap, // Quick tap dismisses
                      onLongPress: () => _onMessageLongPress(
                        message['id'] as int,
                      ), // Long press selects
                      onCopy: () => _copyMessage(message['text'] as String),
                      onDelete: () => _deleteMessage(message['id'] as int),
                    );
                  },
                ),
              ),
            ),
            // Message Composer Appearance
            _buildMessageComposer(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(bool isDarkMode) {
    final Color inputFillColor = isDarkMode
        ? _ChatConstants.subtleLighterDark
        : Colors.grey.shade100;
    final Color inputBorderColor = isDarkMode
        ? _ChatConstants.darkBorder
        : Colors.grey.shade300;
    final Color iconColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final Color primaryIconColor = _ChatConstants.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: inputBorderColor, width: 1.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. ➕ Attachment Button (Photo, Camera, Location)
          IconButton(
            icon: Icon(Icons.add, color: primaryIconColor, size: 28),
            onPressed: () => _showAttachmentOptions(context, isDarkMode),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8.0),

          // 2. Text Input Field (Framed and Bordered)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: inputBorderColor, width: 1.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(width: 4.0),

          // 3. Send / Microphone Button Toggle
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              bool hasText = value.text.trim().isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(left: 4.0),
                decoration: BoxDecoration(
                  color: hasText ? primaryIconColor : inputFillColor,
                  shape: BoxShape.circle,
                  border: hasText
                      ? null
                      : Border.all(color: inputBorderColor, width: 1.0),
                ),
                child: IconButton(
                  icon: Icon(
                    hasText ? Icons.send : Icons.mic,
                    color: hasText ? Colors.white : iconColor,
                  ),
                  onPressed: hasText ? _sendMessage : _startAudioRecording,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// MESSAGE BUBBLE WIDGET
// ----------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final String text;
  final String timestamp;
  final bool isUser;
  final bool isDarkMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _MessageBubble({
    required this.text,
    required this.timestamp,
    required this.isUser,
    required this.isDarkMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Internal Chat Design: Colors and BorderRadius
    final Color bubbleColor = isUser
        ? _ChatConstants.primaryBlue
        : (isDarkMode ? _ChatConstants.subtleLighterDark : Colors.white);
    final Color textColor = isUser
        ? Colors.white
        : (isDarkMode ? Colors.white : Colors.black87);
    final Color timestampColor = isUser
        ? Colors.white70
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    // Apply cleaner, rounder corners, with flat corner pointing towards the center of the screen
    final BorderRadius messageBorderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isUser
          ? const Radius.circular(4)
          : const Radius.circular(16),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Action Menu (moved above bubble for cleaner stacking if selected)
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(
                  top: 4.0,
                  bottom: 4.0,
                  right: isUser ? 10.0 : 0,
                  left: isUser ? 0 : 10.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onCopy,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy,
                          size: 18,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete,
                          size: 18,
                          color: _ChatConstants.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message Bubble Container
            GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress, // 1. Use long press for selection
              child: Material(
                elevation: isSelected ? 4 : 1, // Add subtle elevation/shadow
                shadowColor: isSelected
                    ? _ChatConstants.primaryRed.withOpacity(0.5)
                    : Colors.black12,
                borderRadius: messageBorderRadius,
                color: bubbleColor,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        text,
                        style: TextStyle(color: textColor, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timestamp, // Display timestamp
                        style: TextStyle(
                          color: timestampColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

// ----------------------------------------------------------------------
// MOCK PROVIDER PROFILE SCREEN
// ----------------------------------------------------------------------

class _MockProviderProfileScreen extends StatelessWidget {
  final String providerName;
  final bool isDarkMode;

  const _MockProviderProfileScreen({
    required this.providerName,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          '$providerName Profile',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_pin,
                size: 80,
                color: _ChatConstants.primaryBlue,
              ),
              const SizedBox(height: 20),
              Text(
                'This is the profile page for $providerName.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Here you would typically see ratings, services provided, reviews, and contact details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
