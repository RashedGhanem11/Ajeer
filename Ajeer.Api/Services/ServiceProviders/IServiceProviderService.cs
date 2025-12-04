using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceProviders;

namespace Ajeer.Api.Services.ServiceProviders;

public interface IServiceProviderService
{
    Task<AuthResponse> BecomeProviderAsync(int userId, BecomeProviderRequest dto);

    Task<ProviderProfileResponse> GetMyProfileAsync(int userId);

    Task UpdateProviderProfileAsync(int userId, BecomeProviderRequest dto);
}