using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class SubscriptionConfiguration : IEntityTypeConfiguration<Subscription>
{
    public void Configure(EntityTypeBuilder<Subscription> builder)
    {
        builder.ToTable("Subscriptions");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.Price)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(s => s.StartDate)
            .HasDefaultValueSql("GETDATE()");

        builder.Property(s => s.EndDate)
            .IsRequired();

        builder.Property(s => s.IsActive)
            .HasDefaultValue(true);

        builder.HasOne(s => s.ServiceProvider)
            .WithMany(sp => sp.Subscriptions)
            .HasForeignKey(s => s.ServiceProviderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(s => s.Payment)
            .WithOne(p => p.Subscription)
            .HasForeignKey<Payment>(p => p.SubscriptionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}