using System.Security.Claims;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.Services.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(IAuthService _authService) : ControllerBase
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

    [HttpPost("login/email")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> LoginWithEmail([FromBody] EmailLoginRequest dto)
    {
        var result = await _authService.LoginWithEmailAsync(dto);

        if (result == null)
        {
            return Unauthorized(new { message = "Login failed: Invalid email or password." });
        }

        return Ok(result);
    }

    [HttpPost("login/phone")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> LoginWithPhone([FromBody] PhoneLoginRequest dto)
    {
        var result = await _authService.LoginWithPhoneAsync(dto);

        if (result == null)
        {
            return Unauthorized(new { message = "Login failed: Invalid phone number or password." });
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
}