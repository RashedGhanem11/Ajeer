using System.Globalization;
using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Services;
using Ajeer.Api.Services.Formatting;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Services;

public class ServiceService(AppDbContext _context, IFormattingService _formattingService) : IServiceService
{
    public async Task<List<ServiceResponse>> GetServicesByCategoryIdAsync(int categoryId)
    {
        var services = await _context.Services
            .Where(s => s.CategoryId == categoryId)
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

}