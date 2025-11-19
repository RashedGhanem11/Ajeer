namespace Ajeer.Api.Validators.Auth;
using Ajeer.Api.DTOs.Auth;
using FluentValidation;

public class EmailLoginRequestValidator : AbstractValidator<EmailLoginRequest>
{
    public EmailLoginRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .MaximumLength(100).WithMessage("Email cannot exceed 100 characters.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.");
    }
}