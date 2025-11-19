using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Ajeer.Api.Data;
using Ajeer.Api.DTOs.Auth;
using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace Ajeer.Api.Services.Auth;

public class AuthService(AppDbContext context, IConfiguration configuration) : IAuthService
{
    private string? GetPublicImageUrl(User user)
    {
        if (string.IsNullOrEmpty(user.ProfilePictureUrl))
        {
            return null;
        }

        return $"/uploads/profilePictures/{user.ProfilePictureUrl}";
    }

    public string GenerateJwtToken(User user)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
        };

        var jwtSettings = configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["Secret"];
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];
        var expirationMinutes = int.Parse(jwtSettings["TokenExpirationInMinutes"] ?? "1440");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey!));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddMinutes(expirationMinutes),
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = credentials
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return tokenHandler.WriteToken(token);
    }

    public async Task<AuthResponse?> RegisterUserAsync(UserRegisterRequest dto)
    {
        bool userExists = await context.Users.AnyAsync(u =>
        u.Email.ToLower() == dto.Email.ToLower() || u.Phone == dto.Phone);

        if (userExists)
        {
            return null;
        }

        string passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);

        var newUser = new User
        {
            Name = dto.Name,
            Email = dto.Email,
            Phone = dto.Phone,
            Password = passwordHash,
        };

        context.Users.Add(newUser);
        await context.SaveChangesAsync();

        string token = GenerateJwtToken(newUser);

        return new AuthResponse
        {
            Token = token,
            UserId = newUser.Id,
            Name = newUser.Name,
            Email = newUser.Email,
            Phone = newUser.Phone,
            Role = newUser.Role.ToString(),
            ProfilePictureUrl = null
        };
    }

    public async Task<AuthResponse?> LoginWithEmailAsync(EmailLoginRequest dto)
    {
        var user = await context.Users
            .SingleOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower());

        if (user == null)
        {
            return null;
        }

        bool passwordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.Password);

        if (!passwordValid)
        {
            return null;
        }

        string token = GenerateJwtToken(user);

        return new AuthResponse
        {
            Token = token,
            UserId = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Role = user.Role.ToString(),
            ProfilePictureUrl = GetPublicImageUrl(user)
        };
    }

    public async Task<AuthResponse?> LoginWithPhoneAsync(PhoneLoginRequest dto)
    {
        var user = await context.Users
            .SingleOrDefaultAsync(u => u.Phone == dto.PhoneNumber);

        if (user == null)
        {
            return null;
        }

        bool passwordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.Password);

        if (!passwordValid)
        {
            return null;
        }

        string token = GenerateJwtToken(user);

        return new AuthResponse
        {
            Token = token,
            UserId = user.Id,
            Name = user.Name,
            Email = user.Email,
            Phone = user.Phone,
            Role = user.Role.ToString(),
            ProfilePictureUrl = GetPublicImageUrl(user)
        };
    }
}