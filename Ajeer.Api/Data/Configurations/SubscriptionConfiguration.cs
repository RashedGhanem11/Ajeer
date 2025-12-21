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

        builder.Property(s => s.PriceAtPurchase)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(s => s.StartDate)
            .HasDefaultValueSql("GETDATE()");

        builder.Property(s => s.EndDate)
            .IsRequired();

        builder.Property(s => s.PaymentIntentId)
            .IsRequired(false)
            .HasMaxLength(255);

        builder.HasOne(s => s.ServiceProvider)
            .WithMany(sp => sp.Subscriptions)
            .HasForeignKey(s => s.ServiceProviderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(s => s.SubscriptionPlan)
            .WithMany()
            .HasForeignKey(s => s.SubscriptionPlanId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}