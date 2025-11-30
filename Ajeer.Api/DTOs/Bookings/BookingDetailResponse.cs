using Ajeer.Api.DTOs.Attachments;
using Ajeer.Api.DTOs.Bookings;

public class BookingDetailResponse : BookingListResponse
{
    public string OtherSidePhone { get; set; } = null!;
    public DateOnly ScheduledDate { get; set; }
    public TimeOnly ScheduledTime { get; set; }
    public string AreaName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string FormattedPrice { get; set; } = null!;
    public string EstimatedTime { get; set; } = null!;
    public string? Notes { get; set; }
    public List<AttachmentResponse> Attachments { get; set; } = new();
}