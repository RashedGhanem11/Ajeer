using Ajeer.Api.DTOs.Auth;
using FluentValidation;

public class UserRegisterRequestValidator : AbstractValidator<UserRegisterRequest>
{
    public UserRegisterRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Name is required.")
            .MaximumLength(100).WithMessage("Name cannot exceed 100 characters.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("A valid email address is required.")
            .MaximumLength(100).WithMessage("Email cannot exceed 100 characters.");

        RuleFor(x => x.Phone)
            .NotEmpty().WithMessage("Phone number is required.")
            .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.");
            //.Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            //.Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            //.Matches("[0-9]").WithMessage("Password must contain at least one number.")
            //.Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character.");

    }
}