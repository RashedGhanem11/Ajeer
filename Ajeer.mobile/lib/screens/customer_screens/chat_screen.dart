import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';
import '../shared_screens/profile_screen.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import '../../config/app_config.dart';

class _ChatConstants {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color subtleLighterDark = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const double navBarTotalHeight = 86.0;
  static const double logoHeight = 105.0;
  static const double borderRadius = 50.0;
  static const Color chatBackgroundColorLight = Color(0xFFF7F7F7);
  static const Color chatBackgroundColorDark = Color(0xFF1A1A1A);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService _chatService;
  Future<List<ChatConversation>>? _conversationsFuture;
  final int _selectedIndex = 1;
  String _searchQuery = '';
  List<ChatConversation>? _allConversations;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = _chatService.getConversations().then((data) {
        _allConversations = data;
        return data;
      });
    });
  }

  List<ChatConversation> _filterConversations(
    List<ChatConversation> conversations,
  ) {
    if (_searchQuery.isEmpty) return conversations;
    return conversations.where((chat) {
      return chat.otherSideName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
    final bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
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
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: whiteContainerTop + 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _ChatConstants.lightBlue,
                    _ChatConstants.primaryBlue,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Ajeer',
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
          ),
          Positioned(
            top: whiteContainerTop,
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                    child: FutureBuilder<List<ChatConversation>>(
                      future: _conversationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading chats',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No conversations found.',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey : Colors.grey,
                              ),
                            ),
                          );
                        }

                        final conversations = _filterConversations(
                          snapshot.data!,
                        );

                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: bottomNavClearance),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final chat = conversations[index];

                            return _ChatListItem(
                              chat: chat,
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      bookingId: chat.bookingId,
                                      otherSideName: chat.otherSideName,
                                      chatService: _chatService,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                ).then((_) => _loadConversations());
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: logoTopPosition,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                isDarkMode
                    ? 'assets/image/home_dark.png'
                    : 'assets/image/home.png',
                width: 140,
                height: _ChatConstants.logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: const [
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
          },
          {
            'label': 'Home',
            'icon': Icons.home_outlined,
            'activeIcon': Icons.home,
          },
        ],
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search chats...',
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
}

class _ChatListItem extends StatelessWidget {
  final ChatConversation chat;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl = chat.otherSideImageUrl;
    if (imageUrl != null) imageUrl = AppConfig.getFullImageUrl(imageUrl);

    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final bool isUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
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
              backgroundColor: Colors.blue.shade100,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Text(
                      chat.otherSideName.isNotEmpty
                          ? chat.otherSideName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.otherSideName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
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
                  chat.lastMessageFormattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread
                        ? _ChatConstants.primaryBlue
                        : subtitleColor,
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

class ChatDetailScreen extends StatefulWidget {
  final int bookingId;
  final String otherSideName;
  final ChatService chatService;
  final bool isDarkMode;

  const ChatDetailScreen({
    super.key,
    required this.bookingId,
    required this.otherSideName,
    required this.chatService,
    required this.isDarkMode,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  int? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    widget.chatService.initSignalR(
      onMessageReceived: _onNewMessageReceived,
      onMessageDeleted: _onMessageDeleted,
      onMessageRead: _onMessageRead,
    );
  }

  @override
  void dispose() {
    widget.chatService.disconnectSignalR();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNewMessageReceived(ChatMessage message) {
    if (mounted) {
      setState(() => _messages.add(message));
      _scrollToBottom();
    }
  }

  void _onMessageDeleted(int messageId) {
    if (mounted)
      setState(() => _messages.removeWhere((m) => m.id == messageId));
  }

  void _onMessageRead(int messageId) {
    if (mounted) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final old = _messages[index];
          _messages[index] = ChatMessage(
            id: old.id,
            content: old.content,
            formattedTime: old.formattedTime,
            sentAt: old.sentAt,
            isMine: old.isMine,
            isRead: true,
          );
        }
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await widget.chatService.getMessages(widget.bookingId);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    try {
      final sentMsg = await widget.chatService.sendMessage(
        widget.bookingId,
        text,
      );
      if (mounted) {
        setState(() => _messages.add(sentMsg));
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
    }
  }

  Future<void> _deleteMessage(int id) async {
    try {
      await widget.chatService.deleteMessage(id);
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == id);
          _selectedMessageId = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete message")));
    }
  }

  void _onMessageLongPress(ChatMessage message) {
    if (message.isMine) {
      setState(
        () => _selectedMessageId = (_selectedMessageId == message.id)
            ? null
            : message.id,
      );
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message copied!')));
    setState(() => _selectedMessageId = null);
  }

  @override
  Widget build(BuildContext context) {
    final chatBackgroundColor = widget.isDarkMode
        ? _ChatConstants.chatBackgroundColorDark
        : _ChatConstants.chatBackgroundColorLight;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.otherSideName,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: widget.isDarkMode ? Colors.white : Colors.black87,
        ),
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () => setState(() => _selectedMessageId = null),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: chatBackgroundColor,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _MessageBubble(
                            message: message,
                            isDarkMode: widget.isDarkMode,
                            isSelected: _selectedMessageId == message.id,
                            onTap: () =>
                                setState(() => _selectedMessageId = null),
                            onLongPress: () => _onMessageLongPress(message),
                            onCopy: () => _copyMessage(message.content),
                            onDelete: () => _deleteMessage(message.id),
                          );
                        },
                      ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    final Color inputFillColor = widget.isDarkMode
        ? _ChatConstants.subtleLighterDark
        : Colors.grey.shade100;
    final Color inputBorderColor = widget.isDarkMode
        ? _ChatConstants.darkBorder
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: inputBorderColor, width: 1.0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8.0),
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
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
                onSubmitted: (_) => _sendMessage(),
                minLines: 1,
                maxLines: 5,
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          IconButton(
            icon: const Icon(Icons.send, color: _ChatConstants.primaryBlue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _MessageBubble({
    required this.message,
    required this.isDarkMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMine;
    final Color bubbleColor = isMe
        ? _ChatConstants.primaryBlue
        : (isDarkMode ? _ChatConstants.subtleLighterDark : Colors.white);
    final Color textColor = isMe
        ? Colors.white
        : (isDarkMode ? Colors.white : Colors.black87);
    final Color timestampColor = isMe
        ? Colors.white70
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onCopy,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy,
                          size: 18,
                          color: isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
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
            GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Material(
                elevation: isSelected ? 4 : 1,
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.formattedTime,
                            style: TextStyle(
                              color: timestampColor,
                              fontSize: 10,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: message.isRead
                                  ? (isDarkMode
                                        ? Colors.lightBlueAccent
                                        : Colors.lightBlue.shade100)
                                  : timestampColor,
                            ),
                          ],
                        ],
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
