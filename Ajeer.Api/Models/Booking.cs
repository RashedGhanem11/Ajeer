using Ajeer.Api.Enums;

namespace Ajeer.Api.Models;

public class Booking
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ServiceProviderId { get; set; }
    public int ServiceAreaId { get; set; }
    public BookingStatus Status { get; set; }
    public DateTime ScheduledDate { get; set; }
    public decimal EstimatedHours { get; set; }
    public decimal TotalAmount { get; set; }
    public string Address { get; set; } = null!;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
    public ServiceProvider ServiceProvider { get; set; } = null!;
    public ServiceArea ServiceArea { get; set; } = null!;
    public Review? Review { get; set; }

    public ICollection<BookingServiceItem> BookingServiceItems { get; set; } = new List<BookingServiceItem>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();
    public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}