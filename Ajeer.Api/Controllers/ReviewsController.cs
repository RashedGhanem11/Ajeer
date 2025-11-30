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
}