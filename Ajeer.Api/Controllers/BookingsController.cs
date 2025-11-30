using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.Enums;
using Ajeer.Api.Services.Bookings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class BookingsController(IBookingService _bookingService) : BaseApiController
{
    [HttpPost]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> CreateBooking([FromForm] CreateBookingRequest dto)
    {
        int userId = GetUserId();
        int bookingId = await _bookingService.CreateBookingAsync(userId, dto);

        return StatusCode(StatusCodes.Status201Created, new { bookingId = bookingId, message = "Booking created successfully" });
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<BookingListResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBookings([FromQuery] string role)
    {
        if
        (
            string.IsNullOrEmpty(role) ||
            (role.ToLower() != "customer" && role.ToLower() != "serviceprovider")
        )
        {
            return BadRequest(new { message = "Valid Role (Customer or ServiceProvider) is required." });
        }

        int userId = GetUserId();
        var result = await _bookingService.GetBookingsAsync(userId,
         role.ToLower() == "customer" ? UserRole.Customer : UserRole.ServiceProvider);

        return Ok(result);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(BookingDetailResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBookingDetails(int id)
    {
        int userId = GetUserId();
        var result = await _bookingService.GetBookingDetailsAsync(userId, id);

        return Ok(result);
    }

    [HttpPut("{id}/accept")]
    [Authorize(Roles = "ServiceProvider")]
    public async Task<IActionResult> AcceptBooking(int id)
    {
        int userId = GetUserId();
        await _bookingService.AcceptBookingAsync(userId, id);
        return Ok(new { message = "Booking accepted successfully." });
    }

    [HttpPut("{id}/complete")]
    [Authorize(Roles = "ServiceProvider")]
    public async Task<IActionResult> CompleteBooking(int id)
    {
        int userId = GetUserId();
        await _bookingService.CompleteBookingAsync(userId, id);
        return Ok(new { message = "Booking completed successfully." });
    }

    [HttpPut("{id}/reject")]
    [Authorize(Roles = "ServiceProvider")]
    public async Task<IActionResult> RejectBooking(int id)
    {
        int userId = GetUserId();
        await _bookingService.RejectBookingAsync(userId, id);
        return Ok(new { message = "Booking rejected successfully." });
    }

    [HttpPut("{id}/cancel")]
    public async Task<IActionResult> CancelBooking(int id)
    {
        int userId = GetUserId();
        await _bookingService.CancelBookingAsync(userId, id);
        return Ok(new { message = "Booking cancelled successfully." });
    }
}