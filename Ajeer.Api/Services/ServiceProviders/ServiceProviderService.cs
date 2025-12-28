using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.DTOs.ServiceCategories;
using Ajeer.Api.DTOs.ServiceProviders;
using Ajeer.Api.DTOs.Services;
using Ajeer.Api.DTOs.Subscriptions;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Auth;
using Ajeer.Api.Services.Emails;
using Ajeer.Api.Services.Files;
using Ajeer.Api.Services.Subscriptions;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.ServiceProviders;

public class ServiceProviderService(AppDbContext _context, IAuthService _authService, IFileService _fileService, ISubscriptionService _subscriptionService, IEmailService _emailService) : IServiceProviderService
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

        string? idCardUrl = null;
        if (dto.IdCardImage != null)
        {
            idCardUrl = await _fileService.SaveFileAsync(dto.IdCardImage, "idCards");
        }

        var provider = new Models.ServiceProvider
        {
            UserId = userId,
            Bio = dto.Bio,
            IdCardUrl = idCardUrl,
            IsVerified = false,
            Rating = 0,
            TotalReviews = 0,
            IsActive = true,
            CreatedAt = DateTime.Now
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
            ProfilePictureUrl = _fileService.GetPublicUrl("profilePictures", user.ProfilePictureUrl),
            HasProviderApplication = true
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

    public async Task<List<ProviderSummaryResponse>> GetProvidersByStatusAsync(bool isVerified)
    {
        return await _context.ServiceProviders
            .Where(sp => sp.IsVerified == isVerified)
            .Include(sp => sp.User)
            .Select(sp => new ProviderSummaryResponse
            {
                ServiceProviderId = sp.UserId,
                FullName = sp.User.Name,
                Email = sp.User.Email,
                PhoneNumber = sp.User.Phone,
                IsVerified = sp.IsVerified,
                IsActive = sp.IsActive,
                Rating = sp.Rating,
                TotalReviews = sp.TotalReviews,
                TotalBookings = sp.Bookings.Count(),
                JoinedDate = sp.CreatedAt,
                ProfilePictureUrl = _fileService.GetPublicUrl("profilePictures", sp.User.ProfilePictureUrl),
                IdCardUrl = _fileService.GetPublicUrl("idCards", sp.IdCardUrl)
            })
            .ToListAsync();
    }

    public async Task<ProviderDetailResponse> GetProviderDetailsAsync(int providerId)
    {
        var sp = await _context.ServiceProviders
            .Include(sp => sp.User)
            .Include(sp => sp.ProviderServices).ThenInclude(ps => ps.Service)
            .Include(sp => sp.Subscriptions).ThenInclude(s => s.SubscriptionPlan)
            .FirstOrDefaultAsync(x => x.UserId == providerId);

        if (sp == null) throw new Exception("Provider not found");

        var bookings = await _context.Bookings
            .Where(b => b.ServiceProviderId == providerId)
            .OrderByDescending(b => b.CreatedAt)
            .Select(b => new BookingSummaryResponse
            {
                Id = b.Id,
                UserName = b.User.Name,
                ScheduledDate = b.ScheduledDate,
                CompletedDate = b.CompletedDate,
                EstimatedHours = b.EstimatedHours,
                Amount = b.TotalAmount,
                Status = b.Status
            })
            .ToListAsync();

        var reviews = await _context.Reviews
            .Where(r => r.ServiceProviderId == providerId)
            .OrderByDescending(r => r.ReviewDate)
            .Select(r => new ReviewResponse
            {
                ReviewerName = r.User.Name,
                Rating = r.Rating,
                Comment = r.Comment,
                ReviewDate = r.ReviewDate
            })
            .ToListAsync();

        var activeSub = sp.Subscriptions.FirstOrDefault(s => s.EndDate > DateTime.UtcNow);

        return new ProviderDetailResponse
        {
            ServiceProviderId = sp.UserId,
            FullName = sp.User.Name,
            Email = sp.User.Email,
            PhoneNumber = sp.User.Phone,
            Rating = sp.Rating,
            TotalBookings = sp.Bookings.Count,
            IsActive = sp.IsActive,
            IsVerified = sp.IsVerified,
            Bio = sp.Bio ?? "",
            ProfilePictureUrl = _fileService.GetPublicUrl("profilePictures", sp.User.ProfilePictureUrl),

            Services = sp.ProviderServices.Select(s => s.Service.Name).ToList(),
            RecentBookings = bookings,
            RecentReviews = reviews,

            Subscription = new SubscriptionStatusResponse
            {
                HasActiveSubscription = activeSub != null,
                PlanName = activeSub?.SubscriptionPlan.Name ?? "None",
                ExpiryDate = activeSub?.EndDate,
                IsProviderActive = sp.IsActive
            }
        };
    }

    public async Task ApproveProviderAsync(int providerId)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.UserId == providerId);

        if (provider == null) throw new Exception("Provider application not found.");

        provider.IsVerified = true;
        provider.User.Role = UserRole.ServiceProvider;

        await _context.SaveChangesAsync();

        // free subscription for 30 days
        await _subscriptionService.ActivateSubscriptionAsync(provider.UserId, -1);

        string body = $@"
            <h3>Congratulations {provider.User.Name}!</h3>
            <p>Your application to become a Service Provider on Ajeer has been <b>APPROVED</b>.</p>
            <p>You have been granted a <b>30-Day Free Trial</b>.</p>
            <p>Please log out and log back in to access your provider dashboard.</p>";

        await _emailService.SendEmailAsync(provider.User.Email, "Welcome to Ajeer - Application Approved", body);
    }

    public async Task RejectProviderAsync(int providerId, string reason)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.UserId == providerId);

        if (provider == null) throw new Exception("Provider application not found.");

        string email = provider.User.Email;
        string name = provider.User.Name;

        _context.ServiceProviders.Remove(provider);
        provider.User.Role = UserRole.Customer;

        await _context.SaveChangesAsync();

        string body = $@"
            <h3>Application Update</h3>
            <p>Dear {name},</p>
            <p>Unfortunately, your application to join Ajeer has been <b>REJECTED</b>.</p>
            <p><b>Reason:</b> {reason}</p>
            <p>You may fix the issues and apply again.</p>";

        await _emailService.SendEmailAsync(email, "Ajeer Application Status", body);
    }

    public async Task ToggleProviderActiveStatusAsync(int providerId)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.UserId == providerId);

        if (provider == null) throw new Exception("Provider not found.");

        provider.IsActive = !provider.IsActive;
        await _context.SaveChangesAsync();

        string status = provider.IsActive ? "ACTIVATED" : "DEACTIVATED";
        string color = provider.IsActive ? "green" : "red";
        string body = $@"
            <h3>Account Status Update</h3>
            <p>Dear {provider.User.Name},</p>
            <p>Your service provider account has been <b style='color:{color}'>{status}</b> by the administrator.</p>
            <p>If you believe this is a mistake, please contact support.</p>";

        await _emailService.SendEmailAsync(provider.User.Email, $"Ajeer - Account {status}", body);
    }

    public async Task SendCustomEmailAsync(int providerId, string subject, string bodyContent)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.UserId == providerId);

        if (provider == null) throw new Exception("Provider not found.");

        string htmlBody = $@"
            <h3>Message from Ajeer Admin</h3>
            <p>Dear {provider.User.Name},</p>
            <p>{bodyContent}</p>
            <br/>
            <p>Regards,<br/>Ajeer Management</p>";

        await _emailService.SendEmailAsync(provider.User.Email, subject, htmlBody);
    }

}