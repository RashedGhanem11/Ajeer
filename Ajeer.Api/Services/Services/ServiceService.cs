using System.Globalization;
using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Admin.Services;
using Ajeer.Api.DTOs.Services;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Formatting;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Services;

public class ServiceService(AppDbContext _context, IFormattingService _formattingService) : IServiceService
{
    public async Task<List<ServiceResponse>> GetServicesByCategoryIdAsync(int categoryId)
    {
        var services = await _context.Services
            .Where(s => s.CategoryId == categoryId && s.IsActive)
            .OrderBy(s => s.Name)
            .ToListAsync();

        var response = services.Select(s => new ServiceResponse
        {
            Id = s.Id,
            Name = s.Name,
            FormattedPrice = _formattingService.FormatCurrency(s.BasePrice),
            EstimatedTime = _formattingService.FormatEstimatedTime(s.EstimatedHours)
        }).ToList();

        return response;
    }

    public async Task CreateServiceAsync(CreateServiceRequest dto)
    {
        var service = new Service
        {
            Name = dto.Name,
            CategoryId = dto.CategoryId,
            BasePrice = dto.BasePrice,
            EstimatedHours = dto.EstimatedHours,
            IsActive = dto.IsActive
        };
        _context.Services.Add(service);
        await _context.SaveChangesAsync();
}

    public async Task UpdateServiceAsync(UpdateServiceRequest dto)
    {
        var existing = await _context.Services.FindAsync(dto.Id);
        if (existing == null) throw new Exception("Service not found");

        existing.Name = dto.Name;
        existing.CategoryId = dto.CategoryId;
        existing.BasePrice = dto.BasePrice;
        existing.EstimatedHours = dto.EstimatedHours;
        existing.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();
    }
}