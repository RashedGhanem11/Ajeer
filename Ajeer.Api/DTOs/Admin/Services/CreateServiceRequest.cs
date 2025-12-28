namespace Ajeer.Api.DTOs.Admin.Services;

public class CreateServiceRequest
{
    public int CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal BasePrice { get; set; }
    public decimal EstimatedHours { get; set; }
    public bool IsActive { get; set; } = true;
}
