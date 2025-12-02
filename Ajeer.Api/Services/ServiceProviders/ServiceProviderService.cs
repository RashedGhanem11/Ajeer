using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceProviders;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Auth;
using Ajeer.Api.Services.Files;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceProviders;

public class ServiceProviderService(AppDbContext _context, IAuthService _authService, IFileService _fileService) : IServiceProviderService
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
            TotalReviews = 0
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
}