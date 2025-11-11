using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class ScheduleConfiguration : IEntityTypeConfiguration<Schedule>
{
    public void Configure(EntityTypeBuilder<Schedule> builder)
    {
        builder.ToTable("Schedules");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.DayOfWeek)
            .IsRequired()
            .HasColumnType("tinyint");

        builder.Property(s => s.StartTime)
            .IsRequired();

        builder.Property(s => s.EndTime)
            .IsRequired();

        builder.HasOne(s => s.ServiceProvider)
            .WithMany(sp => sp.Schedules)
            .HasForeignKey(s => s.ServiceProviderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasData(SeedData.GetSchedules());
    }
}