namespace Ajeer.Api.DTOs.ServiceAreas;

public class CityResponse
{
    public string CityName { get; set; } = null!;
    public List<AreaResponse> Areas { get; set; } = new();
}