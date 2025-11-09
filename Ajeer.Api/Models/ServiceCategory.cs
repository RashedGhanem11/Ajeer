namespace Ajeer.Api.Models;

public class ServiceCategory
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string IconUrl { get; set; } = null!;

    public ICollection<Service> Services { get; set; } = new List<Service>();
}