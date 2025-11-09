namespace Ajeer.Api.Models;

public class ProviderServiceArea
{
    public int ServiceProviderId { get; set; }
    public int ServiceAreaId { get; set; }

    public ServiceProvider ServiceProvider { get; set; } = null!;
    public ServiceArea ServiceArea { get; set; } = null!;
}