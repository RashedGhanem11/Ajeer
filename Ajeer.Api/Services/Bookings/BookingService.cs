using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Attachments;
using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Files;
using Ajeer.Api.Services.Formatting;
using Ajeer.Api.Services.Notifications;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Bookings;

public class BookingService(AppDbContext _context, IFileService _fileService,
    IFormattingService _formattingService, INotificationService _notificationService) : IBookingService
{
    private async Task<Models.ServiceProvider> FindProviderForBooking(
        int serviceAreaId,
        List<int> serviceIds,
        DateTime scheduledDate,
        int customerId,
        int? excludeProviderId = null)
    {
        var areaExists = await _context.ServiceAreas.AnyAsync(a => a.Id == serviceAreaId);
        if (!areaExists) throw new Exception("The requested Service Area is not available.");

        TimeSpan bookingTime = scheduledDate.TimeOfDay;
        DayOfWeek bookingDay = scheduledDate.DayOfWeek;

        var query = _context.ServiceProviders
            .AsNoTracking()
            .Where(p => p.IsActive)
            .Where(p => p.Subscriptions.Any(s => s.EndDate >= DateTime.Now))
            .Where(p => p.ServiceAreas.Any(a => a.Id == serviceAreaId))
            .Where(p => serviceIds.All(reqId => p.Services.Any(s => s.Id == reqId)))
            .Where(p => p.Schedules.Any(s =>
                s.DayOfWeek == bookingDay
                && s.StartTime <= bookingTime
                && s.EndTime >= bookingTime));

        query = query.Where(p => p.UserId != customerId);

        if (excludeProviderId.HasValue)
        {
            query = query.Where(p => p.UserId != excludeProviderId.Value);
        }

        var suitableProvider = await query
            .OrderBy(x => Guid.NewGuid())
            .FirstOrDefaultAsync();

        if (suitableProvider == null)
        {
            throw new Exception("No service providers are currently available for these services in your area at this time.");
        }

        return suitableProvider;
    }

    public async Task<int> CreateBookingAsync(int userId, CreateBookingRequest dto)
    {
        var fileUploadTask = SaveAttachmentsAsync(userId, dto.Attachments);
        var suitableProvider = await FindProviderForBooking(
            dto.ServiceAreaId,
            dto.ServiceIds,
            dto.ScheduledDate,
            userId,
            null
        );

        var services = await _context.Services
            .Where(s => dto.ServiceIds.Contains(s.Id))
            .ToListAsync();

        var attachments = await fileUploadTask;

        decimal totalCost = services.Sum(s => s.BasePrice);
        decimal totalHours = services.Sum(s => s.EstimatedHours);

        var booking = new Booking
        {
            UserId = userId,
            ServiceProviderId = suitableProvider.UserId,
            ServiceAreaId = dto.ServiceAreaId,
            Status = BookingStatus.Pending,
            ScheduledDate = dto.ScheduledDate,
            Address = dto.Address,
            Latitude = (decimal)dto.Latitude,
            Longitude = (decimal)dto.Longitude,
            Notes = dto.Notes,
            TotalAmount = totalCost,
            EstimatedHours = totalHours,
            Attachments = attachments,
            BookingServiceItems = services.Select(s => new BookingServiceItem
            {
                ServiceId = s.Id,
                PriceAtBooking = s.BasePrice
            }).ToList()
        };

        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();

        await _notificationService.CreateNotificationAsync(
            suitableProvider.UserId,
            NotificationType.BookingCreated,
            booking.Id
        );

        return booking.Id;
    }

    private async Task<List<Attachment>> SaveAttachmentsAsync(int userId, List<IFormFile>? files)
    {
        var attachments = new List<Attachment>();
        if (files == null || !files.Any()) return attachments;

        var tasks = files.Select(async file =>
        {
            string? fileName = await _fileService.SaveFileAsync(file, "bookings");

            if (fileName != null)
            {
                (MimeType mime, FileType type) = _fileService.GetFileTypes(fileName);

                return new Attachment
                {
                    UploaderId = userId,
                    FileUrl = fileName,
                    MimeType = mime,
                    FileType = type
                };
            }
            return null;
        });

        var results = await Task.WhenAll(tasks);

        return results.Where(a => a != null).ToList()!;
    }

    public async Task<List<BookingListResponse>> GetBookingsAsync(int userId, UserRole role)
    {
        var query = _context.Bookings
            .AsNoTracking()
            .Include(b => b.User)
            .Include(b => b.ServiceProvider).ThenInclude(sp => sp.User)
            .Include(b => b.BookingServiceItems).ThenInclude(bsi => bsi.Service)
            .Include(b => b.Review)
            .AsQueryable();

        if (role == UserRole.Customer)
        {
            query = query.Where(b => b.UserId == userId);
        }
        else if (role == UserRole.ServiceProvider)
        {
            query = query.Where(b => b.ServiceProvider.UserId == userId);
        }
        else
        {
            return new List<BookingListResponse>();
        }

        var bookings = await query
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();

        return bookings.Select(b => new BookingListResponse
        {
            Id = b.Id,
            Status = b.Status,
            ServiceName = string.Join(", ", b.BookingServiceItems.Select(i => i.Service.Name)),
            OtherSideName = role == UserRole.Customer
                ? b.ServiceProvider.User.Name  // I see Provider
                : b.User.Name,                 // I see Customer

            OtherSideImageUrl = role == UserRole.Customer
                ? _fileService.GetPublicUrl("profilePictures", b.ServiceProvider.User.ProfilePictureUrl)
                : _fileService.GetPublicUrl("profilePictures", b.User.ProfilePictureUrl),

            HasReview = b.Review is not null
        }).ToList();
    }

    public async Task<BookingDetailResponse> GetBookingDetailsAsync(int userId, int bookingId)
    {
        var booking = await _context.Bookings
            .AsNoTracking()
            .Include(b => b.User)
            .Include(b => b.ServiceProvider).ThenInclude(sp => sp.User)
            .Include(b => b.BookingServiceItems).ThenInclude(bsi => bsi.Service)
            .Include(b => b.Attachments)
            .Include(b => b.ServiceArea)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null) throw new Exception("Booking not found.");

        if (booking.UserId != userId && booking.ServiceProvider.UserId != userId)
        {
            throw new Exception("You are not authorized to view these booking details.");
        }

        bool isCustomer = booking.UserId == userId;

        var attachmentUrls = booking.Attachments.Select(a =>
            _fileService.GetPublicUrl("bookings", a.FileUrl)!
        ).ToList();

        var response = new BookingDetailResponse
        {
            Id = booking.Id,
            Status = booking.Status,
            ServiceName = string.Join(", ", booking.BookingServiceItems.Select(i => i.Service.Name)),
            OtherSideName = isCustomer ? booking.ServiceProvider.User.Name : booking.User.Name,
            OtherSideImageUrl = isCustomer
                ? _fileService.GetPublicUrl("profilePictures", booking.ServiceProvider.User.ProfilePictureUrl)
                : _fileService.GetPublicUrl("profilePictures", booking.User.ProfilePictureUrl),

            OtherSidePhone = isCustomer ? booking.ServiceProvider.User.Phone : booking.User.Phone,
            ScheduledDate = DateOnly.FromDateTime(booking.ScheduledDate),
            ScheduledTime = TimeOnly.FromDateTime(booking.ScheduledDate),
            Address = booking.Address,
            Latitude = (double)booking.Latitude,
            Longitude = (double)booking.Longitude,
            Notes = booking.Notes,
            FormattedPrice = _formattingService.FormatCurrency(booking.TotalAmount),
            EstimatedTime = _formattingService.FormatEstimatedTime(booking.EstimatedHours),
            AreaName = booking.ServiceArea.AreaName,
            Attachments = booking.Attachments.Select(a => new AttachmentResponse
            {
                Id = a.Id,
                Url = _fileService.GetPublicUrl("bookings", a.FileUrl)!,
                FileType = a.FileType,
                MimeType = a.MimeType
            }).ToList()
        };

        return response;
    }

    public async Task AcceptBookingAsync(int providerId, int bookingId)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) throw new Exception("Booking not found.");

        if (booking.ServiceProviderId != providerId)
            throw new Exception("You are not authorized to accept this booking.");

        if (booking.Status != BookingStatus.Pending)
            throw new Exception("Only pending bookings can be accepted.");

        booking.Status = BookingStatus.Active;
        await _context.SaveChangesAsync();

        await _notificationService.CreateNotificationAsync(
            booking.UserId,
            NotificationType.BookingAccepted,
            bookingId
        );
    }

    public async Task RejectBookingAsync(int providerId, int bookingId)
    {
        var booking = await _context.Bookings
            .Include(b => b.BookingServiceItems)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null) throw new Exception("Booking not found.");

        if (booking.ServiceProviderId != providerId)
            throw new Exception("You are not authorized to reject this booking.");

        if (booking.Status != BookingStatus.Pending)
            throw new Exception("Only pending bookings can be rejected.");

        var serviceIds = booking.BookingServiceItems.Select(i => i.ServiceId).ToList();

        var newProvider = await FindProviderForBooking(
            booking.ServiceAreaId,
            serviceIds,
            booking.ScheduledDate,
            booking.UserId,
            providerId
        );

        booking.ServiceProviderId = newProvider.UserId;
        await _context.SaveChangesAsync();

        await _notificationService.CreateNotificationAsync(
            newProvider.UserId,
            NotificationType.BookingCreated,
            bookingId
        );

        await _notificationService.CreateNotificationAsync(
            booking.UserId,
            NotificationType.BookingReassignedAfterBeingRejected,
            bookingId
        );
    }

    public async Task CompleteBookingAsync(int providerId, int bookingId)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) throw new Exception("Booking not found.");

        if (booking.ServiceProviderId != providerId)
            throw new Exception("You are not authorized to complete this booking.");

        if (booking.Status != BookingStatus.Active)
            throw new Exception("Only active bookings can be completed.");

        booking.Status = BookingStatus.Completed;
        await _context.SaveChangesAsync();

        await _notificationService.CreateNotificationAsync(
            booking.UserId,
            NotificationType.BookingCompleted,
            bookingId
        );
    }

    public async Task CancelBookingAsync(int userId, int bookingId)
    {
        var booking = await _context.Bookings
            .Include(b => b.BookingServiceItems)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null) throw new Exception("Booking not found.");

        bool isCustomer = booking.UserId == userId;
        bool isProvider = booking.ServiceProviderId == userId;

        if (!isCustomer && !isProvider)
            throw new Exception("You are not authorized to cancel this booking.");

        if (booking.Status == BookingStatus.Completed)
            throw new Exception("Cannot cancel a completed booking.");

        if (isCustomer)
        {
            booking.Status = BookingStatus.Cancelled;
            await _context.SaveChangesAsync();

            await _notificationService.CreateNotificationAsync(
                booking.ServiceProviderId,
                NotificationType.BookingCancelledByUser,
                bookingId
            );
        }
        else if (isProvider)
        {
            string oldProviderName = booking.ServiceProvider.User.Name;
            var serviceIds = booking.BookingServiceItems.Select(i => i.ServiceId).ToList();

            try
            {
                var newProvider = await FindProviderForBooking(
                    booking.ServiceAreaId,
                    serviceIds,
                    booking.ScheduledDate,
                    booking.UserId,
                    userId
                );

                booking.ServiceProviderId = newProvider.UserId;
                booking.Status = BookingStatus.Pending;
            }
            catch
            {
                throw new Exception("You cannot cancel, no replacement found");
            }

            await _context.SaveChangesAsync();

            // Notify New Provider
            await _notificationService.CreateNotificationAsync(
                booking.ServiceProviderId,
                NotificationType.BookingCreated,
                bookingId
            );

            // Notify Customer (Because status changed Active -> Pending)
            await _notificationService.CreateNotificationAsync(
                booking.UserId,
                NotificationType.BookingReassignedAfterBeingCancelled,
                bookingId,
                oldProviderName
            );
        }
    }
}