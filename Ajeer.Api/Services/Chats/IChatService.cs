using Ajeer.Api.DTOs.Chats;

namespace Ajeer.Api.Services.Chats;

public interface IChatService
{
    Task<List<ConversationResponse>> GetConversationsAsync(int userId);
    Task<List<MessageResponse>> GetMessagesAsync(int userId, int bookingId);
    Task<MessageResponse> SendMessageAsync(int userId, int bookingId, string content);
    Task DeleteMessageAsync(int userId, int messageId);
    Task MarkMessageAsReadAsync(int userId, int messageId);
}