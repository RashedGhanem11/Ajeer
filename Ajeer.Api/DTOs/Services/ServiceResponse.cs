namespace Ajeer.Api.DTOs.Services;

public class ServiceResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string FormattedPrice { get; set; } = null!;
    public string EstimatedTime { get; set; } = null!;
}