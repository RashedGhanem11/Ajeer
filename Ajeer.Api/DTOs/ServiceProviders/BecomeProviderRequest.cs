namespace Ajeer.Api.DTOs.ServiceProviders;

public class BecomeProviderRequest
{
    public string? Bio { get; set; } = null!;
    public List<int> ServiceIds { get; set; } = new();
    public List<int> ServiceAreaIds { get; set; } = new();
    public List<WorkScheduleDto> Schedules { get; set; } = new();
    public IFormFile? IdCardImage { get; set; }
}