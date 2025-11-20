using System.Globalization;
using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Services;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Services;

public class ServiceService(AppDbContext _context) : IServiceService
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
            FormattedPrice = $"JOD {s.BasePrice.ToString("N1", new CultureInfo("en-US"))}",
            EstimatedTime = FormatEstimatedTime(s.EstimatedHours)
        }).ToList();

        return response;
    }

    private static string FormatEstimatedTime(decimal hours)
    {
        int totalMinutes = (int)(hours * 60);
        int wholeHours = totalMinutes / 60;
        int remainingMinutes = totalMinutes % 60;

        string timeString = "Est. Time: ";

        if (wholeHours > 0)
        {
            timeString += $"{wholeHours} hr" + (wholeHours > 1 ? "s" : "");
            if (remainingMinutes > 0)
            {
                timeString += $" {remainingMinutes} mins";
            }
        }
        else if (remainingMinutes > 0)
        {
            timeString += $"{remainingMinutes} mins";
        }
        else
        {
            timeString += "less than 1 hr";
        }

        return timeString;
    }
}