using Ajeer.Api.Enums;

namespace Ajeer.Api.Models;

public class Notification
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int? BookingId { get; set; }
    public string Title { get; set; } = null!;
    public NotificationType Type { get; set; }
    public string Message { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public bool IsRead { get; set; } = false;

    public User User { get; set; } = null!;
    public Booking? Booking { get; set; }
}