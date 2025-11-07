// lib/models/booking.dart

import 'dart:io';
import 'package:flutter/material.dart';

class Booking {
  final String provider;
  final String phone;
  final String location;
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final String? userDescription;
  final List<File>? uploadedFiles;
  final int totalTimeMinutes;
  final double totalPrice;

  Booking({
    required this.provider,
    required this.phone,
    required this.location,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    this.userDescription,
    this.uploadedFiles,
    required this.totalTimeMinutes,
    required this.totalPrice,
  });
}
