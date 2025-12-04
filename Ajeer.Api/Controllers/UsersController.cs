using Ajeer.Api.DTOs.Users;
using Ajeer.Api.Services.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class UsersController(IUserService _userService) : BaseApiController
{
    [HttpPut("profile")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UpdateProfile([FromForm] UpdateUserProfileRequest dto)
    {
        int userId = GetUserId();

        var result = await _userService.UpdateProfileAsync(userId, dto);
        return Ok(result);
    }

    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest dto)
    {
        int userId = GetUserId();

        await _userService.ChangePasswordAsync(userId, dto);
        return Ok(new { message = "Password updated successfully." });
    }
}