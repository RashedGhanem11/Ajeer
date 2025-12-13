// lib/models/service_models.dart

class ServiceCategory {
  final int id;
  final String name;
  final String iconUrl;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
    );
  }
}

// Model for the unit types/services
class ServiceItem {
  final int id;
  final String name;
  final String? formattedPrice; // e.g., "15.00 JOD"
  final String? estimatedTime; // e.g., "60 mins", "1 hr 30 mins"

  ServiceItem({
    required this.id,
    required this.name,
    this.formattedPrice,
    this.estimatedTime,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int,
      name: json['name'] as String,
      formattedPrice: json['formattedPrice'] as String?,
      estimatedTime: json['estimatedTime'] as String?,
    );
  }

  // Helper to extract double from string (e.g., "15.00 JOD" -> 15.0)
  double get priceValue {
    if (formattedPrice == null) return 0.0;
    // Remove all non-digit characters except the decimal point
    final cleaned = formattedPrice!.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  // --- FIXED TIME CALCULATION LOGIC ---
  // This now handles "2 hrs", "1 hr 30 mins", and "45 mins" correctly.
  int get timeInMinutes {
    if (estimatedTime == null) return 0;
    String timeString = estimatedTime!.toLowerCase();

    double totalMinutes = 0.0;

    // 1. Look for Hours (matches "1.5 hrs", "2 hours", "1 hr")
    // Regex finds a number followed immediately or loosely by 'h' or 'hr'
    final hourMatch = RegExp(
      r'(\d+(\.\d+)?)\s*(?:h|hr|hour)',
    ).firstMatch(timeString);
    if (hourMatch != null) {
      // Group 1 captures the number part (e.g., "1.5" or "2")
      double hours = double.tryParse(hourMatch.group(1) ?? '0') ?? 0.0;
      totalMinutes += hours * 60;
    }

    // 2. Look for Minutes (matches "30 mins", "45 min")
    // Regex finds a number followed immediately or loosely by 'm' or 'min'
    final minuteMatch = RegExp(r'(\d+)\s*(?:m|min)').firstMatch(timeString);
    if (minuteMatch != null) {
      // Group 1 captures the integer minutes
      double minutes = double.tryParse(minuteMatch.group(1) ?? '0') ?? 0.0;
      totalMinutes += minutes;
    }

    return totalMinutes.round();
  }
}
