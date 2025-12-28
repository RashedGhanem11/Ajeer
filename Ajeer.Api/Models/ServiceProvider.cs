namespace Ajeer.Api.Models;

public class ServiceProvider
{
    public int UserId { get; set; }
    public string? IdCardUrl { get; set; }
    public string? Bio { get; set; }
    public decimal Rating { get; set; }
    public int TotalReviews { get; set; }
    public bool IsVerified { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<ProviderService> ProviderServices { get; set; } = new List<ProviderService>();
    public ICollection<ProviderServiceArea> ProviderServiceAreas { get; set; } = new List<ProviderServiceArea>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<Schedule> Schedules { get; set; } = new List<Schedule>();
    public ICollection<Subscription> Subscriptions { get; set; } = new List<Subscription>();
    public ICollection<Service> Services { get; set; } = new List<Service>();
    public ICollection<ServiceArea> ServiceAreas { get; set; } = new List<ServiceArea>();
}