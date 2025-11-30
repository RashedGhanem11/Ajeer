using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

public class BaseApiController : ControllerBase
{
    protected int GetUserId()
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdString))
        {
            throw new UnauthorizedAccessException("User ID claim is missing.");
        }

        return int.Parse(userIdString);
    }
}