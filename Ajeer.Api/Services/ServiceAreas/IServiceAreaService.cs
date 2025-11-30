using Ajeer.Api.DTOs.ServiceAreas;

namespace Ajeer.Api.Services.ServiceAreas;

public interface IServiceAreaService
{
    Task<List<CityResponse>> GetAllServiceAreasAsync();
}