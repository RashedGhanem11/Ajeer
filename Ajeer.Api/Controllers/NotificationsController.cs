using Ajeer.Api.Services.Notifications;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class NotificationsController(INotificationService _notificationService) : BaseApiController
{
    [HttpGet]
    public async Task<IActionResult> GetNotifications()
    {
        var userId = GetUserId();
        var result = await _notificationService.GetUserNotificationsAsync(userId);

        return Ok(result);
    }
}