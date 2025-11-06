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

  Map<String, dynamic> toJson() => {
    'startHour': startTimeOfDay.hour,
    'startMinute': startTimeOfDay.minute,
    'endHour': endTimeOfDay.hour,
    'endMinute': endTimeOfDay.minute,
  };

  factory WorkTime.fromJson(Map<String, dynamic> json) => WorkTime(
    startTimeOfDay: TimeOfDay(
      hour: json['startHour'],
      minute: json['startMinute'],
    ),
    endTimeOfDay: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
  );
}

class WorkSchedule {
  final String day;
  final List<WorkTime> timeSlots;

  WorkSchedule({required this.day, required this.timeSlots});

  Map<String, dynamic> toJson() => {
    'day': day,
    'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
  };

  factory WorkSchedule.fromJson(Map<String, dynamic> json) => WorkSchedule(
    day: json['day'],
    timeSlots: (json['timeSlots'] as List)
        .map((t) => WorkTime.fromJson(t))
        .toList(),
  );
}

class LocationSelection {
  final String city;
  final Set<String> areas;

  LocationSelection({required this.city, required this.areas});

  Map<String, dynamic> toJson() => {'city': city, 'areas': areas.toList()};

  factory LocationSelection.fromJson(Map<String, dynamic> json) =>
      LocationSelection(
        city: json['city'],
        areas: Set<String>.from(json['areas']),
      );
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

  /// ✅ Used to prefill services when editing
  List<ServiceSelection> get services => selectedServices.entries
      .map(
        (entry) => ServiceSelection(
          name: entry.key,
          selectedUnitTypes: entry.value.toList(),
        ),
      )
      .toList();

  /// ✅ Save to JSON
  Map<String, dynamic> toJson() => {
    'selectedServices': selectedServices.map(
      (key, value) => MapEntry(key, value.toList()),
    ),
    'selectedLocations': selectedLocations.map((loc) => loc.toJson()).toList(),
    'finalSchedule': finalSchedule.map((s) => s.toJson()).toList(),
  };

  /// ✅ Load from JSON
  factory ProviderData.fromJson(Map<String, dynamic> json) => ProviderData(
    selectedServices: Map<String, Set<String>>.fromEntries(
      (json['selectedServices'] as Map<String, dynamic>).entries.map(
        (e) => MapEntry(e.key, Set<String>.from(e.value)),
      ),
    ),
    selectedLocations: (json['selectedLocations'] as List)
        .map((loc) => LocationSelection.fromJson(loc))
        .toList(),
    finalSchedule: (json['finalSchedule'] as List)
        .map((s) => WorkSchedule.fromJson(s))
        .toList(),
  );
}

class ServiceSelection {
  final String name;
  final List<String> selectedUnitTypes;

  ServiceSelection({required this.name, required this.selectedUnitTypes});
}
