using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class BookingConfiguration : IEntityTypeConfiguration<Booking>
{
    public void Configure(EntityTypeBuilder<Booking> builder)
    {
        builder.ToTable("Bookings");

        builder.HasKey(b => b.Id);

        builder.Property(b => b.Status)
            .IsRequired()
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(b => b.ScheduledDate)
            .IsRequired();

        builder.Property(b => b.EstimatedHours)
            .IsRequired()
            .HasColumnType("decimal(5,2)");

        builder.Property(b => b.TotalAmount)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(b => b.Address)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(b => b.Latitude)
            .IsRequired()
            .HasColumnType("decimal(10,8)");

        builder.Property(b => b.Longitude)
            .IsRequired()
            .HasColumnType("decimal(11,8)");

        builder.Property(b => b.Notes)
            .IsRequired(false)
            .HasMaxLength(500);

        builder.Property(b => b.CreatedAt)
            .HasDefaultValueSql("GETDATE()");

        builder.HasOne(b => b.User)
            .WithMany(u => u.Bookings)
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.ServiceProvider)
            .WithMany(sp => sp.Bookings)
            .HasForeignKey(b => b.ServiceProviderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.ServiceArea)
            .WithMany(sa => sa.Bookings)
            .HasForeignKey(b => b.ServiceAreaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.Review)
            .WithOne(r => r.Booking)
            .HasForeignKey<Review>(r => r.BookingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(b => b.BookingServiceItems)
            .WithOne(bsi => bsi.Booking)
            .HasForeignKey(bsi => bsi.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(b => b.Messages)
            .WithOne(m => m.Booking)
            .HasForeignKey(m => m.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(b => b.Attachments)
            .WithOne(a => a.Booking)
            .HasForeignKey(a => a.BookingId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasData(SeedData.GetBookings());
    }
}