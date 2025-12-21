namespace Ajeer.Api.DTOs.Subscriptions;

public class PaymentIntentResponse
{
    public string ClientSecret { get; set; } = null!;
    public string PublishableKey { get; set; } = null!;
}