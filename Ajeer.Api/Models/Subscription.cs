namespace Ajeer.Api.Models;

public class Subscription
{
    public int Id { get; set; }
    public int ServiceProviderId { get; set; }
    public decimal Price { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; }

    public ServiceProvider ServiceProvider { get; set; } = null!;
    public Payment? Payment { get; set; }
}