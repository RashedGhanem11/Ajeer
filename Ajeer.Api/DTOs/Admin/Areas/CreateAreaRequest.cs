namespace Ajeer.Api.DTOs.Admin.Areas;

public class CreateAreaRequest
{
    public string AreaName { get; set; } = string.Empty;
    public string CityName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}