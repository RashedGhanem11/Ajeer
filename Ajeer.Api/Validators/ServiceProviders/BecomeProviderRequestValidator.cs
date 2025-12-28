using Ajeer.Api.DTOs.ServiceProviders;
using FluentValidation;

namespace Ajeer.Api.Validators.ServiceProviders;

public class BecomeProviderRequestValidator : AbstractValidator<BecomeProviderRequest>
{
    public BecomeProviderRequestValidator()
    {
        RuleFor(x => x.Bio)
            .MaximumLength(500).WithMessage("Bio cannot exceed 500 characters.");

        RuleFor(x => x.ServiceIds)
            .NotEmpty().WithMessage("You must select at least one service.")
            .Must(ids => ids != null && ids.Distinct().Count() == ids.Count)
            .WithMessage("Duplicate services are not allowed.");

        RuleFor(x => x.ServiceAreaIds)
            .NotEmpty().WithMessage("You must select at least one service area.")
            .Must(ids => ids != null && ids.Distinct().Count() == ids.Count)
            .WithMessage("Duplicate service areas are not allowed.");

        RuleFor(x => x.Schedules)
            .NotEmpty().WithMessage("You must provide your work schedule.")
            .Must(HaveNoOverlappingSlots).WithMessage("Your schedule contains overlapping time slots on the same day.");

        RuleForEach(x => x.Schedules).ChildRules(schedule =>
        {
            schedule.RuleFor(s => s.DayOfWeek)
                .IsInEnum().WithMessage("Invalid Day of Week.");

            schedule.RuleFor(s => s.StartTime)
                .LessThan(s => s.EndTime)
                .WithMessage("Start time must be before end time.");
        });

        RuleFor(x => x.IdCardImage)
            .Must(file => file == null || (file.Length > 0 && file.Length <= 10 * 1024 * 1024))
            .WithMessage("ID Card image must be less than 10 MB.");
    }

    private bool HaveNoOverlappingSlots(List<WorkScheduleDto> schedules)
    {
        if (schedules == null || !schedules.Any()) return true;

        var groupedByDay = schedules.GroupBy(s => s.DayOfWeek);

        foreach (IGrouping<DayOfWeek, WorkScheduleDto> dayGroup in groupedByDay)
        {
            var sortedSlots = dayGroup.OrderBy(s => s.StartTime).ToList();

            for (int i = 0; i < sortedSlots.Count - 1; i++)
            {
                var current = sortedSlots[i];
                var next = sortedSlots[i + 1];

                if (current.EndTime > next.StartTime)
                {
                    return false;
                }
            }
        }

        return true;
    }
}