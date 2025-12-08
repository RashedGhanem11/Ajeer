class ChatConversation {
  final int bookingId;
  final String otherSideName;
  final String? otherSideImageUrl;
  final String lastMessage;
  final String lastMessageFormattedTime;
  final int unreadCount;

  ChatConversation({
    required this.bookingId,
    required this.otherSideName,
    this.otherSideImageUrl,
    required this.lastMessage,
    required this.lastMessageFormattedTime,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      bookingId: json['bookingId'],
      otherSideName: json['otherSideName'] ?? 'Unknown',
      otherSideImageUrl: json['otherSideImageUrl'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageFormattedTime: json['lastMessageFormattedTime'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final String content;
  final DateTime sentAt;
  final String formattedTime;
  final bool isMine;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.formattedTime,
    required this.isMine,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'] ?? '',
      sentAt: json['sentAt'] != null
        ? DateTime.parse(json['sentAt'])
        : DateTime.now(),
      formattedTime: json['formattedTime'] ?? '',
      isMine: json['isMine'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }
}