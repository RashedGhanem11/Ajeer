// ✅ UPDATED: provider_data.dart with 'services' getter for edit mode support

import 'package:flutter/material.dart';

class WorkTime {
  final TimeOfDay startTimeOfDay;
  final TimeOfDay endTimeOfDay;

  WorkTime({required this.startTimeOfDay, required this.endTimeOfDay});

  @override
  String toString() {
    String formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    return '${formatTime(startTimeOfDay)} - ${formatTime(endTimeOfDay)}';
  }
}

class WorkSchedule {
  final String day;
  final List<WorkTime> timeSlots;

  WorkSchedule({required this.day, required this.timeSlots});
}

class LocationSelection {
  final String city;
  final Set<String> areas;

  LocationSelection({required this.city, required this.areas});
}

class ProviderData {
  final Map<String, Set<String>> selectedServices;
  final List<LocationSelection> selectedLocations;
  final List<WorkSchedule> finalSchedule;

  ProviderData({
    required this.selectedServices,
    required this.selectedLocations,
    required this.finalSchedule,
  });

  /// ✅ NEW: Used to prefill services when editing
  List<ServiceSelection> get services => selectedServices.entries
      .map(
        (entry) => ServiceSelection(
          name: entry.key,
          selectedUnitTypes: entry.value.toList(),
        ),
      )
      .toList();
}

class ServiceSelection {
  final String name;
  final List<String> selectedUnitTypes;

  ServiceSelection({required this.name, required this.selectedUnitTypes});
}
