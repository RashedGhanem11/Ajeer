namespace Ajeer.Api.Validators.Auth;
using Ajeer.Api.DTOs.Auth;
using FluentValidation;

public class PhoneLoginRequestValidator : AbstractValidator<PhoneLoginRequest>
{
    public PhoneLoginRequestValidator()
    {
        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Phone number is required.")
            .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.");
    }
}