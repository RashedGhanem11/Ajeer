namespace Ajeer.Api.DTOs.ServiceProviders;

public class ProviderSummaryResponse
{
    public int ServiceProviderId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;
    public bool IsVerified { get; set; }
    public bool IsActive { get; set; }
    public decimal Rating { get; set; }
    public int TotalReviews { get; set; }
    public int TotalBookings { get; set; }
    public DateTime JoinedDate { get; set; }
    public string? ProfilePictureUrl { get; set; }
    public string? IdCardUrl { get; set; }
}