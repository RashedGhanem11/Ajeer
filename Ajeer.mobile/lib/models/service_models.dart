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
