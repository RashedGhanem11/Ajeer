enum BookingStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
  inProgress,
  unknown,
}

class BookingListItem {
  final int id;
  final String otherSideName;
  final String? otherSideImageUrl;
  final String serviceName;
  final BookingStatus status;
  final bool hasReview;

  BookingListItem({
    required this.id,
    required this.otherSideName,
    this.otherSideImageUrl,
    required this.serviceName,
    required this.status,
    required this.hasReview,
  });

  factory BookingListItem.fromJson(Map<String, dynamic> json) {
    return BookingListItem(
      id: json['id'] ?? 0,
      otherSideName: json['otherSideName'] ?? 'Unknown',
      otherSideImageUrl: json['otherSideImageUrl'],
      serviceName: json['serviceName'] ?? 'Service',
      status: _parseStatus(json['status']),
      hasReview: json['hasReview'] ?? false,
    );
  }

  static BookingStatus _parseStatus(dynamic status) {
    if (status is int) {
      switch (status) {
        case 0:
          return BookingStatus.pending;
        case 1:
          return BookingStatus.accepted;
        case 2:
          return BookingStatus.rejected;
        case 3:
          return BookingStatus.cancelled;
        case 4:
          return BookingStatus.completed;
        default:
          return BookingStatus.unknown;
      }
    } else if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
          return BookingStatus.pending;
        case 'active':
          return BookingStatus.inProgress;
        case 'completed':
          return BookingStatus.completed;
        case 'cancelled':
          return BookingStatus.cancelled;
        case 'rejected':
          return BookingStatus.rejected;
        default:
          return BookingStatus.unknown;
      }
    }
    return BookingStatus.unknown;
  }
}

class BookingDetail {
  final int id;
  final BookingStatus status;
  final String serviceName;
  final String otherSideName;
  final String? otherSideImageUrl;
  final String otherSidePhone;
  final DateTime scheduledDate;
  final String address;
  final double latitude;
  final double longitude;
  final String? notes;
  final String formattedPrice;
  final String estimatedTime;
  final String areaName;
  final List<String> attachmentUrls;

  BookingDetail({
    required this.id,
    required this.status,
    required this.serviceName,
    required this.otherSideName,
    this.otherSideImageUrl,
    required this.otherSidePhone,
    required this.scheduledDate,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.notes,
    required this.formattedPrice,
    required this.estimatedTime,
    required this.areaName,
    required this.attachmentUrls,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime() {
      try {
        if (json['scheduledDate'] != null &&
            json['scheduledDate'].contains('T')) {
          return DateTime.parse(json['scheduledDate']);
        }

        String dateStr =
            json['scheduledDate'] ?? DateTime.now().toIso8601String();
        String timeStr = json['scheduledTime'] ?? '00:00:00';
        return DateTime.parse('${dateStr.split('T')[0]}T$timeStr');
      } catch (e) {
        return DateTime.now();
      }
    }

    return BookingDetail(
      id: json['id'] ?? 0,
      status: BookingListItem._parseStatus(json['status']),
      serviceName: json['serviceName'] ?? '',
      otherSideName: json['otherSideName'] ?? '',
      otherSideImageUrl: json['otherSideImageUrl'],
      otherSidePhone: json['otherSidePhone'] ?? '',
      scheduledDate: parseDateTime(),
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      notes: json['notes'],
      formattedPrice: json['formattedPrice'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
      areaName: json['areaName'] ?? '',
      attachmentUrls:
          (json['attachments'] as List<dynamic>?)
              ?.map((a) => a['url'] as String)
              .toList() ??
          [],
    );
  }
}
