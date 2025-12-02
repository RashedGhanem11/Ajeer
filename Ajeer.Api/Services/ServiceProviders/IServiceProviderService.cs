using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.ServiceProviders;

namespace Ajeer.Api.Services.ServiceProviders;

public interface IServiceProviderService
{
    Task<AuthResponse> BecomeProviderAsync(int userId, BecomeProviderRequest dto);
}