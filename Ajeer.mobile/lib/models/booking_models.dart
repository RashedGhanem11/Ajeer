import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  rejected,
}

class BookingListItem {
  final int id;
  final String otherSideName;
  final String? otherSideImageUrl;
  final String serviceName;
  final BookingStatus status;

  BookingListItem({
    required this.id,
    required this.otherSideName,
    this.otherSideImageUrl,
    required this.serviceName,
    required this.status,
  });

  factory BookingListItem.fromJson(Map<String, dynamic> json) {
    // Helper to safely get value regardless of casing (Id vs id)
    dynamic getVal(String key) =>
        json[key] ?? json[key[0].toUpperCase() + key.substring(1)];

    return BookingListItem(
      id: getVal('id') ?? 0, // Fallback to 0 if ID is missing to prevent crash
      otherSideName: getVal('otherSideName') ?? 'Unknown Provider',
      otherSideImageUrl: getVal('otherSideImageUrl'),
      serviceName: getVal('serviceName') ?? 'Service',
      status: _parseStatus(getVal('status')),
    );
  }

  static BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;

    if (status is int) {
      return BookingStatus.values.length > status
          ? BookingStatus.values[status]
          : BookingStatus.pending;
    }

    if (status is String) {
      final String lowerStatus = status.toLowerCase();
      if (lowerStatus == 'active') return BookingStatus.accepted;

      return BookingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == lowerStatus,
        orElse: () => BookingStatus.pending,
      );
    }
    return BookingStatus.pending;
  }
}

class BookingDetail extends BookingListItem {
  final String otherSidePhone;
  final DateTime scheduledDate;
  final String areaName;
  final String address;
  final double latitude;
  final double longitude;
  final String formattedPrice;
  final String estimatedTime;
  final String? notes;
  final List<String> attachmentUrls;

  BookingDetail({
    required super.id,
    required super.otherSideName,
    super.otherSideImageUrl,
    required super.serviceName,
    required super.status,
    required this.otherSidePhone,
    required this.scheduledDate,
    required this.areaName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.formattedPrice,
    required this.estimatedTime,
    this.notes,
    required this.attachmentUrls,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    // Helper to safely get value regardless of casing
    dynamic getVal(String key) =>
        json[key] ?? json[key[0].toUpperCase() + key.substring(1)];

    DateTime date = DateTime.now();
    try {
      final dateStr = getVal('scheduledDate');
      if (dateStr != null) {
        date = DateTime.parse(dateStr);
      }
    } catch (_) {}

    return BookingDetail(
      id: getVal('id') ?? 0,
      otherSideName: getVal('otherSideName') ?? 'Unknown',
      otherSideImageUrl: getVal('otherSideImageUrl'),
      serviceName: getVal('serviceName') ?? 'Service',
      status: BookingListItem._parseStatus(getVal('status')),
      otherSidePhone: getVal('otherSidePhone') ?? '',
      scheduledDate: date,
      areaName: getVal('areaName') ?? '',
      address: getVal('address') ?? '',
      latitude: (getVal('latitude') as num?)?.toDouble() ?? 0.0,
      longitude: (getVal('longitude') as num?)?.toDouble() ?? 0.0,
      formattedPrice: getVal('formattedPrice')?.toString() ?? '0.00',
      estimatedTime: getVal('estimatedTime')?.toString() ?? '',
      notes: getVal('notes'),
      attachmentUrls:
          (getVal('attachments') as List?)?.map((e) {
            // Handle if attachment is an object {url: "..."} or just a string
            if (e is Map) return (e['url'] ?? e['Url'] ?? '').toString();
            return e.toString();
          }).toList() ??
          [],
    );
  }
}
