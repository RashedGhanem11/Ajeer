class AppConfig {
//192.168.100.20
  static const String baseUrl = 'http://localhost:5289';
  static const String apiUrl = '$baseUrl/api';
  static const String hubUrl = '$baseUrl/hubs/chat';

  static String getFullImageUrl(String? relativePath)
  {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;

    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$baseUrl$path';
  }
}