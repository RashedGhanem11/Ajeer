using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.Models;

namespace Ajeer.Api.Services.Auth;

public interface IAuthService
{
    Task<AuthResponse?> RegisterUserAsync(UserRegisterRequest dto);

    Task<AuthResponse?> LoginAsync(LoginRequest dto);

    Task<bool?> VerifyEmailAsync(string token);

    string GenerateJwtToken(User user);
}