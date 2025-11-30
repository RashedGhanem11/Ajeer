namespace Ajeer.Api.Models;

public class ServiceArea
{
    public int Id { get; set; }
    public string AreaName { get; set; } = null!;
    public string CityName { get; set; } = null!;

    public ICollection<ServiceProvider> ServiceProviders { get; set; } = new List<ServiceProvider>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}