using Ajeer.Api.DTOs.Notifications;
using Ajeer.Api.Enums;

namespace Ajeer.Api.Services.Notifications;

public interface INotificationService
{
    Task CreateNotificationAsync(int userId, NotificationType type, int? bookingId, string? specificValue = null);
    Task<List<NotificationResponse>> GetUserNotificationsAsync(int userId);
}