using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.Enums;
using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Bookings;

public class BookingService(AppDbContext _context, IWebHostEnvironment _environment) : IBookingService
{
    private readonly string _uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", "bookings");

    public async Task<int> CreateBookingAsync(int userId, CreateBookingRequest dto)
    {
        var fileUploadTask = SaveAttachmentsAsync(userId, dto.Attachments);
        var suitableProvider = await FindSuitableProviderAsync(dto);

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

        return booking.Id;
    }

    private async Task<Models.ServiceProvider> FindSuitableProviderAsync(CreateBookingRequest dto)
    {
        var areaExists = await _context.ServiceAreas.AnyAsync(a => a.Id == dto.ServiceAreaId);
        if (!areaExists) throw new Exception("The requested Area is not available.");

        TimeSpan bookingTime = dto.ScheduledDate.TimeOfDay;
        DayOfWeek bookingDay = dto.ScheduledDate.DayOfWeek;

        var suitableProvider = await _context.ServiceProviders
            .AsNoTracking()
            .Where(p => p.ServiceAreas.Any(a => a.Id == dto.ServiceAreaId))
            .Where(p => dto.ServiceIds.All(reqId => p.Services.Any(s => s.Id == reqId)))
            .Where(p => p.Schedules.Any(s =>
                s.DayOfWeek == bookingDay
                && s.StartTime <= bookingTime
                && s.EndTime >= bookingTime))
            .OrderBy(x => Guid.NewGuid())
            .FirstOrDefaultAsync();

        if (suitableProvider == null)
            throw new Exception("No service providers are currently available for these services in your area at this time.");

        return suitableProvider;
    }

    private async Task<List<Attachment>> SaveAttachmentsAsync(int userId, List<IFormFile>? files)
    {
        var attachments = new List<Attachment>();
        if (files == null || !files.Any()) return attachments;

        if (!Directory.Exists(_uploadsFolder)) Directory.CreateDirectory(_uploadsFolder);

        var tasks = files.Select(async file =>
        {
            if (file.Length > 0)
            {
                string uniqueFileName = $"{Guid.NewGuid()}_{file.FileName}";
                string filePath = Path.Combine(_uploadsFolder, uniqueFileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                string ext = Path.GetExtension(file.FileName).ToLower();
                (MimeType mime, FileType type) = GetFileTypes(ext);

                return new Attachment
                {
                    UploaderId = userId,
                    FileUrl = uniqueFileName,
                    MimeType = mime,
                    FileType = type
                };
            }
            return null;
        });

        var results = await Task.WhenAll(tasks);

        return results.Where(a => a != null).ToList()!;
    }

    private static (MimeType, FileType) GetFileTypes(string ext)
    {
        return ext switch
        {
            // Images
            ".jpg" or ".jpeg" => (MimeType.Jpeg, FileType.BookingImage),
            ".png" => (MimeType.Png, FileType.BookingImage),
            ".webp" => (MimeType.Webp, FileType.BookingImage),

            // Video
            ".mp4" => (MimeType.Mp4, FileType.BookingVideo),
            ".mov" => (MimeType.Mov, FileType.BookingVideo),

            // Audio
            ".mp3" => (MimeType.Mp3, FileType.BookingAudio),
            ".wav" => (MimeType.Wav, FileType.BookingAudio),
            ".m4a" => (MimeType.M4a, FileType.BookingAudio),

            _ => (MimeType.Other, FileType.BookingImage)
        };
    }
}