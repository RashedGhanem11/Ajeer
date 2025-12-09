// attachment_models.dart

// 1. Mirror the FileType Enum
enum FileType { Image, Video, Audio }

// 2. Mirror the MimeType Enum
enum MimeType { Jpeg, Png, Webp, Mp4, Mov, Mp3, Wav, M4a, Other }

// 3. Mirror the AttachmentResponse DTO
class AttachmentResponse {
  final int id;
  final String url;
  final FileType fileType;
  final MimeType mimeType;

  AttachmentResponse({
    required this.id,
    required this.url,
    required this.fileType,
    required this.mimeType,
  });

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) {
    return AttachmentResponse(
      id: json['Id'] ?? 0,
      url: json['Url'] ?? '',
      // Parsing Enums (assuming backend returns Int or String, here handling String)
      fileType: FileType.values.firstWhere(
        (e) => e.toString().split('.').last == json['FileType'],
        orElse: () => FileType.Image,
      ),
      mimeType: MimeType.values.firstWhere(
        (e) => e.toString().split('.').last == json['MimeType'],
        orElse: () => MimeType.Other,
      ),
    );
  }
}
