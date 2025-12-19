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

class ServiceItem {
  final int id;
  final String name;
  final String? formattedPrice;
  final String? estimatedTime;

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

  double get priceValue {
    if (formattedPrice == null) return 0.0;
    final cleaned = formattedPrice!.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  int get timeInMinutes {
    if (estimatedTime == null) return 0;
    String timeString = estimatedTime!.toLowerCase();

    double totalMinutes = 0.0;

    final hourMatch = RegExp(
      r'(\d+(\.\d+)?)\s*(?:h|hr|hour)',
    ).firstMatch(timeString);
    if (hourMatch != null) {
      double hours = double.tryParse(hourMatch.group(1) ?? '0') ?? 0.0;
      totalMinutes += hours * 60;
    }

    final minuteMatch = RegExp(r'(\d+)\s*(?:m|min)').firstMatch(timeString);
    if (minuteMatch != null) {
      double minutes = double.tryParse(minuteMatch.group(1) ?? '0') ?? 0.0;
      totalMinutes += minutes;
    }

    return totalMinutes.round();
  }
}
