namespace Ajeer.Api.Models;

public class Review
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int UserId { get; set; }
    public int ServiceProviderId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; } = null!;
    public DateTime ReviewDate { get; set; }

    public Booking Booking { get; set; } = null!;
    public User User { get; set; } = null!;
    public ServiceProvider ServiceProvider { get; set; } = null!;
}