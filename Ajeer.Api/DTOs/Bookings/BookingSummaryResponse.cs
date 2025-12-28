using Ajeer.Api.Enums;

namespace Ajeer.Api.DTOs.Bookings;

public class BookingSummaryResponse
{
    public int Id { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string ProviderName { get; set; } = string.Empty;
    public DateTime ScheduledDate { get; set; }
    public DateTime? CompletedDate { get; set; }
    public decimal EstimatedHours { get; set; }
    public decimal Amount { get; set; }
    public BookingStatus Status { get; set; }
}