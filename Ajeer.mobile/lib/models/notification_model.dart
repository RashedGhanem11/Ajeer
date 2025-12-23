class NotificationModel {
  final int id;
  final String title;
  final String message;
  final int type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // Safely parse ID even if it comes as a String "123"
      id: _toInt(json['id']),

      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',

      // Safely parse Type even if it comes as a String "1"
      type: _toInt(json['type']),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),

      isRead: json['isRead'] == true || json['isRead'] == 'true',
    );
  }

  // Helper to force conversion to int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
