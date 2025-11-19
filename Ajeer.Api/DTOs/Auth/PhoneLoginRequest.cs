namespace Ajeer.Api.DTOs.Auth;

public class PhoneLoginRequest
{
    public string PhoneNumber { get; set; } = null!;
    public string Password { get; set; } = null!;
}