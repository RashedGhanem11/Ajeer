using Ajeer.Api.Enums;

namespace Ajeer.Api.Models;

public class Attachment
{
    public int Id { get; set; }
    public int? BookingId { get; set; }
    public int UploaderId { get; set; }
    public string FileUrl { get; set; } = null!;
    public MimeType MimeType { get; set; }
    public FileType FileType { get; set; }

    public Booking? Booking { get; set; }
    public User Uploader { get; set; } = null!;
}