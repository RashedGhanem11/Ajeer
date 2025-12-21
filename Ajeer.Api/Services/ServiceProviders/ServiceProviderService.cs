using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.DTOs.ServiceProviders;
using Ajeer.Api.DTOs.Services;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Auth;
using Ajeer.Api.Services.Files;
using Ajeer.Api.Services.Subscriptions;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceProviders;

public class ServiceProviderService(AppDbContext _context, IAuthService _authService, IFileService _fileService, ISubscriptionService _subscriptionService) : IServiceProviderService
{
    public async Task<AuthResponse> BecomeProviderAsync(int userId, BecomeProviderRequest dto)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) throw new Exception("User not found.");

        var existingProvider = await _context.ServiceProviders.FirstOrDefaultAsync(sp => sp.UserId == userId);
        if (existingProvider != null)
        {
            throw new Exception("User is already registered as a service provider.");
        }

        var provider = new Models.ServiceProvider
        {
            UserId = userId,
            Bio = dto.Bio,
            IsVerified = true,
            Rating = 0,
            TotalReviews = 0,
            IsActive = true
        };

        foreach (var serviceId in dto.ServiceIds)
        {
            provider.ProviderServices.Add(new ProviderService { ServiceId = serviceId });
        }

        foreach (var areaId in dto.ServiceAreaIds)
        {
            provider.ProviderServiceAreas.Add(new ProviderServiceArea { ServiceAreaId = areaId });
        }

        foreach (var slot in dto.Schedules)
        {
            provider.Schedules.Add(new Schedule
            {
                DayOfWeek = slot.DayOfWeek,
                StartTime = slot.StartTime,
                EndTime = slot.EndTime
            });
        }

        user.Role = UserRole.ServiceProvider;

        _context.ServiceProviders.Add(provider);

        await _context.SaveChangesAsync();

        // free subscription for 30 days
        await _subscriptionService.ActivateSubscriptionAsync(provider.UserId, -1);

        string newToken = _authService.GenerateJwtToken(user);

        return new AuthResponse
        {
            Token = newToken,
            UserId = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Role = user.Role,
            ProfilePictureUrl = _fileService.GetPublicUrl("profilePictures", user.ProfilePictureUrl)
        };
    }

    public async Task<ProviderProfileResponse> GetMyProfileAsync(int userId)
    {
        var providerData = await _context.ServiceProviders
            .AsNoTracking()
            .Where(p => p.UserId == userId)
            .Select(p => new
            {
                p.Bio,
                p.Rating,
                p.TotalReviews,
                p.IsVerified,
                Services = p.Services.Select(s => new ServiceResponse
                {
                    Id = s.Id,
                    Name = s.Name
                }).ToList(),

                FirstServiceCategory = p.Services.Select(s => new
                {
                    s.Category.Id,
                    s.Category.Name,
                    s.Category.IconUrl
                }).FirstOrDefault(),

                Areas = p.ServiceAreas.Select(a => new
                {
                    a.Id,
                    a.AreaName,
                    a.CityName
                }).ToList(),

                Schedules = p.Schedules.Select(s => new WorkScheduleDto
                {
                    DayOfWeek = s.DayOfWeek,
                    StartTime = s.StartTime,
                    EndTime = s.EndTime
                }).ToList()
            })
            .FirstOrDefaultAsync();

        if (providerData == null) throw new Exception("Provider profile not found.");

        ServiceCategoryResponse? categoryResponse = null;
        if (providerData.FirstServiceCategory != null)
        {
            categoryResponse = new ServiceCategoryResponse
            {
                Id = providerData.FirstServiceCategory.Id,
                Name = providerData.FirstServiceCategory.Name,
                IconUrl = _fileService.GetPublicUrl("categories", providerData.FirstServiceCategory.IconUrl)!
            };
        }

        var cities = providerData.Areas
            .GroupBy(a => a.CityName)
            .Select(g => new CityResponse
            {
                CityName = g.Key,
                Areas = g.Select(area => new AreaResponse
                {
                    Id = area.Id,
                    Name = area.AreaName
                }).ToList()
            })
            .ToList();

        var sortedSchedules = providerData.Schedules
            .OrderBy(s => s.DayOfWeek)
            .ThenBy(s => s.StartTime)
            .ToList();

        return new ProviderProfileResponse
        {
            Bio = providerData.Bio,
            Rating = providerData.Rating,
            TotalReviews = providerData.TotalReviews,
            IsVerified = providerData.IsVerified,
            ServiceCategory = categoryResponse,
            Services = providerData.Services,
            Cities = cities,
            Schedules = sortedSchedules
        };

    }

    public async Task UpdateProviderProfileAsync(int userId, BecomeProviderRequest dto)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.ProviderServices)
            .Include(p => p.ProviderServiceAreas)
            .Include(p => p.Schedules)
            .FirstOrDefaultAsync(p => p.UserId == userId);

        if (provider == null) throw new Exception("Provider profile not found.");

        provider.Bio = dto.Bio;

        var servicesToRemove = provider.ProviderServices
            .Where(ps => !dto.ServiceIds.Contains(ps.ServiceId))
            .ToList();

        if (servicesToRemove.Any())
        {
            _context.RemoveRange(servicesToRemove);
        }

        var existingServiceIds = provider.ProviderServices.Select(ps => ps.ServiceId).ToList();
        var newServiceIds = dto.ServiceIds.Except(existingServiceIds);

        foreach (var serviceId in newServiceIds)
        {
            provider.ProviderServices.Add(new ProviderService { ServiceId = serviceId });
        }

        var areasToRemove = provider.ProviderServiceAreas
            .Where(psa => !dto.ServiceAreaIds.Contains(psa.ServiceAreaId))
            .ToList();

        if (areasToRemove.Any())
        {
            _context.RemoveRange(areasToRemove);
        }

        var existingAreaIds = provider.ProviderServiceAreas.Select(psa => psa.ServiceAreaId).ToList();
        var newAreaIds = dto.ServiceAreaIds.Except(existingAreaIds);

        foreach (var areaId in newAreaIds)
        {
            provider.ProviderServiceAreas.Add(new ProviderServiceArea { ServiceAreaId = areaId });
        }

        _context.Schedules.RemoveRange(provider.Schedules);

        foreach (var slot in dto.Schedules)
        {
            provider.Schedules.Add(new Schedule
            {
                DayOfWeek = slot.DayOfWeek,
                StartTime = slot.StartTime,
                EndTime = slot.EndTime
            });
        }

        await _context.SaveChangesAsync();
    }
}