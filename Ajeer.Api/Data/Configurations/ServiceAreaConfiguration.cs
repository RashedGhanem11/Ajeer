using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class ServiceAreaConfiguration : IEntityTypeConfiguration<ServiceArea>
{
    public void Configure(EntityTypeBuilder<ServiceArea> builder)
    {
        builder.ToTable("ServiceAreas");

        builder.HasKey(sa => sa.Id);

        builder.Property(sa => sa.AreaName)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(sa => sa.CityName)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(sc => sc.IsActive)
            .IsRequired()
            .HasDefaultValue(true);
    }
}
