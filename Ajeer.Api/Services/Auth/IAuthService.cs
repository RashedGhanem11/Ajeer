using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.Models;

namespace Ajeer.Api.Services.Auth;

public interface IAuthService
{
    Task<AuthResponse?> RegisterUserAsync(UserRegisterRequest dto);

    Task<AuthResponse?> LoginWithEmailAsync(EmailLoginRequest dto);

    Task<AuthResponse?> LoginWithPhoneAsync(PhoneLoginRequest dto);

    string GenerateJwtToken(User user);
}