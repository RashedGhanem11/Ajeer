using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class ServiceProviderConfiguration : IEntityTypeConfiguration<Models.ServiceProvider>
{
    public void Configure(EntityTypeBuilder<Models.ServiceProvider> builder)
    {
        builder.ToTable("ServiceProviders");

        builder.HasKey(sp => sp.UserId);

        builder.Property(sp => sp.Bio)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(sp => sp.Rating)
            .HasColumnType("decimal(3,2)")
            .HasDefaultValue(0);

        builder.Property(sp => sp.TotalReviews)
            .HasDefaultValue(0);

        builder.Property(sp => sp.IsVerified)
            .HasDefaultValue(false);

        builder.HasOne(sp => sp.User)
            .WithOne(u => u.ServiceProvider)
            .HasForeignKey<Models.ServiceProvider>(sp => sp.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(sp => sp.IdCardAttachment)
            .WithOne()
            .HasForeignKey<Models.ServiceProvider>(sp => sp.IdCardAttachmentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(sp => sp.Bookings)
            .WithOne(b => b.ServiceProvider)
            .HasForeignKey(b => b.ServiceProviderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(sp => sp.Reviews)
            .WithOne(r => r.ServiceProvider)
            .HasForeignKey(r => r.ServiceProviderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(sp => sp.Schedules)
            .WithOne(s => s.ServiceProvider)
            .HasForeignKey(s => s.ServiceProviderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(sp => sp.Subscriptions)
            .WithOne(s => s.ServiceProvider)
            .HasForeignKey(s => s.ServiceProviderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(sp => sp.Services)
            .WithMany(s => s.ServiceProviders)
            .UsingEntity<ProviderService>(
                j => j.HasOne(ps => ps.Service)
                      .WithMany()
                      .HasForeignKey(ps => ps.ServiceId),
                j => j.HasOne(ps => ps.ServiceProvider)
                      .WithMany()
                      .HasForeignKey(ps => ps.ServiceProviderId),
                j =>
                {
                    j.ToTable("ProviderServices");
                    j.HasKey(ps => new { ps.ServiceProviderId, ps.ServiceId });
                }
            );

        builder.HasMany(sp => sp.ServiceAreas)
            .WithMany(a => a.ServiceProviders)
            .UsingEntity<ProviderServiceArea>(
                j => j.HasOne(psa => psa.ServiceArea)
                      .WithMany()
                      .HasForeignKey(psa => psa.ServiceAreaId),
                j => j.HasOne(psa => psa.ServiceProvider)
                      .WithMany()
                      .HasForeignKey(psa => psa.ServiceProviderId),
                j =>
                {
                    j.ToTable("ProviderServiceAreas");
                    j.HasKey(psa => new { psa.ServiceProviderId, psa.ServiceAreaId });
                }
            );
    }
}