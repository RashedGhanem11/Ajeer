using System.Security.Claims;
using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.Services.Bookings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class BookingsController(IBookingService _bookingService) : ControllerBase
{
    [HttpPost]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> CreateBooking([FromForm] CreateBookingRequest dto)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null) return Unauthorized();
        int userId = int.Parse(userIdClaim.Value);

        int bookingId = await _bookingService.CreateBookingAsync(userId, dto);

        return StatusCode(StatusCodes.Status201Created, new { bookingId = bookingId, message = "Booking created successfully" });
    }
}