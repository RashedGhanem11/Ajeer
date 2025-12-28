using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Admin.Services;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Files;
using Microsoft.EntityFrameworkCore;
using MudBlazor.Extensions;

namespace Ajeer.Api.Services.ServiceCategories;

public class ServiceCategoryService(AppDbContext _context, IFileService _fileService) : IServiceCategoryService
{
    public async Task<List<ServiceCategoryResponse>> GetAllCategoriesAsync()
    {
        var categories = await _context.ServiceCategories
            .AsNoTracking()
            .Where(c => c.IsActive)
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

    public async Task<List<ServiceCategory>> GetAdminCategoriesAsync()
    {
        return await _context.ServiceCategories
            .Include(c => c.Services)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task CreateCategoryAsync(CreateCategoryRequest dto, Stream? iconStream, string? fileName)
    {
        var category = new ServiceCategory
        {
            Name = dto.Name,
            Description = dto.Description,
            IsActive = dto.IsActive
        };

        if (iconStream != null && !string.IsNullOrEmpty(fileName))
        {
            category.IconUrl = await _fileService.SaveFileAsync(iconStream, fileName, "categories") 
                            ?? throw new Exception("Failed to save icon");
        }

        _context.ServiceCategories.Add(category);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateCategoryAsync(UpdateCategoryRequest dto, Stream? iconStream, string? fileName)
    {
        var existing = await _context.ServiceCategories.FindAsync(dto.Id);
        if (existing == null) throw new Exception("Category not found");

        existing.Name = dto.Name;
        existing.Description = dto.Description;
        existing.IsActive = dto.IsActive;

        if (iconStream != null && !string.IsNullOrEmpty(fileName))
        {
            string? oldIconUrl = existing.IconUrl;

            existing.IconUrl = await _fileService.SaveFileAsync(iconStream, fileName, "categories")
                            ?? throw new Exception("Failed to save icon");

            if (!string.IsNullOrEmpty(oldIconUrl))
                _fileService.DeleteFile("categories", oldIconUrl);
        }

        await _context.SaveChangesAsync();
    }
}