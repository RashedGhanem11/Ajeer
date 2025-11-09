using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class BookingServiceItemConfiguration : IEntityTypeConfiguration<BookingServiceItem>
{
    public void Configure(EntityTypeBuilder<BookingServiceItem> builder)
    {
        builder.ToTable("BookingServiceItems");

        builder.HasKey(bsi => bsi.Id);

        builder.Property(bsi => bsi.PriceAtBooking)
            .IsRequired()
            .HasColumnType("decimal(10,2)");

        builder.HasOne(bsi => bsi.Booking)
            .WithMany(b => b.BookingServiceItems)
            .HasForeignKey(bsi => bsi.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(bsi => bsi.Service)
            .WithMany()
            .HasForeignKey(bsi => bsi.ServiceId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}