// lib/models/service_models.dart

class ServiceCategory {
  // ... (existing code for ServiceCategory)
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

// NEW: Model for the unit types/services
class ServiceItem {
  final int id;
  final String name;
  final String? formattedPrice; // e.g., "15.00 JOD"
  final String? estimatedTime; // e.g., "60 mins"

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

  // Helper to extract int minutes from string (e.g., "60 mins" -> 60)
  int get timeInMinutes {
    if (estimatedTime == null) return 0;
    // Remove all non-digit characters
    final cleaned = estimatedTime!.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}
