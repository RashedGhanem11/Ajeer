using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Ajeer.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Attachment> Attachments { get; set; }
    public DbSet<Booking> Bookings { get; set; }
    public DbSet<BookingServiceItem> BookingServiceItems { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<ProviderService> ProviderServices { get; set; }
    public DbSet<ProviderServiceArea> ProviderServiceAreas { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<Schedule> Schedules { get; set; }
    public DbSet<Service> Services { get; set; }
    public DbSet<ServiceArea> ServiceAreas { get; set; }
    public DbSet<ServiceCategory> ServiceCategories { get; set; }
    public DbSet<Models.ServiceProvider> ServiceProviders { get; set; }
    public DbSet<Subscription> Subscriptions { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}