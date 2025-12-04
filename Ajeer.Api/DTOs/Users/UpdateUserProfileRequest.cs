namespace Ajeer.Api.DTOs.Users;

public class UpdateUserProfileRequest
{
    public string? Name { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public IFormFile? ProfileImage { get; set; }
}