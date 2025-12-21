namespace Ajeer.Api.Models;

public class Subscription
{
    public int Id { get; set; }
    public string? PaymentIntentId { get; set; }
    public int ServiceProviderId { get; set; }
    public int SubscriptionPlanId { get; set; }
    public decimal PriceAtPurchase { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }

    public ServiceProvider ServiceProvider { get; set; } = null!;
    public SubscriptionPlan SubscriptionPlan { get; set; } = null!;
}