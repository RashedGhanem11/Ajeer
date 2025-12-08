namespace Ajeer.Api.DTOs.Chats;

public class MessageResponse
{
    public int Id { get; set; }
    public string Content { get; set; } = null!;
    public DateTime SentAt { get; set; }
    public string FormattedTime { get; set; } = null!;
    public bool IsRead { get; set; }
    public bool IsMine { get; set; }
}