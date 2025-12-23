using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Notifications;
using Ajeer.Api.Enums;
using Ajeer.Api.Hubs;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Formatting;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Notifications;

public class NotificationService(AppDbContext _context, IFormattingService _formattingService,
    IHubContext<NotificationHub> _hubContext) : INotificationService
{
    public async Task CreateNotificationAsync(int userId, NotificationType type,
        int? bookingId = null, string? specificValue = null)
    {
        var content = await GetTitleAndMessageAsync(type, bookingId, specificValue);

        var notification = new Notification
        {
            UserId = userId,
            BookingId = bookingId,
            Type = type,
            Title = content.Title,
            Message = content.Message,
            CreatedAt = DateTime.Now,
            IsRead = false
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        var responseDto = new NotificationResponse
        {
            Id = notification.Id,
            Title = notification.Title,
            Message = notification.Message,
            Type = notification.Type,
            CreatedAt = notification.CreatedAt,
            FormattedTime = "Just now",
            IsRead = notification.IsRead
        };

        await _hubContext.Clients.User(userId.ToString())
            .SendAsync("ReceiveNotification", responseDto);

        if (bookingId.HasValue)
        {
            await _hubContext.Clients.User(userId.ToString())
                .SendAsync("BookingUpdated", bookingId.Value);
        }

    }

    private async Task<(string Title, string Message)> GetTitleAndMessageAsync(NotificationType type, int? bookingId, string? specificValue)
    {
        string title = "";
        string message = "";

        Booking? booking = null;
        if (bookingId.HasValue)
        {
            booking = await _context.Bookings
                .Include(b => b.User)
                .Include(b => b.ServiceProvider).ThenInclude(sp => sp.User)
                .AsNoTracking()
                .FirstOrDefaultAsync(b => b.Id == bookingId);
        }

        switch (type)
        {
            case NotificationType.BookingCreated:
                title = "New Booking Request";
                message = "You have received a new booking request.";
                break;

            case NotificationType.BookingAccepted:
                title = "Booking Accepted";
                message = booking != null
                    ? $"Your booking has been accepted by {booking.ServiceProvider.User.Name}."
                    : "Your booking has been accepted.";
                break;

            case NotificationType.BookingCancelledByUser:
                title = "Booking Cancelled";
                message = booking != null
                    ? $"Booking cancelled by {booking.User.Name}."
                    : "The booking was cancelled by the customer.";
                break;

            case NotificationType.BookingReassignedAfterBeingCancelled:
                title = "Booking Reassigned";
                message = $"Your provider {specificValue} cancelled. We found a new provider for you automatically.";
                break;

            case NotificationType.BookingReassignedAfterBeingRejected:
                title = "Booking Reassigned";
                message = "We found a new provider for your request.";
                break;

            case NotificationType.BookingCompleted:
                title = "Booking Completed";
                message = "Your service has been completed. Please leave a review!";
                break;

            case NotificationType.BookingReviewed:
                title = "New Review Received!";
                message = booking != null
                    ? $"A customer has rated your service. You received {booking.Review?.Rating.ToString()} stars!"
                    : "A customer has left a review for your service.";
                break;

            default:
                title = "Notification";
                message = "You have a new notification.";
                break;
        }

        return (title, message);
    }

    public async Task<List<NotificationResponse>> GetUserNotificationsAsync(int userId)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();

        var unread = notifications.Where(n => !n.IsRead).ToList();

        if (unread.Any())
        {
            foreach (var n in unread)
            {
                n.IsRead = true;
            }
            await _context.SaveChangesAsync();
        }

        return notifications.Select(n => new NotificationResponse
        {
            Id = n.Id,
            Title = n.Title,
            Message = n.Message,
            Type = n.Type,
            CreatedAt = n.CreatedAt,
            FormattedTime = _formattingService.FormatRelativeTime(n.CreatedAt),
            IsRead = n.IsRead
        }).ToList();
    }
}