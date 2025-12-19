enum FileType { Image, Video, Audio }

enum MimeType { Jpeg, Png, Webp, Mp4, Mov, Mp3, Wav, M4a, Other }

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
