using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceProviders;
using Ajeer.Api.Services.ServiceProviders;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ServiceProvidersController(IServiceProviderService _providerService) : BaseApiController
{
    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(AuthResponse))]
    public async Task<IActionResult> BecomeProvider([FromBody] BecomeProviderRequest dto)
    {
        int userId = GetUserId();
        var response = await _providerService.BecomeProviderAsync(userId, dto);

        return Ok(response);
    }

    [HttpGet("my-profile")]
    [Authorize(Roles = "ServiceProvider")]
    [ProducesResponseType(typeof(ProviderProfileResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyProfile()
    {
        int userId = GetUserId();
        var result = await _providerService.GetMyProfileAsync(userId);
        return Ok(result);
    }

    [HttpPut("profile")]
    [Authorize(Roles = "ServiceProvider")]
    public async Task<IActionResult> UpdateProfile([FromBody] BecomeProviderRequest dto)
    {
        int userId = GetUserId();
        await _providerService.UpdateProviderProfileAsync(userId, dto);

        return Ok(new { message = "Profile updated successfully." });
    }
}