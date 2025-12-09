// service_area_models.dart

class AreaResponse {
  final int id;
  final String name;

  AreaResponse({required this.id, required this.name});

  factory AreaResponse.fromJson(Map<String, dynamic> json) {
    return AreaResponse(id: json['id'], name: json['name']);
  }
}

class CityResponse {
  final String cityName;
  final List<AreaResponse> areas;

  CityResponse({required this.cityName, required this.areas});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    var areasList = json['areas'] as List;
    List<AreaResponse> areasItems = areasList
        .map((i) => AreaResponse.fromJson(i))
        .toList();

    return CityResponse(cityName: json['cityName'], areas: areasItems);
  }
}
