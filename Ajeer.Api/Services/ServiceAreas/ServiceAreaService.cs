using Ajeer.Api.Data;
using Ajeer.Api.DTOs.ServiceAreas;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceAreas;

public class ServiceAreaService(AppDbContext _context) : IServiceAreaService
{
    public async Task<List<CityResponse>> GetAllServiceAreasAsync()
    {
        var areas = await _context.ServiceAreas
            .AsNoTracking()
            .OrderBy(a => a.CityName)
            .ThenBy(a => a.AreaName)
            .ToListAsync();

        var groupedAreas = areas
            .GroupBy(a => a.CityName)
            .Select(group => new CityResponse
            {
                CityName = group.Key,
                Areas = group.Select(a => new AreaResponse
                {
                    Id = a.Id,
                    Name = a.AreaName
                }).ToList()
            })
            .ToList();

        return groupedAreas;
    }
}