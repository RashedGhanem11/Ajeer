namespace Ajeer.Api.Models;

public class Schedule
{
    public int Id { get; set; }
    public int ServiceProviderId { get; set; }
    public DayOfWeek DayOfWeek { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }

    public ServiceProvider ServiceProvider { get; set; } = null!;
}