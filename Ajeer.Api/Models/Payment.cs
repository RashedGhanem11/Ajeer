namespace Ajeer.Api.Models;

public class Payment
{
    public int Id { get; set; }
    public int SubscriptionId { get; set; }
    public decimal Amount { get; set; }
    public DateTime PaymentDate { get; set; }

    public Subscription Subscription { get; set; } = null!;
}