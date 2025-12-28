using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceProviders;

namespace Ajeer.Api.Services.ServiceProviders;

public interface IServiceProviderService
{
    Task<AuthResponse> BecomeProviderAsync(int userId, BecomeProviderRequest dto);

    Task<ProviderProfileResponse> GetMyProfileAsync(int userId);

    Task UpdateProviderProfileAsync(int userId, BecomeProviderRequest dto);

    Task<List<ProviderSummaryResponse>> GetProvidersByStatusAsync(bool isVerified);

    Task<ProviderDetailResponse> GetProviderDetailsAsync(int providerId);

    Task ApproveProviderAsync(int providerId);

    Task RejectProviderAsync(int providerId, string reason);

    Task ToggleProviderActiveStatusAsync(int providerId);

    Task SendCustomEmailAsync(int providerId, string subject, string bodyContent);
}