namespace Ajeer.Api.Models;

public class Service
{
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public string Name { get; set; } = null!;
    public decimal BasePrice { get; set; }
    public decimal EstimatedHours { get; set; }
    public bool IsActive { get; set; } = true;

    public ServiceCategory Category { get; set; } = null!;
    public ICollection<ServiceProvider> ServiceProviders { get; set; } = new List<ServiceProvider>();
}