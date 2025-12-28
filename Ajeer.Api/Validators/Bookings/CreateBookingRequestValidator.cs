using Ajeer.Api.DTOs.Bookings;
using FluentValidation;

namespace Ajeer.Api.Validators.Bookings;

public class CreateBookingRequestValidator : AbstractValidator<CreateBookingRequest>
{
    private const long MaxTotalSize = 30 * 1024 * 1024;
    private const int MaxFilesCount = 3;

    private readonly string[] _allowedExtensions =
    {
        ".jpg", ".jpeg", ".png", ".webp",
        ".mp4", ".mov", ".mp3", ".wav", ".m4a"
    };

    public CreateBookingRequestValidator()
    {
        RuleFor(x => x.ServiceIds)
            .NotEmpty().WithMessage("At least one service must be selected.");

        RuleFor(x => x.ServiceAreaId)
            .NotEmpty().WithMessage("Service Area must be not empty.");

        RuleFor(x => x.ScheduledDate)
            .NotEmpty().WithMessage("Date must be not empty.")
            .GreaterThan(DateTime.Now).WithMessage("Scheduled date must be in the future.");

        RuleFor(x => x.Latitude)
            .NotEmpty().WithMessage("Latitude is required.")
            .NotEqual(0).WithMessage("Invalid Latitude.");

        RuleFor(x => x.Longitude)
            .NotEmpty().WithMessage("Longitude is required.")
            .NotEqual(0).WithMessage("Invalid Longitude.");

        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Notes can not exceed 500 characters.");

        RuleFor(x => x.Attachments)
            .Must(ValidateAttachmentsCount).WithMessage($"You can upload a maximum of {MaxFilesCount} files.")
            .Must(ValidateTotalSize).WithMessage($"Total file size cannot exceed {MaxTotalSize / 1024 / 1024}MB.");

        RuleForEach(x => x.Attachments).ChildRules(attachment =>
        {
            attachment.RuleFor(f => f.Length)
                .GreaterThan(0).WithMessage("File cannot be empty.");

            attachment.RuleFor(f => f)
                .Must(ValidateFileType).WithMessage("Invalid file type. Allowed: Images, Video, Audio.");
        });
    }

    private bool ValidateAttachmentsCount(List<IFormFile>? list)
    {
        if (list is null) return true;
        return list.Count <= MaxFilesCount;
    }

    private bool ValidateTotalSize(List<IFormFile>? list)
    {
        if (list is null) return true;

        long totalSize = list.Sum(f => f.Length);
        return totalSize <= MaxTotalSize;
    }

    private bool ValidateFileType(IFormFile file)
    {
        var ext = Path.GetExtension(file.FileName).ToLower();
        return _allowedExtensions.Contains(ext);
    }
}