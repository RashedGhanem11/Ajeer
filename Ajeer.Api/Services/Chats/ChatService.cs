using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Chats;
using Ajeer.Api.Hubs;
using Ajeer.Api.Models;
using Ajeer.Api.Services.Files;
using Ajeer.Api.Services.Formatting;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Chats;

public class ChatService(AppDbContext _context, IFileService _fileService,
 IFormattingService _formattingService, IHubContext<ChatHub> _hubContext) : IChatService
{
    public async Task<List<ConversationResponse>> GetConversationsAsync(int userId)
    {
        var conversationsData = await _context.Bookings
            .AsNoTracking()
            .Where(b => b.UserId == userId || b.ServiceProvider.UserId == userId)
            .Where(b => b.Messages.Any())
            .Select(b => new
            {
                BookingId = b.Id,
                IsCustomer = b.UserId == userId,
                CustomerName = b.User.Name,
                CustomerImage = b.User.ProfilePictureUrl,
                ProviderName = b.ServiceProvider.User.Name,
                ProviderImage = b.ServiceProvider.User.ProfilePictureUrl,
                LastMsg = b.Messages.OrderByDescending(m => m.SentAt).FirstOrDefault(),
                UnreadCount = b.Messages.Count(m => m.ReceiverId == userId && !m.IsRead)
            })
            .OrderByDescending(x => x.LastMsg!.SentAt)
            .ToListAsync();

        return conversationsData.Select(c => new ConversationResponse
        {
            BookingId = c.BookingId,
            LastMessage = c.LastMsg?.Content ?? "",
            LastMessageFormattedTime = c.LastMsg?.SentAt != null ? _formattingService.FormatRelativeTime(c.LastMsg.SentAt) : "",
            UnreadCount = c.UnreadCount,
            OtherSideName = c.IsCustomer ? c.ProviderName : c.CustomerName,
            OtherSideImageUrl = c.IsCustomer
                ? _fileService.GetPublicUrl("profilePictures", c.ProviderImage)
                : _fileService.GetPublicUrl("profilePictures", c.CustomerImage)
        }).ToList();
    }

    public async Task<List<MessageResponse>> GetMessagesAsync(int userId, int bookingId)
    {
        var booking = await _context.Bookings
            .AsNoTracking()
            .Include(b => b.ServiceProvider)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null) throw new Exception("Booking not found");

        if (booking.UserId != userId && booking.ServiceProvider.UserId != userId)
        {
            throw new Exception("You are not part of this conversation.");
        }

        var messages = await _context.Messages
            .Where(m => m.BookingId == bookingId)
            .OrderBy(m => m.SentAt)
            .ToListAsync();

        var unreadMessages = messages
            .Where(m => m.ReceiverId == userId && !m.IsRead)
            .ToList();

        if (unreadMessages.Any())
        {
            foreach (var msg in unreadMessages)
            {
                msg.IsRead = true;
            }
            _context.Messages.UpdateRange(unreadMessages);
            await _context.SaveChangesAsync();
        }

        return messages.Select(m => new MessageResponse
        {
            Id = m.Id,
            Content = m.Content,
            SentAt = m.SentAt,
            FormattedTime = _formattingService.FormatRelativeTime(m.SentAt),
            IsRead = m.IsRead,
            IsMine = m.SenderId == userId
        }).ToList();
    }

    public async Task<MessageResponse> SendMessageAsync(int userId, int bookingId, string content)
    {
        var booking = await _context.Bookings
            .Include(b => b.ServiceProvider)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null) throw new Exception("Booking not found");

        int receiverId;
        if (booking.UserId == userId)
        {
            receiverId = booking.ServiceProviderId;
        }
        else if (booking.ServiceProviderId == userId)
        {
            receiverId = booking.UserId;
        }
        else
        {
            throw new Exception("You are not part of this booking.");
        }

        var message = new Message
        {
            BookingId = bookingId,
            SenderId = userId,
            ReceiverId = receiverId,
            Content = content,
            SentAt = DateTime.Now,
            IsRead = false
        };

        _context.Messages.Add(message);
        await _context.SaveChangesAsync();

        var messageDto = new MessageResponse
        {
            Id = message.Id,
            Content = message.Content,
            SentAt = message.SentAt,
            FormattedTime = _formattingService.FormatRelativeTime(message.SentAt),
            IsMine = true,
            IsRead = false
        };

        var receiverDto = new MessageResponse
        {
            Id = message.Id,
            Content = message.Content,
            SentAt = message.SentAt,
            FormattedTime = _formattingService.FormatRelativeTime(message.SentAt),
            IsMine = false,
            IsRead = false
        };

        await _hubContext.Clients.User(receiverId.ToString())
            .SendAsync("ReceiveNewMessage", receiverDto);

        return messageDto;
    }

    public async Task DeleteMessageAsync(int userId, int messageId)
    {
        var message = await _context.Messages.FindAsync(messageId);
        if (message == null) throw new Exception("Message not found.");

        if (message.SenderId != userId)
            throw new Exception("You can only delete your own messages.");

        _context.Messages.Remove(message);
        await _context.SaveChangesAsync();

        await _hubContext.Clients.User(message.ReceiverId.ToString())
            .SendAsync("MessageDeleted", messageId);
    }

    public async Task MarkMessageAsReadAsync(int userId, int messageId)
    {
        var message = await _context.Messages.FindAsync(messageId);
        if (message == null) throw new Exception("Message not found.");

        if (message.ReceiverId != userId)
            throw new Exception("Unauthorized.");

        if (!message.IsRead)
        {
            message.IsRead = true;
            await _context.SaveChangesAsync();

            await _hubContext.Clients.User(message.SenderId.ToString())
                .SendAsync("MessageRead", messageId);
        }
    }
}