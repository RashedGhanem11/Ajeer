using System.Reflection.Metadata.Ecma335;
using Ajeer.Api.DTOs.Users;
using FluentValidation;

namespace Ajeer.Api.Validators.Users;

public class UpdateUserProfileRequestValidator : AbstractValidator<UpdateUserProfileRequest>
{
    public UpdateUserProfileRequestValidator()
    {
        RuleFor(x => x.Name)
            .MaximumLength(100).WithMessage("Name cannot exceed 100 characters.");

        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("Invalid email format.");

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("Phone number too long.");

        RuleFor(x => x.ProfileImage)
            .Must(CheckSize).WithMessage("Image max size must be less than 5MB.");
    }

    private bool CheckSize(IFormFile? file)
    {
        if (file is null)
            return true;

        if (file.Length == 0)
            return false;

        return file.Length < 5 * 1024 * 1024;
    }
}