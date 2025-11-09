namespace Ajeer.Api.Models;

public class Message
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int SenderId { get; set; }
    public int ReceiverId { get; set; }
    public string Content { get; set; } = null!;
    public DateTime SentAt { get; set; } = DateTime.Now;
    public bool IsRead { get; set; } = false;

    public User Sender { get; set; } = null!;
    public User Receiver { get; set; } = null!;
    public Booking Booking { get; set; } = null!;
}