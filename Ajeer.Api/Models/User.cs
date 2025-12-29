using System.ComponentModel.DataAnnotations;
using Ajeer.Api.Enums;

namespace Ajeer.Api.Models;

public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string Password { get; set; } = null!;
    public bool IsActive { get; set; } = true;
    public UserRole Role { get; set; }
    public string? ProfilePictureUrl { get; set; }
    public DateTime LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsEmailVerified { get; set; } = false;
    public string? VerificationToken { get; set; }

    public ServiceProvider? ServiceProvider { get; set; }
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<Message> SentMessages { get; set; } = new List<Message>();
    public ICollection<Message> ReceivedMessages { get; set; } = new List<Message>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}