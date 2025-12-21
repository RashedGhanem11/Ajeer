using Ajeer.Api.DTOs.Subscriptions;
using Ajeer.Api.Services.Subscriptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Ajeer.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class SubscriptionsController(ISubscriptionService _subscriptionService) : BaseApiController
{
    [HttpGet("plans")]
    public async Task<ActionResult<List<SubscriptionPlanResponse>>> GetPlans()
    {
        return Ok(await _subscriptionService.GetPlansAsync());
    }

    [HttpGet("my-status")]
    public async Task<ActionResult<SubscriptionStatusResponse>> GetStatus()
    {
        var userId = GetUserId();
        return Ok(await _subscriptionService.GetProviderSubscriptionStatusAsync(userId));
    }

    [HttpPost("create-payment-intent/{planId}")]
    public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent(int planId)
    {
        var userId = GetUserId();

        try
        {
            var response = await _subscriptionService.CreateSubscriptionIntentAsync(userId, planId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}