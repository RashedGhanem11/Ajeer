using Ajeer.Api.DTOs.Subscriptions;

namespace Ajeer.Api.Services.Subscriptions;

public interface ISubscriptionService
{
    Task<List<SubscriptionPlanResponse>> GetPlansAsync();

    Task<SubscriptionStatusResponse> GetProviderSubscriptionStatusAsync(int userId);

    Task<PaymentIntentResponse> CreateSubscriptionIntentAsync(int userId, int planId);

    Task ActivateSubscriptionAsync(int userId, int planId, string? paymentIntentId = null);
}