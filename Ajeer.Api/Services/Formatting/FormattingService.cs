using System.Globalization;

namespace Ajeer.Api.Services.Formatting;

public class FormattingService : IFormattingService
{
    public string FormatCurrency(decimal amount)
    {
        return $"JOD {amount.ToString("N2", new CultureInfo("en-US"))}";
    }

    public string FormatEstimatedTime(decimal hours)
    {
        int totalMinutes = (int)(hours * 60);
        int wholeHours = totalMinutes / 60;
        int remainingMinutes = totalMinutes % 60;

        string timeString = "";

        if (wholeHours > 0)
        {
            timeString += $"{wholeHours} hr" + (wholeHours > 1 ? "s" : "");
            if (remainingMinutes > 0)
            {
                timeString += $" {remainingMinutes} mins";
            }
        }
        else if (remainingMinutes > 0)
        {
            timeString += $"{remainingMinutes} mins";
        }
        else
        {
            timeString += "less than 1 hr";
        }

        return "Est. Time: " + timeString;
    }
}