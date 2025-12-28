using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Admin.Areas;
using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceAreas;

public class ServiceAreaService(AppDbContext _context) : IServiceAreaService
{
    public async Task<List<CityResponse>> GetAllServiceAreasAsync()
    {
        var areas = await _context.ServiceAreas
            .AsNoTracking()
            .Where(a => a.IsActive)
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

    public async Task<List<ServiceArea>> GetAdminAreasAsync()
    {
        return await _context.ServiceAreas
            .AsNoTracking()
            .OrderBy(a => a.CityName)
            .ThenBy(a => a.AreaName)
            .ToListAsync();
    }

    public async Task CreateAreaAsync(CreateAreaRequest request)
    {
        var area = new ServiceArea
        {
            AreaName = request.AreaName,
            CityName = request.CityName,
            IsActive = request.IsActive
        };
        _context.ServiceAreas.Add(area);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAreaAsync(UpdateAreaRequest request)
    {
        var existing = await _context.ServiceAreas.FindAsync(request.Id);
        if (existing == null) throw new Exception("Area not found");

        existing.AreaName = request.AreaName;
        existing.CityName = request.CityName;
        existing.IsActive = request.IsActive;

        await _context.SaveChangesAsync();
    }

    private List<CityResponse> GroupAreas(List<ServiceArea> areas)
    {
        return areas
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
    }
}