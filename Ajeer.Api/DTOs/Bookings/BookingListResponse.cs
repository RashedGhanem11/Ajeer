using Ajeer.Api.Enums;

namespace Ajeer.Api.DTOs.Bookings;

public class BookingListResponse
{
    public int Id { get; set; }
    public string OtherSideName { get; set; } = null!;
    public string? OtherSideImageUrl { get; set; }
    public string ServiceName { get; set; } = null!;
    public BookingStatus Status { get; set; }
    public bool HasReview { get; set; }
}