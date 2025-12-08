namespace Ajeer.Api.DTOs.Chats;

public class ConversationResponse
{
    public int BookingId { get; set; }
    public string OtherSideName { get; set; } = null!;
    public string? OtherSideImageUrl { get; set; } = null!;
    public string LastMessage { get; set; } = null!;
    public string LastMessageFormattedTime { get; set; } = null!;
    public int UnreadCount { get; set; }
}