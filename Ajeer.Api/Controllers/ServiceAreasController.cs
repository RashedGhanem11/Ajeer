using Ajeer.Api.DTOs.ServiceAreas;
using Ajeer.Api.Services.ServiceAreas;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/service-areas")]
[ApiController]
[Authorize]
public class ServiceAreasController(IServiceAreaService _service) : BaseApiController
{
    [HttpGet]
    [ProducesResponseType(typeof(List<CityResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var result = await _service.GetAllServiceAreasAsync();
        return Ok(result);
    }
}