namespace Ajeer.Api.Services.Formatting;

public interface IFormattingService
{
    string FormatEstimatedTime(decimal hours);

    string FormatCurrency(decimal amount);

    string FormatRelativeTime(DateTime messageTime);
}