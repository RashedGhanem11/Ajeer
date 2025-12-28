using Ajeer.Api.Enums;

namespace Ajeer.Api.DTOs.Auth;

public class AuthResponse
{
    public string Token { get; set; } = null!;
    public int UserId { get; set; }
    public string Name { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public UserRole Role { get; set; }
    public string? ProfilePictureUrl { get; set; }
    public bool HasProviderApplication { get; set; }
}