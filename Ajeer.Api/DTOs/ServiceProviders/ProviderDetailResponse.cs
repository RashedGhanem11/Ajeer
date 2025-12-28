using Ajeer.Api.DTOs.Bookings;
using Ajeer.Api.DTOs.Subscriptions;

namespace Ajeer.Api.DTOs.ServiceProviders;

public class ProviderDetailResponse : ProviderSummaryResponse
{
    public string Bio { get; set; } = null!;
    public List<string> Services { get; set; } = new();
    public SubscriptionStatusResponse Subscription { get; set; } = null!;
    public List<BookingSummaryResponse> RecentBookings { get; set; } = new();
    public List<ReviewResponse> RecentReviews { get; set; } = new();
}
