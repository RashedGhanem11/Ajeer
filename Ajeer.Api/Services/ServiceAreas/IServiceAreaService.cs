using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.Models;
using Ajeer.Api.DTOs.Admin.Areas;

namespace Ajeer.Api.Services.ServiceAreas;

public interface IServiceAreaService
{
    Task<List<CityResponse>> GetAllServiceAreasAsync();

    Task<List<ServiceArea>> GetAdminAreasAsync();

    Task CreateAreaAsync(CreateAreaRequest area);

    Task UpdateAreaAsync(UpdateAreaRequest area);
}