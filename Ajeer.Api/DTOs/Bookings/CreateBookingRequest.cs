namespace Ajeer.Api.DTOs.Bookings;

public class CreateBookingRequest
{
    public List<int> ServiceIds { get; set; } = new();
    public int ServiceAreaId { get; set; }
    public DateTime ScheduledDate { get; set; }
    public string Address { get; set; } = null!;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? Notes { get; set; }

    public List<IFormFile>? Attachments { get; set; }
}