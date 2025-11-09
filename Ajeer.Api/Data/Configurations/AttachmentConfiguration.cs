using Ajeer.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Ajeer.Api.Data.Configurations;

public class AttachmentConfiguration : IEntityTypeConfiguration<Attachment>
{
    public void Configure(EntityTypeBuilder<Attachment> builder)
    {
        builder.ToTable("Attachments");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.FileUrl)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(a => a.MimeType)
            .IsRequired()
            .HasColumnType("nvarchar(50)")
            .HasConversion<string>();

        builder.Property(a => a.FileType)
            .IsRequired()
            .HasColumnType("nvarchar(50)")
            .HasConversion<string>();

        builder.HasOne(a => a.Booking)
            .WithMany(b => b.Attachments)
            .HasForeignKey(a => a.BookingId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.Uploader)
            .WithMany()
            .HasForeignKey(a => a.UploaderId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}