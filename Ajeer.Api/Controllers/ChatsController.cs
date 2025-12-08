using Ajeer.Api.DTOs.Chats;
using Ajeer.Api.Services.Chats;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ChatsController(IChatService _chatService) : BaseApiController
{
    [HttpGet]
    public async Task<IActionResult> GetConversations()
    {
        var userId = GetUserId();
        var result = await _chatService.GetConversationsAsync(userId);
        return Ok(result);
    }

    [HttpGet("{bookingId}")]
    public async Task<IActionResult> GetMessages(int bookingId)
    {
        var userId = GetUserId();
        var result = await _chatService.GetMessagesAsync(userId, bookingId);
        return Ok(result);
    }

    [HttpPost("{bookingId}")]
    public async Task<IActionResult> SendMessage(int bookingId, [FromBody] SendMessageRequest dto)
    {
        var userId = GetUserId();
        var result = await _chatService.SendMessageAsync(userId, bookingId, dto.Content);
        return Ok(result);
    }

    [HttpDelete("messages/{id}")]
    public async Task<IActionResult> DeleteMessage(int id)
    {
        var userId = GetUserId();
        await _chatService.DeleteMessageAsync(userId, id);
        return Ok(new { message = "Message deleted." });
    }

    [HttpPut("messages/{id}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        var userId = GetUserId();
        await _chatService.MarkMessageAsReadAsync(userId, id);
        return Ok(new { message = "Message marked as read." });
    }
}