using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Ajeer.Api.Hubs;

[Authorize]
public class NotificationHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        Console.WriteLine($"User {Context.UserIdentifier} connected to NotificationHub");
        await base.OnConnectedAsync();
    }
}