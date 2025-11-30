using Ajeer.Api.Enums;

namespace Ajeer.Api.DTOs.Attachments;

public class AttachmentResponse
{
    public int Id { get; set; }
    public string Url { get; set; } = null!;
    public FileType FileType { get; set; }
    public MimeType MimeType { get; set; }
}