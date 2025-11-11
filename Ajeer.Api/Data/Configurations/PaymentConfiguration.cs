using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.ToTable("Payments");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Amount)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.Property(p => p.PaymentDate)
            .HasDefaultValueSql("GETDATE()");

        builder.HasOne(p => p.Subscription)
            .WithOne(s => s.Payment)
            .HasForeignKey<Payment>(p => p.SubscriptionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasData(SeedData.GetPayments());
    }
}