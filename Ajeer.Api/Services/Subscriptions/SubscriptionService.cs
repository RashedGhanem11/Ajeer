using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Subscriptions;
using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Stripe;

namespace Ajeer.Api.Services.Subscriptions;

public class SubscriptionService : ISubscriptionService
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;

    public SubscriptionService(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
        StripeConfiguration.ApiKey = _configuration["Stripe:SecretKey"];
    }

    public async Task<List<SubscriptionPlanResponse>> GetPlansAsync()
    {
        return await _context.SubscriptionPlans
            .Select(p => new SubscriptionPlanResponse
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.Price,
                DurationInDays = p.DurationInDays
            }).ToListAsync();
    }

    public async Task<SubscriptionStatusResponse> GetProviderSubscriptionStatusAsync(int userId)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.Subscriptions)
            .ThenInclude(s => s.SubscriptionPlan)
            .FirstOrDefaultAsync(p => p.UserId == userId);

        if (provider == null) throw new Exception("Provider not found.");

        var latestSub = provider.Subscriptions
            .OrderByDescending(s => s.EndDate)
            .FirstOrDefault();

        bool hasActive = latestSub != null && latestSub.EndDate > DateTime.Now;

        return new SubscriptionStatusResponse
        {
            HasActiveSubscription = hasActive,
            ExpiryDate = latestSub?.EndDate,
            PlanName = latestSub?.SubscriptionPlan?.Name,
            IsProviderActive = provider.IsActive
        };
    }

    public async Task<PaymentIntentResponse> CreateSubscriptionIntentAsync(int userId, int planId)
    {
        var plan = await _context.SubscriptionPlans.FindAsync(planId);
        if (plan == null) throw new Exception("Subscription plan not found.");

        var options = new PaymentIntentCreateOptions
        {
            // Stripe uses smallest currency unit (Cents)
            Amount = (long)(plan.Price * 100),
            Currency = "usd",
            AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
            {
                Enabled = true,
            },
            Metadata = new Dictionary<string, string>
            {
                { "UserId", userId.ToString() },
                { "PlanId", planId.ToString() }
            }
        };

        var service = new PaymentIntentService();
        PaymentIntent intent = await service.CreateAsync(options);

        return new PaymentIntentResponse
        {
            ClientSecret = intent.ClientSecret,
            PublishableKey = _configuration["Stripe:PublishableKey"]!
        };
    }

    public async Task ActivateSubscriptionAsync(int userId, int planId, string? paymentIntentId = null)
    {
        var provider = await _context.ServiceProviders
            .Include(p => p.Subscriptions)
            .FirstOrDefaultAsync(p => p.UserId == userId);

        if (provider == null) return;

        var plan = await _context.SubscriptionPlans.FindAsync(planId);
        if (plan == null) return;

        // Extend current expiry if it exists
        var latestSub = provider.Subscriptions
            .Where(s => s.EndDate > DateTime.Now)
            .OrderByDescending(s => s.EndDate)
            .FirstOrDefault();

        DateTime startDate = latestSub != null ? latestSub.EndDate : DateTime.Now;
        DateTime endDate = startDate.AddDays(plan.DurationInDays);

        var subscription = new Models.Subscription
        {
            ServiceProviderId = provider.UserId,
            SubscriptionPlanId = plan.Id,
            PriceAtPurchase = plan.Price,
            StartDate = startDate,
            EndDate = endDate,
            PaymentIntentId = paymentIntentId
        };

        _context.Subscriptions.Add(subscription);
        await _context.SaveChangesAsync();
    }
}