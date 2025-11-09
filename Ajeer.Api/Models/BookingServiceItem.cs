namespace Ajeer.Api.Models;

public class BookingServiceItem
{
    public int Id { get; set; }
    public int ServiceId { get; set; }
    public int BookingId { get; set; }
    public decimal PriceAtBooking { get; set; }

    public Service Service { get; set; } = null!;
    public Booking Booking { get; set; } = null!;

}