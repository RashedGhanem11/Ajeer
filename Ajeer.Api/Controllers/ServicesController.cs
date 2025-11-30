using Ajeer.Api.DTOs.Services;
using Ajeer.Api.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ServicesController(IServiceService _service) : BaseApiController
{
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(List<ServiceResponse>))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetServices([FromQuery] int categoryId)
    {
        var services = await _service.GetServicesByCategoryIdAsync(categoryId);
        return Ok(services);
    }
}