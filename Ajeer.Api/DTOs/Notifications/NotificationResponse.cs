using Ajeer.Api.Enums;

namespace Ajeer.Api.DTOs.Notifications;

public class NotificationResponse
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public DateTime CreatedAt { get; set; }
    public string FormattedTime { get; set; } = string.Empty;
    public bool IsRead { get; set; }
}