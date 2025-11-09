namespace Ajeer.Api.Models;

public class ProviderService
{
    public int ServiceProviderId { get; set; }
    public int ServiceId { get; set; }

    public ServiceProvider ServiceProvider { get; set; } = null!;
    public Service Service { get; set; } = null!;
}