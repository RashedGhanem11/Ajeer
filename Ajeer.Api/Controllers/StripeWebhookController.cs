using Ajeer.Api.Services.Subscriptions;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace Ajeer.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class StripeWebhookController(ISubscriptionService _subscriptionService, IConfiguration _configuration) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Index()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        try
        {
            var stripeEvent = EventUtility.ConstructEvent(
                json,
                Request.Headers["Stripe-Signature"],
                _configuration["Stripe:WebhookSecret"]
            );

            if (stripeEvent.Type == EventTypes.PaymentIntentSucceeded)
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;

                var userId = int.Parse(paymentIntent!.Metadata["UserId"]);
                var planId = int.Parse(paymentIntent!.Metadata["PlanId"]);

                await _subscriptionService.ActivateSubscriptionAsync(userId, planId, paymentIntent.Id);
            }

            return Ok();
        }
        catch
        {
            return BadRequest();
        }
    }
}