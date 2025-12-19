import 'package:flutter/material.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

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
      hour: _toInt(json['startHour']),
      minute: _toInt(json['startMinute']),
    ),
    endTimeOfDay: TimeOfDay(
      hour: _toInt(json['endHour']),
      minute: _toInt(json['endMinute']),
    ),
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

  List<Map<String, dynamic>> toApiDto() {
    int getDayOfWeek(String dayName) {
      const days = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
      return days.indexOf(dayName);
    }

    return timeSlots.map((slot) {
      final start =
          "${slot.startTimeOfDay.hour.toString().padLeft(2, '0')}:${slot.startTimeOfDay.minute.toString().padLeft(2, '0')}:00";
      final end =
          "${slot.endTimeOfDay.hour.toString().padLeft(2, '0')}:${slot.endTimeOfDay.minute.toString().padLeft(2, '0')}:00";

      return {
        "dayOfWeek": getDayOfWeek(day),
        "startTime": start,
        "endTime": end,
      };
    }).toList();
  }
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
  final List<int> _serviceIds;
  final List<int> _areaIds;

  ProviderData({
    required this.selectedServices,
    required this.selectedLocations,
    required this.finalSchedule,
    List<int>? serviceIds,
    List<int>? areaIds,
  }) : _serviceIds = serviceIds ?? [],
       _areaIds = areaIds ?? [];

  List<int> getAllServiceIds() => _serviceIds;
  List<int> getAllAreaIds() => _areaIds;

  List<ServiceSelection> get services => selectedServices.entries
      .map(
        (entry) => ServiceSelection(
          name: entry.key,
          selectedUnitTypes: entry.value.toList(),
        ),
      )
      .toList();

  Map<String, dynamic> toJson() => {
    'selectedServices': selectedServices.map(
      (key, value) => MapEntry(key, value.toList()),
    ),
    'selectedLocations': selectedLocations.map((loc) => loc.toJson()).toList(),
    'finalSchedule': finalSchedule.map((s) => s.toJson()).toList(),
  };

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

  factory ProviderData.fromApi(Map<String, dynamic> json) {
    try {
      Map<String, Set<String>> servicesMap = {};
      List<int> sIds = [];
      if (json['serviceCategory'] != null) {
        String catName = json['serviceCategory']['name'] ?? 'Service';
        Set<String> types = {};
        var servicesList = json['services'] as List?;
        if (servicesList != null) {
          for (var s in servicesList) {
            if (s['name'] != null) types.add(s['name']);
            if (s['id'] != null) sIds.add(_toInt(s['id']));
          }
        }
        servicesMap[catName] = types;
      }
      List<LocationSelection> locs = [];
      List<int> aIds = [];
      var citiesList = json['cities'] as List?;
      if (citiesList != null) {
        for (var c in citiesList) {
          Set<String> areaNames = {};
          var areasList = c['areas'] as List?;
          if (areasList != null) {
            for (var a in areasList) {
              if (a['name'] != null) areaNames.add(a['name']);
              if (a['id'] != null) aIds.add(_toInt(a['id']));
            }
          }
          locs.add(
            LocationSelection(
              city: c['cityName'] ?? 'Unknown',
              areas: areaNames,
            ),
          );
        }
      }
      List<WorkSchedule> schedules = [];
      var schedList = json['schedules'] as List?;

      if (schedList != null) {
        Map<int, List<WorkTime>> grouped = {};
        const days = [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
        ];

        for (var s in schedList) {
          var dayVal =
              s['dayOfWeek'] ??
              s['DayOfWeek'] ??
              s['day'] ??
              s['day_of_week'] ??
              s['dow'];

          if (dayVal == null) {
            print('Warning: No day key found in schedule item: $s');
            continue;
          }
          int dayIndex = 0;
          if (dayVal is int) {
            dayIndex = dayVal;
          } else if (dayVal is String) {
            int? parsed = int.tryParse(dayVal);
            if (parsed != null) {
              dayIndex = parsed;
            } else {
              int nameIndex = days.indexWhere(
                (d) => d.toLowerCase() == dayVal.toLowerCase(),
              );
              if (nameIndex != -1) {
                dayIndex = nameIndex;
              }
            }
          }
          TimeOfDay parseTime(String? t) {
            if (t == null || !t.contains(':'))
              return const TimeOfDay(hour: 0, minute: 0);
            try {
              final parts = t.split(':');
              return TimeOfDay(
                hour: _toInt(parts[0]),
                minute: _toInt(parts[1]),
              );
            } catch (e) {
              return const TimeOfDay(hour: 0, minute: 0);
            }
          }

          final startTimeStr = s['startTime'] ?? s['StartTime'];
          final endTimeStr = s['endTime'] ?? s['EndTime'];

          final slot = WorkTime(
            startTimeOfDay: parseTime(startTimeStr),
            endTimeOfDay: parseTime(endTimeStr),
          );

          if (!grouped.containsKey(dayIndex)) {
            grouped[dayIndex] = [];
          }
          grouped[dayIndex]!.add(slot);
        }
        grouped.forEach((dayIndex, slots) {
          if (dayIndex >= 0 && dayIndex < days.length) {
            schedules.add(WorkSchedule(day: days[dayIndex], timeSlots: slots));
          }
        });
      }

      return ProviderData(
        selectedServices: servicesMap,
        selectedLocations: locs,
        finalSchedule: schedules,
        serviceIds: sIds,
        areaIds: aIds,
      );
    } catch (e) {
      debugPrint("Error parsing ProviderData: $e");
      return ProviderData(
        selectedServices: {},
        selectedLocations: [],
        finalSchedule: [],
      );
    }
  }
}

class ServiceSelection {
  final String name;
  final List<String> selectedUnitTypes;

  ServiceSelection({required this.name, required this.selectedUnitTypes});
}
