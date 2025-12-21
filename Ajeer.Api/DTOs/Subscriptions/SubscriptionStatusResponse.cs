namespace Ajeer.Api.DTOs.Subscriptions;

public class SubscriptionStatusResponse
{
    public bool HasActiveSubscription { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public string? PlanName { get; set; }
    public bool IsProviderActive { get; set; }
}