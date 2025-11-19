namespace Ajeer.Api.DTOs.Auth;

public class EmailLoginRequest
{
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
}