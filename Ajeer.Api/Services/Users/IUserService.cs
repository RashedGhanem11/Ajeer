using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.Users;

namespace Ajeer.Api.Services.Users;

public interface IUserService
{
    Task<AuthResponse> UpdateProfileAsync(int userId, UpdateUserProfileRequest dto);

    Task ChangePasswordAsync(int userId, ChangePasswordRequest dto);
}