using Ajeer.Api.DTOs.Bookings;

namespace Ajeer.Api.DTOs.Admin.Dashboard;

public class DashboardResponse
{
    public int TotalUsers { get; set; }
    public int ActiveProviders { get; set; }
    public int PendingProviders { get; set; }
    public double AverageProviderRating { get; set; }
    public decimal TotalRevenue { get; set; }

    public int TotalBookings { get; set; }
    public int PendingBookings { get; set; }
    public int ActiveBookings { get; set; }
    public int CompletedBookings { get; set; }
    public double OnTimeRate { get; set; }
}