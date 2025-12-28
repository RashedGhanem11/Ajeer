using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.DTOs.Users;
using Ajeer.Api.Services.Auth;
using Ajeer.Api.Services.Files;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Services.Users;

public class UserService(AppDbContext _context, IFileService _fileService, IAuthService _authService) : IUserService
{
    public async Task<AuthResponse> UpdateProfileAsync(int userId, UpdateUserProfileRequest dto)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) throw new Exception("User not found.");

        if (!string.IsNullOrEmpty(dto.Name))
            user.Name = dto.Name;

        if (!string.IsNullOrEmpty(dto.Email) && !(dto.Email.ToLower() == user.Email.ToLower()))
        {
            bool emailExists = await _context.Users.AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower());

            if (emailExists)
                throw new Exception("Email is already taken.");

            user.Email = dto.Email;
        }

        if (!string.IsNullOrEmpty(dto.Phone) && dto.Phone != user.Phone)
        {
            bool phoneExists = await _context.Users.AnyAsync(u => u.Phone == dto.Phone);

            if (phoneExists)
                throw new Exception("Phone number is already taken.");

            user.Phone = dto.Phone;
        }

        if (dto.ProfileImage != null)
        {
            string? newFileName = await _fileService.SaveFileAsync(dto.ProfileImage, "profilePictures");

            if (newFileName != null)
            {
                // Delete old image if it exists
                if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
                {
                    _fileService.DeleteFile("profilePictures", user.ProfilePictureUrl);
                }

                user.ProfilePictureUrl = newFileName;
            }
        }

        await _context.SaveChangesAsync();

        string newToken = _authService.GenerateJwtToken(user);

        bool hasApp = await _context.ServiceProviders.AnyAsync(sp => sp.UserId == user.Id);

        return new AuthResponse
        {
            Token = newToken,
            UserId = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Role = user.Role,
            ProfilePictureUrl = _fileService.GetPublicUrl("profilePictures", user.ProfilePictureUrl),
            HasProviderApplication = hasApp
        };
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordRequest dto)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) throw new Exception("User not found.");

        bool isCorrect = BCrypt.Net.BCrypt.Verify(dto.CurrentPassword, user.Password);
        if (!isCorrect) throw new Exception("Incorrect current password.");

        string newHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
        user.Password = newHash;

        await _context.SaveChangesAsync();
    }
}