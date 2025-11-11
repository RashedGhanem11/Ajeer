using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.Property(u => u.Phone)
            .IsRequired()
            .HasMaxLength(20);

        builder.HasIndex(u => u.Phone)
            .IsUnique();

        builder.Property(u => u.Password)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(u => u.IsActive)
            .HasDefaultValue(true);

        builder.Property(u => u.Role)
            .IsRequired()
            .HasColumnType("tinyint")
            .HasDefaultValueSql("0");

        builder.Property(u => u.ProfilePictureUrl)
            .IsRequired(false)
            .HasMaxLength(300);

        builder.Property(u => u.LastLoginAt)
            .HasDefaultValueSql("GETDATE()");

        builder.Property(u => u.CreatedAt)
            .HasDefaultValueSql("GETDATE()");

        builder.HasOne(u => u.ServiceProvider)
            .WithOne(sp => sp.User)
            .HasForeignKey<Models.ServiceProvider>(sp => sp.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.SentMessages)
            .WithOne(m => m.Sender)
            .HasForeignKey(m => m.SenderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.ReceivedMessages)
            .WithOne(m => m.Receiver)
            .HasForeignKey(m => m.ReceiverId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.Notifications)
            .WithOne(n => n.User)
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.Reviews)
            .WithOne(r => r.User)
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.Bookings)
            .WithOne(b => b.User)
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasData(SeedData.GetUsers());
    }
}