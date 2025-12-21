namespace Ajeer.Api.DTOs.Subscriptions;

public class SubscriptionPlanResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public decimal Price { get; set; }
    public int DurationInDays { get; set; }
}
