using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.DTOs.Services;

namespace Ajeer.Api.DTOs.ServiceProviders;

public class ProviderProfileResponse
{
    public string? Bio { get; set; }
    public decimal Rating { get; set; }
    public int TotalReviews { get; set; }
    public bool IsVerified { get; set; }
    public ServiceCategoryResponse? ServiceCategory { get; set; }
    public List<ServiceResponse> Services { get; set; } = new();
    public List<CityResponse> Cities { get; set; } = new();
    public List<WorkScheduleDto> Schedules { get; set; } = new();
}