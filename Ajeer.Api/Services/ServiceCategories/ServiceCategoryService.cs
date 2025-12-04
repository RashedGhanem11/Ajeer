using Ajeer.Api.Data;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.Services.Files;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceCategories;

public class ServiceCategoryService(AppDbContext _context, IFileService _fileService) : IServiceCategoryService
{
    public async Task<List<ServiceCategoryResponse>> GetAllCategoriesAsync()
    {
        var categories = await _context.ServiceCategories
            .OrderBy(c => c.Name)
            .ToListAsync();

        var response = categories.Select(c => new ServiceCategoryResponse
        {
            Id = c.Id,
            Name = c.Name,
            IconUrl = _fileService.GetPublicUrl("categories", c.IconUrl)!
        }).ToList();

        return response;
    }
}