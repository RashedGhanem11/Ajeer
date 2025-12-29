using System.Security.Claims;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.Services.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(IAuthService _authService) : BaseApiController
{
    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Register([FromBody] UserRegisterRequest dto)
    {
        var result = await _authService.RegisterUserAsync(dto);

        if (result == null)
        {
            return Conflict(new { message = "Registration failed: User with this email or phone already exists." });
        }

        return StatusCode(StatusCodes.Status201Created, result);
    }

    [HttpPost("login")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Login([FromBody] LoginRequest dto)
    {
        var result = await _authService.LoginAsync(dto);

        if (result == null)
        {
            return Unauthorized(new { message = "Login failed: Invalid identifier or password." });
        }

        return Ok(result);
    }

    [HttpGet("test-auth")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult TestAuthorization()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userRole = User.FindFirst(ClaimTypes.Role)?.Value;

        return Ok(new
        {
            message = "You are successfully authenticated!",
            UserId = userId,
            Role = userRole
        });
    }

    [HttpGet("verify")]
    public async Task<IActionResult> VerifyEmail([FromQuery] string token)
    {
        var result = await _authService.VerifyEmailAsync(token);

        if (result == true)
        return Content("<h1 style='color:green; text-align:center; margin-top:50px;'>Verified! You can now login.</h1>", "text/html");

        if (result == null)
            return Content("<h1 style='color:blue; text-align:center; margin-top:50px;'>Your email is already verified.</h1>", "text/html");

        return Content("<h1 style='color:red; text-align:center; margin-top:50px;'>Invalid or expired link.</h1>", "text/html");
    }
}