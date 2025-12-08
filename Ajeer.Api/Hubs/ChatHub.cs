using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Ajeer.Api.Hubs;

[Authorize]
public class ChatHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        Console.WriteLine($"User {userId} connected to ChatHub with ConnectionId {Context.ConnectionId}");

        await base.OnConnectedAsync();
    }
}