using Ajeer.Api.DTOs.Reviews;
using Ajeer.Api.Services.Reviews;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ReviewsController(IReviewService _reviewService) : BaseApiController
{
    [HttpPost]
    public async Task<IActionResult> AddReview([FromBody] CreateReviewRequest dto)
    {
        int userId = GetUserId();
        await _reviewService.AddReviewAsync(userId, dto);
        return Ok(new { message = "Review added successfully." });
    }

    [HttpGet("booking/{bookingId}")]
    [ProducesResponseType(typeof(ReviewResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status204NoContent)] // no review found
    public async Task<IActionResult> GetReview(int bookingId)
    {
        int userId = GetUserId();
        var result = await _reviewService.GetReviewByBookingIdAsync(userId, bookingId);

        if (result == null) return NoContent(); //nothing found

        return Ok(result);
    }
}