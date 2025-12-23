using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.ToTable("Notifications");

        builder.HasKey(n => n.Id);

        builder.Property(n => n.Title)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(n => n.Type)
            .IsRequired()
            .HasColumnType("nvarchar(50)")
            .HasConversion<string>();

        builder.Property(n => n.Message)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(n => n.CreatedAt)
            .HasDefaultValueSql("GETDATE()");

        builder.Property(n => n.IsRead)
            .HasDefaultValue(false);

        builder.HasOne(n => n.User)
            .WithMany(u => u.Notifications)
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(n => n.Booking)
            .WithMany(b => b.Notifications)
            .HasForeignKey(n => n.BookingId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);
    }
}